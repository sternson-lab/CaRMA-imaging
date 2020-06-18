function ImgData = readTiffStack(strTiffFn,idx_S,idx_E)
%read Tiff Image Stack
%
%   Input arguments
%       strTiffFn: string, file name of Tiff Image Stack
%       idx_S: int, the start frame to be read
%       idx_E: int, the end frame to be read
%
%   Output
%       ImgData: matrix, image data
%
% Saintgene 2013

if(nargin<2)
    idx_S = 1;
end
if(nargin<3)
    idx_E = inf;
end

% warning('off','all');
TifLink = Tiff(strTiffFn, 'r');
dSampFmt = TifLink.getTag('SampleFormat');
BitDepth = TifLink.getTag('BitsPerSample');
SPP = TifLink.getTag('SamplesPerPixel');

if(SPP>1)
    [Height,Width,~]=size(TifLink.read());
else
    [Height,Width]=size(TifLink.read());
end

TifLink.setDirectory(1);
NumberImages = 1;
while ~TifLink.lastDirectory()
    TifLink.nextDirectory();
    NumberImages = NumberImages + 1;
end
TifLink.setDirectory(1);

idx_S = max(1,idx_S);
idx_E = min(idx_E,NumberImages);

switch(BitDepth)
    case 1
        if(dSampFmt == Tiff.SampleFormat.UInt)
            strFormat = 'logical';
        else
            strFormat = 'uint8';
        end
    case 8
        if(dSampFmt == Tiff.SampleFormat.UInt)
            strFormat = 'uint8';
        else
            strFormat = 'int8';
        end
    case 16
         if(dSampFmt == Tiff.SampleFormat.UInt)
            strFormat = 'uint16';
         else
             strFormat = 'int16';
         end
    case 32
        if(dSampFmt == Tiff.SampleFormat.UInt)
            strFormat = 'uint32';
        elseif(dSampFmt == Tiff.SampleFormat.Int)
            strFormat = 'int32';
        else
            strFormat = 'single';
        end
    otherwise
        strFormat = 'double';
end

if(SPP>1)
    ImgData = zeros(Height,Width,SPP,idx_E-idx_S+1,strFormat);
    for nImg=idx_S:idx_E
        if(nImg==idx_S)
            TifLink.setDirectory(nImg);
        else
            TifLink.nextDirectory();
        end
        ImgData(:,:,:,nImg-idx_S+1)=TifLink.read();
    end
else
    ImgData = zeros(Height,Width,idx_E-idx_S+1,strFormat);
    for nImg=idx_S:idx_E
        if(nImg==idx_S)
            TifLink.setDirectory(nImg);
        else
            TifLink.nextDirectory();
        end
        ImgData(:,:,nImg-idx_S+1)=TifLink.read();
    end
end
TifLink.close();
% warning('on','all');