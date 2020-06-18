function  [strDir_ImgSeq,strImgFn_prefix, idx_S_O,idx_E_O] = TiffStack2ImgSeq_2p(strTiffFn, idx_S, idx_E, bAction)
% Convert Tiff Stack to image sequence in a subfloder
%
%   Inputs:
%       strTiffFn: string, the file name of Tiff Stack to be converted
%       idx_S: int, the index of the first frame in the Tiff Stack to be converted
%       idx_E: int, the index of the last frame in the Tiff Stack to be converted
%       bAction: bool, convert (true) or not (false, which only return the related outputs)
%
%   Outputs:
%       strDir_ImgSeq: string, the name of subfolder containing the converted image sequence
%       strImgFn_prefix: string, the prefix of the file name of the converted image sequence
%       idx_S_O: int, the index of the first frame in the Tiff Stack converted
%       idx_E_O: int, the index of the last frame in the Tiff Stack converted
%
% Saintgene 2014

if(nargin <2)
    idx_S = 1;
end
if(nargin <3)
    idx_E = inf;
end
if(nargin <4)
    bAction = true;
end

[strDir, strImgFn_prefix, ext] = fileparts(strTiffFn);
strDir_ImgSeq = [strDir filesep strImgFn_prefix filesep 'ImgSeq'];
if(~exist(strDir_ImgSeq,'dir'))
    mkdir(strDir_ImgSeq);
end

TifLink = Tiff(strTiffFn, 'r');

NumberImages = 1;
while ~TifLink.lastDirectory()
    TifLink.nextDirectory();
    NumberImages = NumberImages + 1;
end

idx_S_O = max(1,idx_S);
idx_E_O = min(idx_E,NumberImages);

strDataCls = '';

if(bAction)
    for nImg=idx_S_O:idx_E_O
        TifLink.setDirectory(nImg);
        ImgData=TifLink.read();
        strImgFileName = [strDir_ImgSeq filesep strImgFn_prefix '_' num2str(nImg,'%04d') ext];
        
        if(nImg == idx_S_O)
            strDataCls = class(ImgData);
        end
        
        switch strDataCls
            case 'int16'
                writeTiffStack_Int16(ImgData,strImgFileName);
            case 'uint16'
                writeTiffStack_UInt16(ImgData,strImgFileName);
            otherwise
                imwrite(ImgData,strImgFileName);
        end
    end
end

TifLink.close();