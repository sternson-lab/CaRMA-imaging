function matResp = ExtractVOlResp_SubRing_v3(strDir_VolResp,strDir_ROIs,strFn_Resp_RE,vtRing,bROIs_Sav)
%Extract calcium signals of the concatenated registered volumetric images
%with given ROIs in each directory
%
%   Inputs
%       strDir_VolResp: string, the name of the subfolder containing the
%                       the concatenated registered volumetric images
%       strDir_ROIs: string, the name of the subfolder containing the given
%                    ROIs
%       strFn_RgExp_Resp: string, regular expression of the names of the 
%                         combined registered images of individual imaging
%                         planes. The regular expression must have a
%                         grouped number expression, which is used to sort
%                         the images. For example: 
%                         strFn_Resp_RE = '_S(\d{1,2})_C1.tif';
%       vtRing: 2-element vector, the two radii to define the ring shape of
%               background mask
%       bROIs_Sav: boolen, save (true) the exclusive ROIs and ring shape
%                  backgrounds or not (false). When bROIs_Sav is true, 
%                  individual ROIs and their corresponding background masks
%                  will be saved in ROIs_Ex_v3 subfolder. 
%
%   Output
%       matResp: matrix, each row represents the response of one neuron,
%                each column represents the response of all neurons at each
%                timepoint. The reponse of one neuron at one time point is 
%                the average intensity in ROI mask - average intensity in 
%                background mask
%
%Saintgene 2016

if(nargin <2)
    strDir_ROIs = [strDir_VolResp '\ROIs_Reg'];
end

if(nargin < 3)
    strFn_Resp_RE = '_S(\d)_C\d\.tif$';
end

if(nargin <4 || isempty(vtRing))
    vtRing = [2 20];
end

if(nargin < 5)
    bROIs_Sav = true;
end

strExp_Img = 'N(\d{1,3})_reg.tif$';

clFns = FindFiles_RegExp(strExp_Img, strDir_ROIs, false)';
[clFns,vtC]= SortFnByCounter(clFns,strExp_Img);
nRC = length(clFns);

matROI1 = readTiffStack(clFns{1});

matROIs_f = false(size(matROI1,1),size(matROI1,2),size(matROI1,3),nRC);%fixed
matROIs_r = false(size(matROI1,1),size(matROI1,2),size(matROI1,3),nRC);%ring

SE_i = strel('disk',vtRing(1),8);
SE_n = strel('disk',2,8);

for nR=1:nRC
    iC = vtC(nR);
    strFn = clFns{nR};
    imgData = readTiffStack(strFn);
    bwData = imfill(imgData == iC,'holes');
    matROIs_f(:,:,:,nR)=imclose(bwData,SE_n);
    
    lgF = any(bwData,[1 2]);
    bwData_i = bwData(:,:,lgF);
    bwData_o = false(size(bwData_i));
    [nYC,nXC,nZC]=size(bwData_o);
    [XX,YY] = meshgrid(1:nXC,1:nYC);
    for nZ = 1:nZC
        bwData_z = bwData_i(:,:,nZ);
        cx = mean(XX(bwData_z));
        cy = mean(YY(bwData_z));
        bwData_o(:,:,nZ) = hypot(XX-cx,YY-cy)<=vtRing(2);
    end
    matROIs_r(:,:,lgF,nR) = bwData_o;
end

matROIs_t = imdilate(any(matROIs_f,4),SE_i);
matROIs = false(size(matROI1,1),size(matROI1,2),size(matROI1,3),nRC);

if(bROIs_Sav)
    strDir_ROIs_Sav = [strDir_ROIs '\ROIs_Ex_v3'];
    mkdir(strDir_ROIs_Sav);
end

for nR=1:nRC
    matROIs_r(:,:,:,nR) = matROIs_r(:,:,:,nR)&(~matROIs_t); %%background ring excludes ROIs
    lgR = true(nRC,1);
    lgR(nR) = false;
    matROIs_o = any(matROIs_f(:,:,:,lgR),4);
    matROIs(:,:,:,nR) = matROIs_f(:,:,:,nR)&(~matROIs_o);
    if(bROIs_Sav)
        strFn_Sav = [strDir_ROIs_Sav '\N' num2str(nR) '_Ex.tif'];
        writeTiffStack_UInt16(matROIs(:,:,:,nR),strFn_Sav)
        strFn_Sav = [strDir_ROIs_Sav '\Bkg' num2str(nR) '.tif'];
        writeTiffStack_UInt16(matROIs_r(:,:,:,nR),strFn_Sav)
    end
end

clFns_Resp = FindFiles_RegExp(strFn_Resp_RE, strDir_VolResp, false)';
clFns_Resp = SortFnByCounter(clFns_Resp,strFn_Resp_RE);

nSliceCount = size(matROIs,3);
if(length(clFns_Resp)~=nSliceCount)
    matResp = [];
    warning('ROIs file does not match with Response file!');
else
    clResp = cell(1,nSliceCount);
    for nFile=1:nSliceCount
        strFn_Resp = clFns_Resp{nFile};
        clResp{nFile} = readTiffStack(strFn_Resp);
    end
    
    matResp_All = cat(4,clResp{:});
    clearvars('clResp');
    nFrameCount = size(matResp_All,3);
 %%   
    matResp = zeros(nRC,nFrameCount);
    for nFrame=1:nFrameCount
        matResp_F = squeeze(matResp_All(:,:,nFrame,:));
        for nR = 1:nRC
            stats = regionprops(int8(matROIs(:,:,:,nR)),matResp_F,'MeanIntensity');
            stats_r = regionprops(int8(matROIs_r(:,:,:,nR)),matResp_F,'MeanIntensity');
            if(~isempty(stats))
                matResp(nR,nFrame) = stats.MeanIntensity-stats_r.MeanIntensity;
            end
        end
    end
    
    save([fileparts(strFn_Resp) filesep 'Resp_SubRing_v3.mat'],'matResp');
    disp('done');
end
