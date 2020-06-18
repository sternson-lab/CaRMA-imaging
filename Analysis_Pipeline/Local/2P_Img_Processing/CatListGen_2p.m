% Generate a concatenation list log file as input of the ImageJ script
% CatExp.ijm
%
% Saintgene 2014
%%
%set parameters
initDir_CaRMA_Wiki();
global strDir_CaRMA_Wiki;

% parent directory containing the images to be concatenated
strDir_Img_P = [strDir_CaRMA_Wiki '\Example_Data\ANM378231\Fear_Imaging_Exp\2P_Imaging'];

% regular expression of the subfolders containing the registered splitted
% images of individual imaging planes
strDir_RE = '_000(\d{2})_S$';

% trials be concatenated
vtCatTrials = 4:5;

% image planes to be contanetated
vtSlices = 1:8;
%%
clDirs_Img = FindSubDirs_RegExp(strDir_RE, strDir_Img_P, true,1)';
[clDirs_Img,vtCounter] = SortFnByCounter(clDirs_Img,strDir_RE);
[vtCatDirs,idxDirs] = intersect(vtCounter,vtCatTrials);

strFn_CatList = [strDir_Img_P filesep 'CatList.log'];

nDirCount = length(idxDirs);

fid = fopen(strFn_CatList,'wt');

for nSlice = vtSlices
    for nDir =1:nDirCount
        idx = idxDirs(nDir);
        strDir = clDirs_Img{idx};
        clFiles = FindFiles_RegExp(['_S' num2str(nSlice) '_C\d_reg.tif$'], strDir, false)';
        strFn_S = clFiles{1};
        fprintf(fid,'%s\n',  strFn_S);
    end
    [strPath,strFn]=fileparts(strFn_S);
    strDir_Sav = [fileparts(strPath) filesep 'Reg_Cat'];
    if(~exist(strDir_Sav,'dir'))
        mkdir(strDir_Sav);
    end
    C = strsplit(strFn,'_');
    strFn_Sav = [C{1} '_' num2str(vtCatTrials(1)) '-' num2str(vtCatTrials(end)) '_' C{3} '_' C{4} '.tif'];
    fprintf(fid,'#sav#:%s\n', [strDir_Sav filesep strFn_Sav]);
end

fclose(fid);