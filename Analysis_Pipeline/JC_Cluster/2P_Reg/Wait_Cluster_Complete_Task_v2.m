function Wait_Cluster_Complete_Task_v2(strTask)
% Wait for the completement of tasks in computer cluster
%
%   Input
%       strTask: string, the prefix of the names of tasks to be completed
%
% Saintgene 2016

strCmd = ['bjobs -w | grep -c "' strTask '"'];
[~,cmdout] = system(strCmd);

while(str2num(cmdout)~=0) %#ok<ST2NM>
    [~, cmdout] = system(strCmd);
    pause(20);
end