function NiftiSeq2TiffStack_2p(strDir_NiftiSeq, strImgFn_prefix, idx_S, idx_E, strFn_TiffStack, bZProj, stTag)
% Convert Nifti image sequence to Tiff stack
%
%   Inputs:
%       strDir_NiftiSeq: string, the name of subfolder containing the Nifti image sequence to be converted
%       strImgFn_prefix: string, the prefix of the file name of the images to be converted
%       idx_S: int, the index of the first image to be converted
%       idx_E: int, the index of the last image to be converted
%       strFn_TiffStack: string, the file name of converted Tiff Stack
%       bZProj: bool, generate (true) average intensity projection image or not (false)
%       stTag: structure, image tag for the converted Tiff Stack
%
% Saintgene 2016

if(nargin < 5||isempty(strFn_TiffStack))
    strFn_TiffStack = [strImgFn_prefix '_reg.tif'];
end

if(nargin<6)
    bZProj = true;
end

if(nargin <7||isempty(stTag))
    stTag.Photometric = Tiff.Photometric.MinIsBlack;
    stTag.BitsPerSample = 16;
    stTag.Compression = Tiff.Compression.PackBits;
    stTag.SamplesPerPixel = 1;
    stTag.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
    stTag.SampleFormat = Tiff.SampleFormat.UInt;
    stTag.Software = 'MATLAB';
end

strDir_TiffStack = fileparts(fileparts(strDir_NiftiSeq));
objTiffStack = Tiff([strDir_TiffStack filesep strFn_TiffStack],'w8');

for nImg = idx_S:idx_E
    strNiftiFn = [strDir_NiftiSeq filesep strImgFn_prefix '_' num2str(nImg,'%04d') '_r.nii'];
    %disp(['Processing file: ' strNiftiFn]);
    imgData = uint16(readnifti(strNiftiFn))';
    if(nImg==idx_S)
        stTag.ImageLength = size(imgData,1);
        stTag.ImageWidth = size(imgData,2);
    end
    objTiffStack.setTag(stTag);
    objTiffStack.write(imgData);
    if(nImg<idx_E)
        objTiffStack.writeDirectory();
    end
    if(bZProj)
        if(nImg==idx_S)
           imgData_Z = double(imgData); 
        else
           imgData_Z = imgData_Z+double(imgData);
        end
        
        if(nImg==idx_E)
            imgData_Z = imgData_Z/(idx_E-idx_S+1);
            strFn_TiffStack_Sav =[strDir_TiffStack filesep strFn_TiffStack(1:end-4) '_ZProj.tif'];
            writeTiffStack_UInt16(imgData_Z,strFn_TiffStack_Sav);
        end
    end
end
objTiffStack.close();