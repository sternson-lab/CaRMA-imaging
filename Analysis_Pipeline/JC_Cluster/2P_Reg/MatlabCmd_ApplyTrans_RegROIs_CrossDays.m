strDir_ROIs = '/groups/sternson/sternsonlab/from_tier2/XSJ/PVH_Analysis/CaRMA_Wiki/Example_Data/ANM378231/ExVivo_InVivo_Reg/Reg/ZStacks_Xdays_Reg/2p_ROIs_Fear';
strFn_Ref = '/groups/sternson/sternsonlab/from_tier2/XSJ/PVH_Analysis/CaRMA_Wiki/Example_Data/ANM378231/ExVivo_InVivo_Reg/Reg/ZStacks_Xdays_Reg/ANM378231_00002_reg_ZProj_ZStack_Correct_Avg8P_Ghrelin.tif';
strDir_Trans = '/groups/sternson/sternsonlab/from_tier2/XSJ/PVH_Analysis/CaRMA_Wiki/Example_Data/ANM378231/ExVivo_InVivo_Reg/Reg/ZStacks_Xdays_Reg/ANM378231_00002_reg_ZProj_ZStack_Correct_Avg8P_Fear/ImgSeq';
bSave = false;

strAffine_Exp = '00(\d{2})0GenericAffine\.mat';
strWarp_Exp = '00(\d{2})1Warp\.nii\.gz';
strFn_Exp = '00(\d{2})\.tif';

clFns_Img = FindFiles_RegExp('N\d{1,3}\.tif', strDir_ROIs, false)';

strDir_RefSeq=TiffStack2ImgSeq_2p(strFn_Ref);

parfor nFile_I =1:length(clFns_Img)
    strFn_Img = clFns_Img{nFile_I};
    [strDir_ImgSeq,strFnImg_Prefix]=TiffStack2ImgSeq_2p(strFn_Img);
    
    clFns_Affine = FindFiles_RegExp(strAffine_Exp, strDir_Trans, false)';
    clFns_Affine = SortFnByCounter(clFns_Affine,strAffine_Exp);
    
    clFns_Warp = FindFiles_RegExp(strWarp_Exp, strDir_Trans, false)';
    clFns_Warp = SortFnByCounter(clFns_Warp,strWarp_Exp);
    
    clFnImg = FindFiles_RegExp(strFn_Exp, strDir_ImgSeq, false)';
    [clFnImg,vtCounter] = SortFnByCounter(clFnImg,strFn_Exp);
    
    clFnRef= FindFiles_RegExp(strFn_Exp, strDir_RefSeq, false)';
    clFnRef = SortFnByCounter(clFnRef,strFn_Exp);
    
    nFileCount = length(clFnImg);
    
    stPaths_G = Init_Cluster_GlobalPaths();
    clFns_TMatrix =[];
    for nFile=1:nFileCount
        strFnImg = clFnImg{nFile};
        strFnRef = clFnRef{nFile};
        clFns_TMatrix{1} = clFns_Warp{nFile};
        clFns_TMatrix{2} = clFns_Affine{nFile};
        Cluster_Scripts_ApplyTrans_2d_Labels(stPaths_G,strFnImg, strFnRef, clFns_TMatrix, 1,true);
    end
    
    Wait_Cluster_Complete_Task_v2(strFnImg_Prefix);
    pause(2);
    NiftiSeq2TiffStack_v2_UInt16(strDir_ImgSeq,strFnImg_Prefix, vtCounter(1), vtCounter(end));
    
    if(~bSave)
        rmdir(fileparts(strDir_ImgSeq),'s');
    end
end