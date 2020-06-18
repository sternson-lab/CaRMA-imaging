function stPaths_G = Init_Cluster_GlobalPaths()
% set the global paths for the computing environment
%
%   Output
%       stPaths_G: structure of global paths
%           .strName_User: string, user name in the cluster server
%           .strDir_User: string, the user home directory in the cluster server
%           .strDir_Matlab: string, the directory of Matlab compiled executable files
%           .strDir_ANTs: string, the directory of ANTs executable files
%           .strIJPath: string, the full path name of ij.jar file
%           .strMCR_Cache_root, string, the temporary MCR cache
%
% Saintgene 2016

stPaths_G.strName_User = 'xus';

stPaths_G.strDir_User = ['/groups/sternson/home/' stPaths_G.strName_User];

stPaths_G.strDir_Matlab = [stPaths_G.strDir_User '/scripts_s/Matlab'];

stPaths_G.strDir_ANTS = [stPaths_G.strDir_User '/scripts_s/ANTs2_2'];

stPaths_G.strIJPath = [stPaths_G.strDir_Matlab filesep 'ij.jar'];

stPaths_G.strMCR_Cache_root =['/scratch/' stPaths_G.strName_User '/mcr_cache_root.$LSB_BATCH_JID\n'];