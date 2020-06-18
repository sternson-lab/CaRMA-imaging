function CopyRefImg(strRefFn, strDesDir, iRefNumb, nRecurseLevel)
% Copy reference image to a destination folder
%
%   Input:
%       strRefFn: string, the file name of reference image
%       strDesDir: string, the name of destination folder
%       iRefNumb: int, the index of reference image in the destination folder
%       nRecurseLevel: int, the number of recurse level to search ImgSeq subfolders in the destination folder
%
% Saintgene 2014

if(nargin <3)
    iRefNumb = 0;
end

if(nargin<4)
    nRecurseLevel = 3;
end

clDesSubs = FindSubDirs_RegExp('ImgSeq', strDesDir, true, nRecurseLevel)';
strRefFn_PP = [strRefFn(1:end-4) '_PP.tif']; %for inscopix images

for nSub = 1:length(clDesSubs)
    strDesSub = clDesSubs{nSub};
    [~,strPrefix]=fileparts(fileparts(strDesSub));
    strDesFn = [ strDesSub filesep strPrefix '_' num2str(iRefNumb,'%04d') '.tif'];
    disp(['Copy file: ' strRefFn ' to ' strDesFn]);
    copyfile(strRefFn,strDesFn,'f');
    if(exist(strRefFn_PP,'file')) %for inscopix images
        strDesFn_PP = [strDesFn(1:end-4) '_PP.tif'];
        disp(['Copy file: ' strRefFn_PP ' to ' strDesFn_PP]);
        copyfile(strRefFn_PP,strDesFn_PP,'f');
    end
end