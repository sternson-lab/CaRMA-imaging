function NiftiSeq2TiffStack_v2_UInt16(strDir_NiftiSeq,strImgFn_prefix, idx_S, idx_E, strFn_TiffStack,stTag)

if(nargin < 5)
    strFn_TiffStack = [strImgFn_prefix '_reg.tif'];
end

if(nargin <6)
    stTag.SampleFormat = Tiff.SampleFormat.UInt;
    stTag.Photometric = Tiff.Photometric.MinIsBlack;
    stTag.BitsPerSample = 16;
    stTag.Compression = Tiff.Compression.PackBits;
    stTag.SamplesPerPixel = 1;
    stTag.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
    stTag.Software = 'MATLAB';
end

strDir_TiffStack = fileparts(fileparts(strDir_NiftiSeq));
objTiffStack = Tiff([strDir_TiffStack filesep strFn_TiffStack],'w');

for nImg = idx_S:idx_E
    strNiftiFn = [strDir_NiftiSeq filesep strImgFn_prefix '_' num2str(nImg,'%04d') '_r.nii'];
    imgData = uint16(readnifti(strNiftiFn))';
    stTag.ImageLength = size(imgData,1);
    stTag.ImageWidth = size(imgData,2);
    objTiffStack.setTag(stTag);
    objTiffStack.write(imgData);
    if(nImg<idx_E)
        objTiffStack.writeDirectory();
    end
end
objTiffStack.close();