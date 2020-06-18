% Split the volumetric images acquired by Scanimage into images of individual
% imaging planes in batch process mode
%
% Saintgene 2016
%%
%set the parameters in this cell
initDir_CaRMA_Wiki();
global strDir_CaRMA_Wiki

%the directory containing ScanImage files to be splitted
strDir = [strDir_CaRMA_Wiki '\Example Data\ANM378231\Fear_Imaging_Exp\2P Imaging'];

%regular expression of the file name of ScanImage files to be splitted
strImg_RE = '\d{5}.tif$';

%regular expression of the file name of the splitted image files to be combined
strFn_RE = '_S(\d{1,2})_C1.tif$';

%the number of columns in the combined images
nColCount = 4;

%%
%batch-process for all image files
strFn_Exp_Avg = [strFn_RE(1:end-5) '_Avg.tif$'];
clFns = FindFiles_RegExp(strImg_RE, strDir, false)';
nFileCount = length(clFns);
for nFile = 1:nFileCount
    strFn = clFns{nFile};
    disp(['Processing file: ' strFn]);
    
    %split the volumetric images into images of individual imaging planes.
    %These splitted images are in a new subfolder.
    strDir_Sub = SplitImages_SI_FastZ(strFn);
    
    %combine the splitted images into a big image so that it can be easily
    %examined in ImageJ
    CombImgs_From_Sub(strDir_Sub,strFn_RE,nColCount);
    
    %combine the average intensity projection image of the splitted images
    %into a big image so that it can be easily examined in ImageJ
    CombImgs_From_Sub(strDir_Sub,strFn_Exp_Avg,nColCount);
end
