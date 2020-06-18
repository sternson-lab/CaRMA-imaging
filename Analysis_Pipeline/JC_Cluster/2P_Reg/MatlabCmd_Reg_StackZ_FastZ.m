stPaths_G = Init_Cluster_GlobalPaths();

clDirs = {
    '/groups/sternson/sternsonlab/from_tier2/XSJ/PVH_Analysis/CaRMA_Wiki/Example_Data/ANM378231/ExVivo_InVivo_Reg/Reg/ZStack_FastZ_Reg';
    };
    
clFns_RE ={
    'ANM378231_\S*_Avg(8P)|(_2X)\.tif$';
    };

clRef_sfx = {
    '_Avg8P.tif';
    };


nDirCount = length(clDirs);

clTiffFns = cell(1,nDirCount);

for nDir =1:nDirCount
    strRegExp = clFns_RE{nDir};
    clTiffs = FindFiles_RegExp(strRegExp, clDirs{nDir}, false)';
    clTiffFns(nDir) = {clTiffs};
end    

%%

for nDir =1:nDirCount
    clTiffs = clTiffFns{nDir};
    nFileCount = length(clTiffs);
    idxStack = find(endsWith(clTiffs,clRef_sfx{nDir}));
    strImgFn_Stack = clTiffs{idxStack};
    vtFileIdx = setxor(1:nFileCount,idxStack);
    for nFile = vtFileIdx
        strImgFn_Fast = clTiffs{nFile};
        Cluster_Scripts_Reg_StackZ_FastZ(stPaths_G,strImgFn_Stack, strImgFn_Fast, true);
    end
end