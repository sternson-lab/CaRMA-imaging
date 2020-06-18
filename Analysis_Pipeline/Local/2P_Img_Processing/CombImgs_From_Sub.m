function CombImgs_From_Sub(strDir,strFn_RE,nColCount)
%combine images of individual imaging planes into a big image file so that
%it can be easily examined simultaneously.
%
%   Inputs
%       strDir: string, the name of the subfolder containing the
%               splitted images
%       strFn_RE: string, regular expression of the names of the files
%                 to be combined. The regular expression must have a
%                 grouped number expression, which is used to sort the
%                 images. For example: strFn_RE = '_S(\d{1,2})_C1_reg.tif';
%       nColCount: int, the number of column in the combined image
%
%
%Saintgene 2015

if(nargin==1)
    strFn_RE = '_S(\d{1,2})_C1_reg.tif';
    nColCount = 4;
end

clFns = FindFiles_RegExp(strFn_RE, strDir, false)';
[clFns,vtCount] = SortFnByCounter(clFns,strFn_RE);
nSubCount = length(clFns);

nRowCount = ceil(nSubCount/nColCount);
matImg = readTiffStack(clFns{1});

[imgInfo.numLines, imgInfo.numPixels,imgInfo.numVolumes]=size(matImg);
matImgOut = zeros(imgInfo.numLines*nRowCount,imgInfo.numPixels*nColCount,imgInfo.numVolumes,'uint16');

idxR_S = 0;
for nRow = 1:nRowCount
    idxR = idxR_S+(1:imgInfo.numLines);
    idxC_S = 0;
    for nCol = 1:nColCount
        idxC = idxC_S+(1:imgInfo.numPixels);
        nSlice = (nRow-1)*nColCount+nCol;
        if(nSlice ~=1 && nSlice <= nSubCount)
            matImg = readTiffStack(clFns{nSlice});
        end
        matImgOut(idxR,idxC,:) = matImg;
        idxC_S = idxC_S+imgInfo.numPixels;
    end
    idxR_S = idxR_S + imgInfo.numLines;
end

strDir_Sav = fileparts(strDir);
[~,strFn] = fileparts(clFns{1});
strFn = strrep(strFn,['_S' num2str(vtCount(1))],'_Comb');
strFn_Sav = [strDir_Sav filesep strFn '.tif'];
writeTiffStack_UInt16(matImgOut,strFn_Sav);

