%Reconstruct the 3D 2p image volume by correcting the FOV curvature,
%remapping the objective-sample and objective-magnification relationships
%in batch process mode
%
% Saintgene 2016
%%
%set the parameters in this cell
initDir_CaRMA_Wiki();
global strDir_CaRMA_Wiki

%the file names of image zstacks to be corrected
clFns_Img = {
    [strDir_CaRMA_Wiki '\Example_Data\ANM378231\ExVivo_InVivo_Reg\ZStack_XDays\d6-Fear\ANM378231_d6-Fear.tif'];
    [strDir_CaRMA_Wiki '\Example_Data\ANM378231\ExVivo_InVivo_Reg\ZStack_XDays\d6-Fear\ANM378231_d6-Fear_Full.tif'];
    [strDir_CaRMA_Wiki '\Example_Data\ANM378231\ExVivo_InVivo_Reg\ZStack_XDays\d10-Perfusion\ANM378231_d10-Perfusion.tif'];
    };
    

%the file names of the meta information of the image zstacks, which are from
%its original ScanImage image zstacks
clFns_Hdr = {
    [strDir_CaRMA_Wiki '\Example_Data\ANM378231\ExVivo_InVivo_Reg\ZStack_XDays\d6-Fear\ANM378231_d6-Fear_Header.mat'];
    [strDir_CaRMA_Wiki '\Example_Data\ANM378231\ExVivo_InVivo_Reg\ZStack_XDays\d6-Fear\ANM378231_d6-Fear_Full_Header.mat'];
    [strDir_CaRMA_Wiki '\Example_Data\ANM378231\ExVivo_InVivo_Reg\ZStack_XDays\d10-Perfusion\ANM378231_d10-Perfusion_Header.mat'];
    };

%the positions [X,Y] of the the image zstack centers
clCtms= {
    [276 248];
    [276 248];
    [254 254];
    };

%The optical properties measured with 2p excitable GRID target, details
%about the optical variables in the file see FOVs_readme.txt
strFn_FOVInfo = [strDir_CaRMA_Wiki '\Example_Data\ANM378231\ExVivo_InVivo_Reg\FOVs.mat'];

nFC = length(clFns_Img);

for nF=nFC%1:nFC
    strFn_Img = clFns_Img{nF};
    strFn_Hdr = clFns_Hdr{nF};
    vtCtm = clCtms{nF};
    ReconstructImage3D(strFn_Img,strFn_Hdr,vtCtm,strFn_FOVInfo);
end