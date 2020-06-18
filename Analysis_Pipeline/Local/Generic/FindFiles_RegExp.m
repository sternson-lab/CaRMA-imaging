function clFullPathFiles = FindFiles_RegExp(strFn_RegExp, strDir, isRecursive, nRecurseLevel)
%Find files with a given regular expression pattern within a directory
%
%   Inputs
%       strFn_RegExp: string, regular expression of the names of the files to be found
%       strDir: string, the parent directory of the files
%       isRecursive: bool, search recursively or not
%       nRecurseLevel: int, the number of recurse level
%
%   Outputs
%       clFullPathFiles: cell of strings, the full names of the files found
%                        in the directory
%
%Saintgene 2009

% check inputs
if(nargin<2)
    error('SG:FindFiles_RegExp:NotEnoughInputs','You must define entry and directory.');
end
if(nargin<3)
    isRecursive = false;
end

if(nargin<4)
    nRecurseLevel = inf;
end

if(~isfolder(strDir))
    error('SG:FindFiles_RegExp:ErrorDir','No directory found.');
end

d = dir(strDir);

clFullPathFiles = {};
numMatches = 0;

nRecurseLevel = nRecurseLevel-1;
if(nRecurseLevel == 0)
    isRecursive = false;
end

for i=1:length(d)
    a_name = d(i).name;
    a_dir = d(i).isdir;

    if(~a_dir && ~isempty(regexp(fullfile(strDir,a_name),strFn_RegExp,'start')))
        numMatches = numMatches + 1;
        clFullPathFiles{numMatches} = fullfile(strDir, a_name); %#ok<AGROW>
        % if recursive is required
    elseif(isRecursive && a_dir && ~strcmp(a_name,'.') && ~strcmp(a_name,'..'))
        clFullPathFiles = [clFullPathFiles  FindFiles_RegExp(strFn_RegExp, fullfile(strDir,a_name), true,nRecurseLevel)]; %#ok<AGROW>
        numMatches = length(clFullPathFiles);
    end
end
