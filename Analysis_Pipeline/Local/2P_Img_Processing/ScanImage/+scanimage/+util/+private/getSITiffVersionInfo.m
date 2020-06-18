function [verInfo] = getSITiffVersionInfo(fileHeader)
%   Analize a tiff-header frame-string to determine the scanimage version it came from
%   The tags provided by the ScanImage header are insufficient to keep track of released 
%   versions of ScanImage, hence we'll provide a structure called verInfo to help us simplify
%   version detection

    verInfo = struct();
    verInfo.infoFound = false;

    %TODO: Make sure this works for the case where this property doesn't exist?
    try
        verInfo.SI_MAJOR = fileHeader.SI.VERSION_MAJOR;
        verInfo.SI_MINOR = fileHeader.SI.VERSION_MINOR;
        verInfo.TIFF_FORMAT_VERSION = fileHeader.SI.TIFF_FORMAT_VERSION;
        verInfo.infoFound = true;
    catch
        most.idioms.dispError('Cannot find SI and/or Tiff version properties in Tiff header.\n');
        return;
    end

    %% Determine if the scanner is linear or resonant
    try
        verInfo.ImagingSystemType = fileHeader.SI.hScan2D.scannerType;
    catch
        verInfo.ImagingSystemType = fileHeader.SI.imagingSystem;
    end
end


%--------------------------------------------------------------------------%
% getSITiffVersionInfo.m                                                   %
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
