function arg = getArg(vararguments, flag, flags, flagIndices)
    [tf,loc] = ismember(flag,flags); %Use this approach, instead of intersect, to allow detection of flag duplication
    if length(find(tf)) > 1
        error(['Flag ''' flag ''' appears more than once, which is not allowed']);
    else %Extract location of specified flag amongst flags
        loc(~loc) = [];
    end
    flagIndex = flagIndices(loc);
    if length(vararguments) <= flagIndex
        arg = [];
        return;
    else
        arg = vararguments{flagIndex+1};
        if ischar(arg) && ismember(lower(arg),flags) %Handle case where argument was omitted, and next argument is a flag
            arg = [];
        end
    end
end

% 
% function arg = getArg(vararguments, flag)
%     % make a temp cell array to search for strings
%     argsch = vararguments;
%     ics = ~cellfun(@ischar,argsch);
%     argsch(ics) = {''};
%     
%     [tf,loc] = ismember(flag,argsch); %Use this approach, instead of intersect, to allow detection of flag duplication


%--------------------------------------------------------------------------%
% getArg.m                                                                 %
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
