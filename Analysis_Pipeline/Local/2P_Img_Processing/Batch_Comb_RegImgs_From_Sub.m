% Combine the registered images of individual imaging planes into a big image file
% so that it can be easily examined simultaneously.
%
% Saintgene 2016
%%
%set the parameters in this cell. these parameters depend on the starage
%organization of your data.
initDir_CaRMA_Wiki();
global strDir_CaRMA_Wiki;

%the parent directory containing registered images to be combined
strImgDir_P = [strDir_CaRMA_Wiki '\Example_Data\ANM378231\Fear_Imaging_Exp'];

%regular expression of the file names of subfolders to be combined
strImgSubDir_RE = '\\2P_Imaging$';

%regular expression of the file names of unregistered combined images
strImg_RE = '_(\d{5})_Comb_C\d\.tif$';

%the number of columns in the combined images
nColCount = 4;
%%
clImgDirs = FindSubDirs_RegExp(strImgSubDir_RE, strImgDir_P, true,2)';
nDC = length(clImgDirs);
for nDir = 1:nDC
    strImgDir = clImgDirs{nDir};
    clANMIDs = regexp(strImgDir,'\\(ANM\d{6})\\','tokens');
    strANMID = clANMIDs{1}{1};
    clFns_Img = FindFiles_RegExp([strANMID strImg_RE], strImgDir, false)';
    
    nFileCount = 1:length(clFns_Img);
    for nFile = nFileCount
        strFn_Img = clFns_Img{nFile};
        [strPath,strFn] = fileparts(strFn_Img);
        clFnParts = strsplit(strFn,'_');
        strCount = clFnParts{2};
        strCh = clFnParts{4};
        strDir_Img = [strImgDir filesep strANMID '_' strCount '_S'];
        strFn_Exp = ['_S(\d{1,2})_' strCh '_reg.tif'];
        CombImgs_From_Sub(strDir_Img, strFn_Exp, nColCount);
    end
    
end