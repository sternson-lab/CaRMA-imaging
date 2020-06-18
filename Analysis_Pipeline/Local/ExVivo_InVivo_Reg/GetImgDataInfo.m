function [matImgData,vtZs] = GetImgDataInfo(strFn_Img,strFn_Hdr)
%Read data and meta info of a zstack image for volumetric reconstruction
%
%   Input arguments
%       strFn_Img: string, name of the image zstack
%       strFn_Hdr: string, name of the .mat file of original ScanImage meta
%                  info (header returned by opentif function) about the
%                  image zstack
%
%   Output
%       matImgData: MXNXF matrix, data of image zstack of size MXN, F
%                   frames.
%       vtZs: vector, the z positions of individual images in the zstack.
%                     the position is relative to the reference zero plane.
%
%Saintgene 2016

matImg = readTiffStack(strFn_Img);
matImgData = squeeze(matImg);

load(strFn_Hdr,'Header');
hSM = Header.SI.hStackManager;
if(Header.SI.hStackManager.slowStackWithFastZ)
    vtZs = linspace(hSM.stackZStartPos,hSM.stackZEndPos,length(hSM.zs));
    vtZs = Header.SI.hMotors.motorPosition(3) + vtZs;
else
    vtZs = hSM.stackZStartPos + hSM.zs;
end
vtZs=vtZs';