function writeTiffStack_UInt16(matImg,strFn_Sav,bShowProc)
%Write uint16 matrix to Tiff Image Stack
%
%   Inputs
%       matImg: matrix, image data
%       strFn_Sav: string, the file name of Tiff image stack
%       bShowProc: bool, show write process or not
%
%
%Saintgene 2013

if(nargin<3)
    bShowProc = true;
end

tagstruct.Photometric = Tiff.Photometric.MinIsBlack;
tagstruct.BitsPerSample = 16;
tagstruct.Compression = Tiff.Compression.PackBits;
tagstruct.ImageLength = size(matImg,1);
tagstruct.ImageWidth = size(matImg,2);
tagstruct.SamplesPerPixel = 1;
tagstruct.SampleFormat = Tiff.SampleFormat.UInt;
tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
tagstruct.Software = 'MATLAB';

if(bShowProc)
    disp(['Writting file: ' strFn_Sav]);
end

objTiffStack = Tiff(strFn_Sav,'w8');
nFrameCount = size(matImg,3);
for nFrame = 1:nFrameCount
    try
        objTiffStack.setTag(tagstruct);
        objTiffStack.write(uint16(matImg(:,:,nFrame)));
        if(nFrame<nFrameCount)
            objTiffStack.writeDirectory();
        end
    catch
        objTiffStack.close();
    end
end
objTiffStack.close();