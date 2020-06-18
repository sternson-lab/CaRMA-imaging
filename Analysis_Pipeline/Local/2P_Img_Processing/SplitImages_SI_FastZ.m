function [strDir_Sav, imgInfo] = SplitImages_SI_FastZ(strFn, bDiff)
%split the volumetric images into images of individual imaging planes.
%These splitted images are in a new subfolder.
%it also saved the meta information of volumetric images and average
%intensity projection images of the splitted images
%
%   Inputs
%       strFn: string, name of the file to be splitted
%       bDiff: bool, when the number of imaging channel==2, use the
%       difference between signals from 2 channels or not
%
%   Outputs
%       strDir_Sav: string, the name of the subfolder containing the
%       splitted images
%       imgInfo: structure, meta info of the volumetric image
%
%Saintgene 2015

if(nargin==1)
    bDiff = false;
end

[Header,Aout,imgInfo] = openSITif(strFn);
Aout = uint16(Aout);
imgInfo.bFastZ = Header.SI.hFastZ.enable;

[strDir,strFn_p]=fileparts(strFn);
strDir_Sav = [strDir filesep strFn_p '_S'];
mkdir(strDir_Sav);

bZStack = imgInfo.numFrames>1;

if(bZStack)
    matImgStack = zeros(imgInfo.numLines,imgInfo.numPixels,imgInfo.numSlices,imgInfo.numChans,'uint16');
end

for nSlice = 1:imgInfo.numSlices
    for nCh =1:imgInfo.numChans
        matImgCh = squeeze(Aout(:,:,nCh,:,nSlice,:));
        strFn_Sav = [strDir_Sav filesep strFn_p '_S' num2str(nSlice) '_C' num2str(nCh) '.tif'];
        writeTiffStack_UInt16(matImgCh,strFn_Sav);
        matImgCh_Avg = mean(matImgCh,3);
        strFn_Avg_Sav = [strFn_Sav(1:end-4) '_Avg.tif'];
        writeTiffStack_UInt16(matImgCh_Avg,strFn_Avg_Sav);
        if(bZStack)
            matImgStack(:,:,nSlice,nCh) = matImgCh_Avg;
        end
    end
    
    if(imgInfo.numChans==2 && bDiff)
        matImgCh = imsubtract(squeeze(Aout(:,:,2,:,nSlice,:)),squeeze(Aout(:,:,1,:,nSlice,:)));
        strFn_Sav = [strDir_Sav filesep strFn_p '_S' num2str(nSlice) '_D.tif'];
        writeTiffStack_UInt16(matImgCh,strFn_Sav);
    end
end

strFn_Header = [strFn(1:end-4) '_Header.mat'];
save(strFn_Header,'Header');

if(bZStack)
    for nCh =1:imgInfo.numChans
        strFn_ZStack_Sav = [strFn(1:end-4) '_C' num2str(nCh) '_ZStack.tif'];
        writeTiffStack_UInt16(squeeze(matImgStack(:,:,:,nCh)),strFn_ZStack_Sav);
    end
end
