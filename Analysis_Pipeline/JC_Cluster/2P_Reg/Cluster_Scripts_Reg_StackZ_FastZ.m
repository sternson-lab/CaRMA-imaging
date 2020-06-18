function Cluster_Scripts_Reg_StackZ_FastZ(stPaths_G, strImgFn_Stack, strImgFn_Fast, bClusterOE)

if(nargin <4)
    bClusterOE = true; %output and error
end

[strDir_ImgSeq_S,strImgFn_prefix_S,idx_S_S,idx_E_S]=TiffStack2ImgSeq_2p(strImgFn_Stack);
[strDir_ImgSeq_F,strImgFn_prefix_F,idx_S_F,idx_E_F]=TiffStack2ImgSeq_2p(strImgFn_Fast);

if(idx_E_S~=idx_E_F||idx_S_S~=idx_S_F)
    warning('The slice number of two Images do not match');
    return;
end

strANTSCmdFn = [stPaths_G.strDir_ANTS filesep 'bin' filesep 'antsRegistration'];

if(bClusterOE)
    strVerb = '1';
else
    strVerb = '0';
end

strDir_ImgWarp = strDir_ImgSeq_F;

for nSlice = idx_S_S:idx_E_S
    strImgFn_Ref = [strDir_ImgSeq_S filesep strImgFn_prefix_S  '_' num2str(nSlice,'%04d') '.tif'];
    strImg = [strImgFn_prefix_F  '_' num2str(nSlice,'%04d')];
    strImgFn = [strDir_ImgSeq_F filesep strImg '.tif'];
    strImg_Warp_prefix = [strDir_ImgWarp filesep strImg];
    strImgFn_Warp = [strImg_Warp_prefix '_r.nii'];
    strScriptFn = [strImg_Warp_prefix '.sh'];
    
    fid = fopen(strScriptFn,'w');
    
    fprintf(fid,'ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=1\n');
    fprintf(fid,'export ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS\n');
     
    strANTSCmd = [strANTSCmdFn ' --float 1 -v ' strVerb ' -d 2 -r [' strImgFn_Ref ',' strImgFn ',0] \\\n'...
        '-m MI[' strImgFn_Ref  ',' strImgFn ',1,32] \\\n'...
        '-t Translation[0.1] -c [1000x10000x10000x10000,5.e-6,10] -s 3x2x1x0vox -f 8x4x2x1 \\\n' ...
        '-m MI[' strImgFn_Ref  ',' strImgFn ',1,32] \\\n'...
        '-t Affine[0.1] -c [10000x10000x10000x10000,5.e-6,10] -s 3x2x1x0vox -f 8x4x2x1 \\\n' ...
        '-m CC[' strImgFn_Ref  ',' strImgFn ',1,2] -t SyN[0.1,3.0,0] -c [90x60x30,1.e-4,3] -s 2x1x0vox -f 4x2x1 \\\n'...
        '-n Linear -o [' strImg_Warp_prefix ',' strImgFn_Warp ']' ];
    fprintf(fid, [FilesepRep(strANTSCmd) '\n']);
    
    fclose(fid);
    strClusterCmd =['chmod 755 ' strScriptFn];
    system(strClusterCmd);
    if(bClusterOE)
        strFn_O = [strDir_ImgWarp '/' strImg '.o'];
        strFn_E = [strDir_ImgWarp '/' strImg '.e'];
    else
        strFn_O = '/dev/null';
        strFn_E = '/dev/null';
    end
    strClusterCmd = ['bsub -n 1 -R"affinity[core(1)]" -J ' strImg ' -o ' strFn_O ' -e ' strFn_E ' ' strScriptFn];
    system(strClusterCmd);
end

Wait_Cluster_Complete_Task_v2(strImgFn_prefix_F);
pause(2);
NiftiSeq2TiffStack_v2_UInt16(strDir_ImgWarp,strImgFn_prefix_F, idx_S_F, idx_E_F);