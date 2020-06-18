function [Header,Aout,imgInfo] = openSITif(strFn,bLegacy)
%Read ScanImage Tiff Stack
%
%   Input arguments
%       strFn: string, name of the file
%       bLegacy: bool, ture: use the legacy opentif function from ScanImage
%                false: use new ScanImageTiffReader class, it's much faster
%                http://scanimage.vidriotechnologies.com/display/SI2016/Open+Tiff
%
%   Outputs (same as scanimage.util.opentif)
%       header: Structure comprising information stored by ScanImage into TIF header
%       Aout: MxNxCxFxSxV array, with images of size MxN for C channels, F frames, S slices, and V volumes. Default type is uint16. 
%       imgInfo: Structure comprising basic information about the structure of the output array Aout
%
%Saintgene 2020


if(nargin==1)
    bLegacy = true;
end

if(bLegacy)
    [Header,Aout,imgInfo] = scanimage.util.opentif(strFn);
else
    reader=ScanImageTiffReader.ScanImageTiffReader(strFn);
    meta=reader.metadata();
    clmeta = strsplit(meta,'\n');
    nLC = length(clmeta);
    for nL=1:nLC
        strmeta = clmeta{nL};
        if(length(strmeta) > 3 && strcmp(strmeta(1:3),'SI.'))
            eval([strmeta ';']);
        end
    end
    Header.SI = SI;
    nCC = length(Header.SI.hChannels.channelSave);
    if(SI.hFastZ.enable)
        nFC = SI.hStackManager.framesPerSlice;
        nSC = SI.hFastZ.numFramesPerVolume;
        nVC = SI.hFastZ.numVolumes;
        nSC_Fb = SI.hFastZ.numDiscardFlybackFrames;
    else
        nFC = SI.hStackManager.framesPerSlice/SI.hScan2D.logAverageFactor;
        nSC = SI.hStackManager.numSlices;
        nVC = 1;
        nSC_Fb = 0;
    end
    
    Aout=permute(reader.data(),[2 1 3]);
    
    [nH,nW,nIC]=size(Aout);
    
    assert(nIC==nCC*nFC*nSC*nVC);
    
    Aout = reshape(Aout,[nH,nW,nCC,nFC,nSC,nVC]);
    
    if(nSC_Fb > 0)
        Aout = Aout(:,:,:,:,1:end-nSC_Fb,:);
        nSC = nSC - nSC_Fb;
    end
    
    imgInfo.numImages = nIC;
    imgInfo.numLines = nH;
    imgInfo.numPixels = nW;
    imgInfo.numChans = nCC;
    imgInfo.numFrames = nFC;
    imgInfo.numSlices = nSC;
    imgInfo.numVolumes = nVC;
    imgInfo.filename = strFn;
    imgInfo.si_ver = Header.SI.VERSION_MAJOR;
end