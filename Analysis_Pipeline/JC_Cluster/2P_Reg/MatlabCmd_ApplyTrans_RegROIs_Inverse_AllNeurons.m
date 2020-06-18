function MatlabCmd_ApplyTrans_RegROIs_Inverse_AllNeurons(strDir_ROIs,strFn_Ref,strDir_Trans,bSave)
if(nargin == 0)
    strDir_ROIs = LP('Z:\Imaging\2P345\20170826\ANM372320\ZStacks\Stack_FastZ_Reg\2p_2X_ROIs\16bit');
    strFn_Ref = LP('Z:\Imaging\2P345\20170826\ANM372320\ZStacks\Stack_FastZ_Reg\ANM372320_00004_Stack_C1_reg_Avg.tif');
    strDir_Trans = LP('Z:\Imaging\2P345\20170826\ANM372320\ZStacks\Stack_FastZ_Reg\ANM372320_00004_Stack_C1_reg_Avg_2X\ImgSeq');
    bSave = false;
end

strAffine_Exp = '00(\d{2})0GenericAffine\.mat';
strWarp_Exp = '00(\d{2})1InverseWarp\.nii\.gz';
strFn_Exp = '00(\d{2})\.tif';

strFn_Img_Rex ='N(\d{1,3})\.tif$';
clFns_Img = FindFiles_RegExp(strFn_Img_Rex, strDir_ROIs, false)';
clFns_Img= SortFnByCounter(clFns_Img,strFn_Img_Rex);

strDir_RefSeq=TiffStack2ImgSeq_2p(strFn_Ref);
%%
parfor nFile_I =1:length(clFns_Img)
    strFn_Img = clFns_Img{nFile_I};
    disp(['Processing File: ' strFn_Img]);
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
        clFns_TMatrix{1} = [stPaths_G.strDir_Matlab filesep '200_2D.txt'];
        clFns_TMatrix{2} = clFns_Warp{nFile};
        clFns_TMatrix{3} = ['[' clFns_Affine{nFile} ', 1]'];
        %clFns_TMatrix{1} = [stPaths_G.strDir_Matlab filesep '200_2D.txt'];
        Cluster_Scripts_ApplyTrans_2d_Labels(stPaths_G,strFnImg, strFnRef, clFns_TMatrix, 1,true);
    end
    
    Wait_Cluster_Complete_Task_v2(strFnImg_Prefix);
    pause(2);
    NiftiSeq2TiffStack_v2_UInt16(strDir_ImgSeq,strFnImg_Prefix, vtCounter(1), vtCounter(end));
    %rmdir(fileparts(strDir_RefSeq),'s');
    
    if(~bSave)
        rmdir(fileparts(strDir_ImgSeq),'s');
    end
end