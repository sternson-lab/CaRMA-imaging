function [header,Aout,imgInfo] = opentif(varargin)
%% OPENTIF   
% Reads a ScanImage TIFF file
%% Description
% Opens a ScanImage TIF file, extracting its header information and, if specified, stores all of image contents as output array Aout if specified. 
% By default, Aout, if specified for output, is of size MxNxCxFxSxV, where C spans the channel indices, F spans the frame indicies, S spans the 
% slice indices, and V the volume indices.
%
% NOTE: IF the second output argument (Aout) is not assigned to output variable
%     THEN image file is not actually read -- only  header information is extracted
%     
% IMPORTANT: opentif currently only exports the header and sequential image data. Once the tiff header specification reaches a stable 
%	    point, parsing and data organization will be reincorporated ++++
%
%% SYNTAX
%   opentif()
%   opentif(filename)
%   header = opentif(...)
%   [header,Aout] = opentif(...)
%   [header,Aout,imgInfo] = opentif(...)
%		INPUT
%       	filename: Name of TIF file, with or without '.tif' extension. If omitted, a dialog is launched to allow interactive selection.
%       	flagN/flagNArg: Flags (string-valued) and/or flag/value pairs, in any order, specifying options to use in opening specified file
%
%		OUTPUT
%       	header: Structure comprising information stored by ScanImage into TIF header
%       	Aout: MxNxCxFxSxV array, with images of size MxN for C channels, F frames, S slices, and V volumes. Default type is uint16. 
%       	imgInfo: Structure comprising basic information about the structure of the output array Aout
%
% NOTE: IF the second output argument (Aout) is not assigned to output variable
%       THEN image file is not actually read -- only header information is extracted
%
%% FLAGS (case-insensitive)
%
%   WITH ARGUMENTS
%       'channel' or 'channels': Argument specifies subset of channel(s) to extract. Ex: 1,[1 3], 2:4. 
%       'frame' or 'frames': Argument specifies subset of frames present to extract. Use 'inf' to specify all frames above highest specified value. Ex: 1:30, [50 inf], [1:9 11:19 21 inf]
%       'slice' or 'slices': Argument specifies subset of slices present to extract. Use 'inf' to specify all slices above highest specified value. Ex: 1:30, [50 inf], [1:9 11:19 21 inf]
%       'volume' or 'volumes': Argument specifies subset of volumes present to extract. Use 'inf' to specify all slices above highest specified value. Ex: 1:30, [50 inf], [1:9 11:19 21 inf]
%
%% NOTES
%   This function replaces the scim_openTif() function supplied with ScanImage 4.2
%  	
%	In case of errors, the program will attempt to output whatever image data is available to it as an uncategorized stream of images
%	This stream will be an array of the form MxNxImg raw ouput without any post-processing, containing all the frames found within the file, where Img is the number of images
%
%   TODO: Port more advanced features to ScanImage 5 from SI3/4 scim_openTif
%   TODO: Add a flag to discard fastZ-flyback frames if present
%
%   12/7/2016 saintgene modifed the file and fixed some bugs (as shown in the comments by saintgene below).
%   03/28/2020 saintgene fixed setDirectory is quite slow in Matlab 2019b and 2020a

    % Initialize output variables
    header = [];
    Aout   = [];
    imgInfo = struct();

    % Constants/Inits
    if nargout < 0 || nargout > 3
        most.idioms.warn('Invalid arguments'); 
        return
    end

    % Parse input arguments

    flagNames = {'channel' 'channels' 'slice' 'slices' 'frame' 'frames' 'volume' 'volumes'};
    argFlags = {'channel' 'channels' 'slice' 'slices' 'frame' 'frames' 'volume' 'volumes'};

    flagIndices = find(cellfun(@(x)ischar(x) && (ismember(lower(x),flagNames) || ismember(lower(x),argFlags)),varargin));

    flags = cellfun(@lower,varargin(flagIndices),'UniformOutput',false);
    if isempty(flags)
        flags = {};
    end

    streamOutput = false;

    % Determine input file
    if isempty(find(flagIndices==1)) && nargin>=1 && ischar(varargin{1})
        fileName = varargin{1};
    else
        fileName = '';
    end

    if isempty(fileName)
        [f, p] = uigetfile({'*.tif;*.tiff'},'Select Image File');
        if f == 0
            most.idioms.warn('Invalid arguments'); 
            return;
        end
        fileName = fullfile(p,f); 
    end

    %Extract filepath for future use
    %[filePath,fileStem,fileExt] = fileparts((fileName));

    % Read TIFF file; extract # frames & image header
    if ~exist(fileName,'file') && ~exist([fileName '.tif'],'file') && ~exist([fileName '.tiff'],'file') 
        error('''%s'' is not a recognized flag or filename. Aborting.',fileName);
    elseif exist([fileName '.tif'],'file') 
        fileName = [fileName '.tif'];
    elseif exist([fileName '.tiff'],'file') 
        fileName = [fileName '.tiff'];
    end

    %most.idioms.warn(['Loading file ' fileName]);

    warning('off','MATLAB:tifflib:TIFFReadDirectory:libraryWarning');
    hTif = Tiff(fileName);

    [fileHeader, frameDescs] = scanimage.util.private.getHeaderData(hTif);

    bErrorFound = false;
    try
        verInfo = scanimage.util.private.getSITiffVersionInfo(fileHeader);
        header = scanimage.util.private.parseFrameHeaders(fileHeader,frameDescs,verInfo);
        si_ver = verInfo.SI_MAJOR;
    catch
        bErrorFound = true;
        si_ver = '';
    end

    numImages = numel(frameDescs);

    %Reincorporate conditional once header spec is stable
    if numImages == 0 || strcmp(si_ver,'')
        bErrorFound = true;
    end

    if bErrorFound
        [Aout,imgInfo] = scanimage.util.private.streamOutputQuit(hTif,numImages,si_ver);
        return;
    end

    hdr = scanimage.util.private.extractHeaderData(header,verInfo);

    % Read image meta-data
    savedChans = hdr.savedChans;

    %Display channel information to user
    %most.idioms.warn(['Matrix of channels saved: ' mat2str(savedChans)]);

    numChans = length(savedChans);
    numPixels = hdr.numPixels;
    numLines = hdr.numLines;
    numSlices = hdr.numSlices;
    numVolumes = hdr.numVolumes;
    numFrames = hdr.numFrames;
    numDiscardFrames = 0;
    discardFlybackframesEnabled = false;

    % If using FastZ, use slices value that contains potential flyback frames
    % for proper organization of output image-array
    if hdr.discardFlybackframesEnabled
        actualNumSlices = hdr.numFramesPerVolume;
    else
        actualNumSlices = hdr.numSlices;
    end

%     if actualNumSlices > 1 && numFrames > 1 %changed by saintgene
%         most.idioms.warn('Cannot interpret multiple frames and slices simultaneously at this time.');
%         [Aout,imgInfo] = scanimage.util.private.streamOutputQuit(hTif,numImages,si_ver);
%         return;
%     end

    % This section makes sure there are no issues with nextTrigger data
    if numImages ~= numChans*numFrames*actualNumSlices*numVolumes
        % We are working under the assumption that only volumes can have multiple "slices"
        if actualNumSlices > 1
            numVolumes = floor(numImages/numChans/actualNumSlices);
            numFrames = 1;  % This should already be the case
        elseif numFrames > 1
            % In this case there are no volumes, since we only can have 1 frame and multiple slices in a volume
            numVolumes = 1; % This should already be the case
            actualNumSlices = 1;  % This should already be the case
            % We discard the previous value of frames and adjust to what was acquired before the next-trigger came in
            numFrames = floor(numImages/numChans);  
        end

        if numImages ~= numChans*numFrames*actualNumSlices*numVolumes
            most.idioms.warn('Unexpected number of images.');
            [Aout,imgInfo] = scanimage.util.private.streamOutputQuit(hTif,numImages,si_ver);
            return;
        end
    end

    %DEBUG msg
    %most.idioms.warn(['numImages = ' num2str(numImages)]);
    %most.idioms.warn(['numChans = ' num2str(numChans)]);
    %most.idioms.warn(['numFrames = ' num2str(numFrames)]);
    %most.idioms.warn(['numSlices = ' num2str(numSlices)]);
    %most.idioms.warn(['numVolumes = ' num2str(numVolumes)]);
    %most.idioms.warn(' ');

    if ~numFrames || ~numSlices
        most.idioms.warn('Acquisition did not complete a single frame or slice. Aborting.');
        [Aout,imgInfo] = scanimage.util.private.streamOutputQuit(hTif,numImages,si_ver);
        return;
    end

    %VI120910A: Detect/handle header-only operation (don't read data)
    if nargout <= 1
        return;
    end

    % Process Flags

    %Determine channels to extract
    if any(ismember({'channel' 'channels'},flags))
        selectedChans = scanimage.util.private.getArg(varargin,{'channel' 'channels'},flags,flagIndices);

        if ~isempty(setdiff(selectedChans,savedChans))
            selectedChans(find(setdiff(selectedChans,savedChans))) = [];
            warning('Some specified channels to extract not detected in file and, hence, ignored');
            if isempty(selectedChans)
                warning('No saved channels are specified to extract. Aborting.');
                return;
            end
        end
    else
        selectedChans = savedChans;
    end

    %This mode stays given the nature of non-selected channel storage
    %Auxiliary mapping for channel selection to index
    chanKey = num2cell(savedChans);
    chanVal = 1:length(savedChans);   %+++ Change to savedChans for selection if no resizing occurs?
    chanMap = containers.Map(chanKey,chanVal);

    %Determine slices to extract
    if numSlices >= 1 && any(ismember({'slice' 'slices'},flags))
        selectedSlices = scanimage.util.private.selectImages(varargin,{'slice' 'slices'},numSlices, flags, flagIndices);
    else
        %Extract all slices
        selectedSlices = 1:numSlices;
    end

    % RRR Extract all frames for now
    %Determine frames to extract
    if numFrames >= 1 && any(ismember({'frame' 'frames'},flags))
        selectedFrames = scanimage.util.private.selectImages(varargin,{'frame' 'frames'},numFrames, flags, flagIndices);
    else
        %Extract all frames
        selectedFrames = 1:numFrames;
    end


    %Determine volumes to extract
    if numVolumes >= 1 && any(ismember({'volume' 'volumes'},flags))
        selectedVolumes = scanimage.util.private.selectImages(varargin,{'volume' 'volumes'},numVolumes, flags, flagIndices);
    else
        %Extract all frames
        selectedVolumes = 1:numVolumes;
    end


    %Determine if any selection is being made
    forceSelection = any(ismember({'channel' 'channels' 'slice' 'slices' 'frame' 'frames' 'volume' 'volumes'},flags));

    % Preallocate image data
    switch hTif.getTag('SampleFormat')
        case 1
            imageDataType = 'uint16';
        case 2
            imageDataType = 'int16';
        otherwise
            assert('Unrecognized or unsupported SampleFormat tag found');
    end

    %Look-up values for faster operation
    lenSelectedFrames = length(selectedFrames);
    lenSelectedChans = length(selectedChans);
    lenSelectedSlices = length(selectedSlices);
    lenSelectedVolumes = length(selectedVolumes);

    lenTotalChans = length(savedChans);
    lenTotalSlices = numSlices;
    lenTotalFrames = numFrames;
    % lenTotalVolumes = numVolumes;

    %HACK! For now there seems to be an issue with the flyback possibly due to mroi
    %still being developed. We need to take only the last section of the following values: 
    %The following also takes care of MROI mode discrepancies, since we don't have access
    %to the properties of MROI captures through the TIFF header at the moment
    numLines = hTif.getTag('ImageLength');
    numPixels = hTif.getTag('ImageWidth');

    Aout = zeros(numLines,numPixels,lenSelectedChans,lenSelectedFrames,lenSelectedSlices,lenSelectedVolumes,imageDataType);    

    % Read image data
    selectedChans = selectedChans';

    if streamOutput
        % This mode is for the case in which the selection parameters cannot be 
        % trusted. For instance, when the number of images is different than 
        % expected, but we would still like to 
        % Checking this mode has priority given that it will always output existing data
        % No postprocessing for data (such as removing discard frames) at this point
        most.idioms.warn('Insufficient or incorrect header data.')

        % Preallocate image data
        Aout = zeros(numLines,numPixels,numImages,imageDataType);    

        for idx = 1:numImages
            hTif.setDirectory(idx);
            Aout(:,:,idx) = hTif.read();
        end

        most.idioms.warn('Returning default, uncategorized stream of Tiff frames')

    elseif forceSelection
        %following codes modified by saintgene
        for p = 1:lenSelectedVolumes
            idx1 = selectedVolumes(p);
            for j = 1:lenSelectedSlices
                idx2 = (idx1-1)*actualNumSlices+selectedSlices(j);
                for k = 1:lenSelectedFrames
                    idx3 = (idx2-1)*lenTotalFrames+selectedFrames(k);
                    for i = 1:lenSelectedChans
                        
                        idx4 = chanMap(selectedChans(i));
                        idx = (idx3-1)*lenTotalChans + idx4;
                        %SELECTION MODE: (can allow parameter selection)
%                         idx = chanMap(selectedChans(i));
%                         %Get the tiff-index for the frames
%                         idx = lenTotalChans*(selectedFrames(k) - 1) + idx;
%                         %Get the tiff-index for the slices
%                         idx = lenTotalFrames*lenTotalChans*(selectedSlices(j) - 1) + idx;
%                         %Get the tiff-index for the volumes
%                         idx = actualNumSlices*lenTotalFrames*lenTotalChans*(selectedVolumes(p) - 1) + idx; %fixed by saintgene

                        %+++ Test the following expression.
                        if ismember(selectedChans(i), savedChans)
                            hTif.setDirectory(idx);
                            Aout(:,:,i,k,j,p) = hTif.read();
                        end
                    end
                end
            end
        end
    else
        idx = 0;
        for p = 1:lenSelectedVolumes
            for j = 1:actualNumSlices%lenSelectedSlices %%fixed by saintgene
                for k = 1:lenSelectedFrames
                    for i = 1:lenSelectedChans
                        %NO-SELECTION MODE: (more efficient)
                        idx = idx + 1;
                        
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        %speed up by saintgene 03/28/2020
                        if(idx==1)
                            hTif.setDirectory(idx); %slow function in Matlab 2019 and later
                        else
                            hTif.nextDirectory(); %fast function 03/28/2020
                        end
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

                        if ismember(selectedChans(i), savedChans)
%                            hTif.setDirectory(idx); %modified by saintgene
                            Aout(:,:,i,k,j,p) = hTif.read();
                        end
                    end
                end
            end
        end
        Aout = Aout(:,:,:,:,1:lenSelectedSlices,:); %fixed by saintgene
    end

    % Prepare imgInfo
    imgInfo.numImages = numImages;
    imgInfo.numChans = numChans;
    imgInfo.numPixels = numPixels;
    imgInfo.numLines = numLines;
    imgInfo.numSlices = numSlices;
    imgInfo.numVolumes = numVolumes;
    imgInfo.numFrames = numFrames;
    imgInfo.filename = fileName;	
    imgInfo.si_ver = si_ver;	

end


%--------------------------------------------------------------------------%
% opentif.m                                                                %
% Copyright © 2016 Vidrio Technologies, LLC                                %
%                                                                          %
% ScanImage is licensed under the Apache License, Version 2.0              %
% (the "License"); you may not use any files contained within the          %
% ScanImage release except in compliance with the License.                %
% You may obtain a copy of the License at                                  %
% http://www.apache.org/licenses/LICENSE-2.0                               %
%                                                                          %
% Unless required by applicable law or agreed to in writing, software      %
% distributed under the License is distributed on an "AS IS" BASIS,        %
% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. %
% See the License for the specific language governing permissions and      %
% limitations under the License.                                           %
%--------------------------------------------------------------------------%
