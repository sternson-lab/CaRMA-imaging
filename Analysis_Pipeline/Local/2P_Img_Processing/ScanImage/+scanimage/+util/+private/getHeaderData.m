function [fileHeader, frameDescs] = getHeaderData(tifObj)
% Returns a cell array of strings for each TIFF header
% If the number of images is desired one can call numel on frameStringCell or use the 
% second argument (the latter approach is preferrable)
%
    numImg = 0;

    % Before anything else, see if the tiff file has any image-data
    try
        %Parse SI from the first frame
        numImg = 1;
        while ~tifObj.lastDirectory()
            tifObj.nextDirectory();
            numImg = numImg + 1;
        end
    catch
        warning('The tiff file may be corrupt.')
        % numImg will have the last valid value, so we can keep going and 
        % deliver as much data as we can
    end
    tifObj.setDirectory(1);

    %Make sure the tiff file's ImageDescription didn't go over the limit set in 
    %Acquisition.m:LOG_TIFF_HEADER_EXPANSION
    try
        if ~isempty(strfind(tifObj.getTag('ImageDescription'), '<output truncated>'))
            most.idioms.warn('Corrupt header data');
            return;
        end
    catch
        most.idioms.warn('Corrupt or incomplete tiff header');
        return
    end

    frameDescs = cell(1,numImg);

    for idxImg = 1:numImg
        frameDescs{1,idxImg} = tifObj.getTag('ImageDescription');
        if idxImg == numImg; break;end  % Handles last case
        tifObj.nextDirectory();
    end
    
    try
        fileHeaderStr = tifObj.getTag('Software');
    catch
        % legacy style
        fileHeaderStr = frameDescs{1};
    end
    
    try
        if fileHeaderStr(1) == '{'
            s = most.json.loadjson(fileHeaderStr);
            
            %known incorrect handling of channel luts!
            n = size(s.SI.hChannels.channelLUT,1);
            c = cell(1,n);
            for i = 1:n
                c{i} = s.SI.hChannels.channelLUT(i,:);
            end
            s.SI.hChannels.channelLUT = c;
            
            fileHeader.SI = s.SI;
        else
            % legacy style
            fileHeaderStr = strrep(fileHeaderStr, 'scanimage.SI.','SI.');
            rows = textscan(fileHeaderStr,'%s','Delimiter','\n');
            rows = rows{1};
            
            for idxLine = 1:numel(rows)
                if strncmp(rows{idxLine},'SI.',3)
                    break;
                end
            end
            
            fileHeader = scanimage.util.private.decodeHeaderLines(rows(idxLine:end));
        end
    catch
        fileHeader = struct();
    end
end


%--------------------------------------------------------------------------%
% getHeaderData.m                                                          %
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
