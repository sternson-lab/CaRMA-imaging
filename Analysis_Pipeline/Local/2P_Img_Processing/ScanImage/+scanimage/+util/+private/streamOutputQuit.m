function [Aout,imgInfo] = streamOutputQuit(hTif,numImages,si_ver)
% This function returns available data and should be followed by an exit call
% The header is assumed to have been set prior to calling this method
%
    %% Preallocate image data
    switch hTif.getTag('SampleFormat')
        case 1
            imageDataType = 'uint16';
        case 2
            imageDataType = 'int16';
        otherwise
            assert('Unrecognized or unsupported SampleFormat tag found');
    end

    numLines = hTif.getTag('ImageLength');
    numPixels = hTif.getTag('ImageWidth');

    Aout = zeros(numLines,numPixels,numImages,imageDataType);    
    imgInfo.numImages = numImages;	% Only the number of images is reliable
    imgInfo.filename = hTif.FileName;	% As well as the filename, of course
    imgInfo.si_ver = si_ver;	% ScanImage version 

    for idx = 1:numImages
        hTif.setDirectory(idx);
        Aout(:,:,idx) = hTif.read();
    end

    most.idioms.warn('Returning default, uncategorized stream of Tiff frames');
    return
end


%--------------------------------------------------------------------------%
% streamOutputQuit.m                                                       %
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
