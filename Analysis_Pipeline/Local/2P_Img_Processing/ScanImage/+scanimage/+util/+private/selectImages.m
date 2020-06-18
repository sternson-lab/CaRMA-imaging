function selection = selectImages(vararguments,selectionFlags, numItems, flags, flagIndices)
    if any(ismember(selectionFlags,flags))
        selection = scanimage.util.private.getArg(vararguments,selectionFlags, flags, flagIndices);
        %Handle 'inf' specifier in slice array
        if find(isinf(selection))
            selection(isinf(selection)) = [];
            if max(selection) < numItems
                selection = [selection (max(selection)+1):numItems];
            end
        end
        if max(selection) > numItems
            error('Frame, slice or volume values specified are not found in file');
        end
    else
        selection = 1:numItems;
    end
end


%--------------------------------------------------------------------------%
% selectImages.m                                                           %
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
