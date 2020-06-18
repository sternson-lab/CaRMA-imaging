function [clFn_O,vtCounter] = SortFnByCounter(clFn_I,strCounter_RE)
%Sort files by the counter in their file names
%
%   Inputs
%       clFn_I: cell of string, the names of the input files to be
%               sorted
%       strCounter_RE: string, the regular expression of the counter in the
%                      file names. The regular expression must have a grouped
%                      number expression, which is used to sort the images.
%                      For example: strCounter_RE = '_(\d{1,2})_';
%
%   Outputs
%       clFn_O: cell of strings, the names of the sorted files
%       vtCounter: int vector, the sorted counter.
%
%Saintgene 2009

nFileCount = length(clFn_I);
vtCounter = zeros(nFileCount,1);
for nFile = 1:nFileCount
    strFn = clFn_I{nFile};
    strCounter = regexp(strFn,strCounter_RE,'tokens');
    vtCounter(nFile) = str2double(strCounter{1});
end

[vtCounter,Indx] = sort(vtCounter);
clFn_O = clFn_I(Indx);

