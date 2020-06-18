function strDir_ImgWarp = Cluster_Scripts_Reg_SyN_2p_par(stPaths_G, strDir_ImgSeq, strImgFn_prefix, idx_S, idx_E, idx_Ref, bClusterOE)
% Generate job shell script for nonlinear image registration and submit the job to the computer cluster. 
% The function is compatable with parallel computing toolbox (parfor)
%
%   Inputs:
%       stPaths_G: structure, the global paths for the computing environment
%       strDir_ImgSeq: string, the name of subfolder containing the images to be registered
%       strImgFn_prefix: string, the prefix of the file name of the images to be registered
%       idx_S: int, the index of the first image to be registered
%       idx_E: int, the index of the last image to be registered
%       idx_Ref: int, the index of the frame in the Tiff Stack used as
%                reference image. idx_Ref == 0.
%       bClusterOE: bool, log (true) the output and error from computer cluster or not (false)
%
%   Output:
%       strDir_ImgWarp: string, the name of subfolder containing the all shell scripts and warpped images
%
% Saintgene 2016

if(nargin <7)
    bClusterOE = true; %output and error
end

strDir_ImgWarp = [fileparts(strDir_ImgSeq) filesep 'ImgWarp'];
if(~exist(strDir_ImgWarp,'dir'))
    mkdir(strDir_ImgWarp);
end

if(isempty(idx_Ref))
    strImgFn_Ref = [strDir_ImgSeq filesep strImgFn_prefix  '_0000.tif'];
else
    strImgFn_Ref = [strDir_ImgSeq filesep strImgFn_prefix  '_' num2str(idx_Ref,'%04d') '.tif'];
end

strFn_Msk = [fileparts(fileparts(strDir_ImgSeq)) filesep strImgFn_prefix(1:end-2) 'X.tif'];

strMsk = '';
if(exist(strFn_Msk,'file'))
    strMsk =['-x [' strFn_Msk ',' strFn_Msk '] \\\n'];
end

strANTSCmdFn = [stPaths_G.strDir_ANTS filesep 'bin' filesep 'antsRegistration'];

if(bClusterOE)
    strVerb = '1';
else
    strVerb = '0';
end

for nFrame = idx_S:idx_E
    strImg = [strImgFn_prefix  '_' num2str(nFrame,'%04d')];
    strImgFn = [strDir_ImgSeq filesep strImg '.tif'];
    strImg_Warp_prefix = [strDir_ImgWarp filesep strImg];
    strImgFn_Warp = [strImg_Warp_prefix '_r.nii'];
    strScriptFn = [strImg_Warp_prefix '.sh'];
    
    fid = fopen(strScriptFn,'w');
    
    fprintf(fid,'ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=1\n');
    fprintf(fid,'export ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS\n');
     
    strANTSCmd = [strANTSCmdFn ' --float 1 -v ' strVerb ' -d 2 -r [' strImg_Warp_prefix '0GenericAffine.mat ] \\\n'...
        '-m MI[' strImgFn_Ref  ',' strImgFn ',1,32] \\\n'...
        '-t Affine[0.1] -c [300x300x300,5.e-6,10] -s 2x1x0vox -f 4x2x1 \\\n' ...
        '-m CC[' strImgFn_Ref  ',' strImgFn ',1,4] -t SyN[0.1,3.0,0] -c [60x40x20,1.e-4,3] -s 2x1x0vox -f 4x2x1 \\\n'...
        strMsk '-n Linear -o [' strImg_Warp_prefix ',' strImgFn_Warp ']' ];
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