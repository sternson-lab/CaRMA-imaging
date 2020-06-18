function ImgFileReg_2p_par(stPaths_G, strTiffFn, idx_S, idx_E, idx_Ref, flgMode, bClusterOE, bKeepResults)
% Register images to correct the motion artifacts. The function is
% compatable with parallel computing toolbox (parfor)
%
%   Input arguments:
%       stPaths_G: structure, the global paths for the computing environment
%       strTiffFn: string, the file name of Tiff Stack to be registered
%       idx_S: int, the index of the first frame in the Tiff Stack to be registered
%       idx_E: int, the index of the last frame in the Tiff Stack to be registered
%       idx_Ref: int, the index of the frame in the Tiff Stack used as
%                reference image. idx_Ref == 0, use the average intensity
%                projection of the tiff stack as the reference image.
%       flgMode: int, 1: convert Tiff Stack to image squence; 2: register only; 3 both
%       bClusterOE: bool, log (true) the output and error from computer cluster or not (false)
%       bKeepResults: bool, keep (true) the intermediate results or not (false)
%
% Saintgene 2016

if(nargin <3)
    idx_S = 1;
end

if(nargin <4)
    idx_E = inf;
end

if(nargin <5)
    idx_Ref = 0;
end

if(nargin<6)
    flgMode = 3;
end

if(nargin < 7)
    bClusterOE = true;
end

if(nargin<8)
   bKeepResults = false; 
end

b2Seq = false;
if(flgMode~=2)
    b2Seq = true;
end


disp('Converting Tiff Stack to Image Sequence...');
tic();
[strDir_ImgSeq,strImgFn_prefix,idx_S,idx_E] = TiffStack2ImgSeq_2p(strTiffFn ,idx_S, idx_E,b2Seq);
tElapse = toc();
disp(['Coverted! Elapse Time: ' num2str(tElapse) ' Seconds']);


if(flgMode ~=1)
    
    if(idx_Ref == 0)
        strFn_Ref_Src = [strTiffFn(1:end-4) '_Avg.tif'];
        strFn_Ref_Des = [strDir_ImgSeq filesep strImgFn_prefix  '_0000.tif'];
        if(~exist(strFn_Ref_Des,'file'))
            copyfile(strFn_Ref_Src,strFn_Ref_Des);
        end
    end
    
    nRndCount = 2; %iterate 2 times to generate a sharp reference image
    for nRnd = 1:nRndCount
        disp(['Linear Registration...' num2str(nRnd)]);
        if(nRnd==1)
            idx_Refl = idx_Ref;
        else
            idx_Refl = -1;
        end
        tic();
        strDir_ImgWarp = Cluster_Scripts_Reg_Linear_2p_par(stPaths_G,strDir_ImgSeq,strImgFn_prefix, idx_S,idx_E,idx_Refl, bClusterOE);
        Wait_Cluster_Complete_Task_v2(strImgFn_prefix);
        tElapse = toc();
        disp(['Done! Elapse Time: ' num2str(tElapse) ' Seconds']);
        
        pause(10);
        disp('Writing Linear registrated tiff stack...');
        strImgFn_Reg_Linear = [strImgFn_prefix '_reg_lin.tif'];
        NiftiSeq2TiffStack_2p(strDir_ImgWarp,strImgFn_prefix, idx_S, idx_E,strImgFn_Reg_Linear,true);
        
        strImgFn_Ref_ZProj = [strTiffFn(1:end-4) '_reg_lin_ZProj.tif'];
        strDesFn = [strDir_ImgSeq filesep strImgFn_prefix  '_' num2str(-1,'%04d') '.tif'];
        copyfile(strImgFn_Ref_ZProj,strDesFn);      
        
        disp(['Deformable Registration...' num2str(nRnd)]);
        tic();
        strDir_ImgWarp = Cluster_Scripts_Reg_SyN_2p_par(stPaths_G,strDir_ImgSeq,strImgFn_prefix, idx_S,idx_E,-1, bClusterOE);
        Wait_Cluster_Complete_Task_v2(strImgFn_prefix);
        pause(10);
        tElapse = toc();
        disp(['Done! Elapse Time: ' num2str(tElapse) ' Seconds']);
        
        if(nRnd==nRndCount)
            disp('Writing Final registed tiff stack...');
        end
        NiftiSeq2TiffStack_2p(strDir_ImgWarp,strImgFn_prefix, idx_S, idx_E);
        if(nRnd<nRndCount)
            strImgFn_Ref_ZProj = [strTiffFn(1:end-4) '_reg_ZProj.tif'];
            strDesFn = [strDir_ImgSeq filesep strImgFn_prefix  '_' num2str(-1,'%04d') '.tif'];
            copyfile(strImgFn_Ref_ZProj,strDesFn);
        end
        
    end
    
    if(~bKeepResults)
        disp('Removing computing results...');
        rmdir(fileparts(strDir_ImgSeq),'s');
        disp('done');
    end
    
end
