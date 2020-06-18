function clFullSubDirs = FindSubDirs_RegExp(strSubdir_RegExp, strDir, isRecursive,nRecurseLevel)
%Find subfolders with a given regular expression pattern in a directory
%
%   Inputs
%       strFn_RegExp: string, regular expression of the names of the subfolders to be found
%       strDir: string, the parent directory of the files
%       isRecursive: bool, search recursively or not
%       nRecurseLevel: int, the number of recurse level
%
%   Outputs
%       clFullSubDirs: cell of strings, the full names of the subfolder found
%                      in the directory
%
%Saintgene 2009

% check inputs
if(nargin<2)
    error('SG:FindSubDirs_RegExp:NotEnoughInputs','You must define entry and directory.');
end
if(nargin<3)
    isRecursive = false;
end

if(nargin<4)
    nRecurseLevel = inf;
end

if(~isfolder(strDir))
    error('SG:FindSubDirs_RegExp:ErrorDir','No such directory found.');
end

d = dir(strDir);

clFullSubDirs = {};
numMatches = 0;

nRecurseLevel = nRecurseLevel-1;
if(nRecurseLevel == 0)
    isRecursive = false;
end

for i=1:length(d)
    a_name = d(i).name;
    a_dir = d(i).isdir;

    if(a_dir && ~isempty(regexp(fullfile(strDir,a_name),strSubdir_RegExp,'start')))
        numMatches = numMatches + 1;
        clFullSubDirs{numMatches} = fullfile(strDir, a_name); %#ok<AGROW>
        % if recursive is required
    elseif(isRecursive && a_dir && ~strcmp(a_name,'.') && ~strcmp(a_name,'..'))
        clFullSubDirs = [clFullSubDirs  FindSubDirs_RegExp(strSubdir_RegExp, fullfile(strDir,a_name), true,nRecurseLevel)]; %#ok<AGROW>
        numMatches = length(clFullSubDirs);
    end
end
