clDirs = {
'/groups/sternson/sternsonlab/from_tier2/XSJ/PVH_Analysis/CaRMA_Wiki/Example_Data/ANM378231/ExVivo_InVivo_Reg/Reg/ZStack_FastZ_Reg/2p_ROIs';
};

nDC = length(clDirs);

for nD=1:nDC
    strDir_ROIs = clDirs{nD};
    strDir_P = fileparts(strDir_ROIs);
    clFn = FindFiles_RegExp('_reg_Avg.tif', strDir_P, false)';
    strFn_Ref= clFn{1};
    clDns = FindSubDirs_RegExp('_Avg_2X/ImgSeq', strDir_P,true,2)';
    strDir_Trans = clDns{1};
    bSave = false;
    disp('Processing file:');
    disp(strDir_ROIs);
    disp(strFn_Ref);
    disp(strDir_Trans);
    MatlabCmd_ApplyTrans_RegROIs_Inverse_AllNeurons(strDir_ROIs,strFn_Ref,strDir_Trans,bSave);
end
