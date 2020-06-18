function ReconstructImage3D(strFn_Img,strFn_Hdr,vtCtm,strFn_FOVInfo,stOptions)
%Reconstruct the 3D 2p image volume by correcting the FOV curvature,
%remapping the objective-sample and objective-magnification relationships
%
%   Inputs
%       strFn_Img: string, the file name of image zstack to be corrected
%       strFn_Hdr: string, the file name of the meta information of the
%                  image zstack, which is from its original ScanImage image
%                  zstack
%       vtCtm: 2-element vector, the center[X,Y] of the the image zstack
%       strFn_FOVInfo: string, the optical properties measured with a 2p
%                      excitable GRID target, details about the optical
%                      variables in the file see FOVs_readme.txt
%       stOptions: structure,options for the reconstruction, following are
%                  its fields. If stOptions = [], it will use default
%                  values
%                  .iSlice_S, int, the first slice in strFn_Img stack used
%                             for the reconstruction. default: 1
%                  .OutRes_XY, double, the X-Y resolution of the corrected
%                              output image zstack, um. default: 0.5
%                  .OutRes_Z, double, the Z resolution of the corrected 
%                             output image zstack, um. default: 2*OutRes_XY
%                  .maxFov_R, double, the max radius of FOV for the
%                             corrected image zstack, um. default: 150
%
% Saintgene 2016

%validate stOptions structure
if(nargin==4||isempty(stOptions))
    stOptions.iSlice_S = 1;
    stOptions.OutRes_XY = 0.5;
    stOptions.OutRes_Z = 2*stOptions.OutRes_XY;
    stOptions.maxFov_R = 150;
end

clFields = {'iSlice_S','OutRes_XY','maxFov_R','OutRes_Z'};
vtDefaults = [1, 0.5, 150];
nFldN = length(clFields);

for nFld=1:nFldN
    if(~isfield(stOptions,clFields{nFld}))
        if(nFld<nFldN)
            stOptions.(clFields{nFld}) = vtDefaults(nFld);
        else
            stOptions.(clFields{nFld}) = 2*stOptions.OutRes_XY;
        end
    end
end

iSlice_S = stOptions.iSlice_S;
OutRes_XY = stOptions.OutRes_XY;
OutRes_Z = stOptions.OutRes_Z;
maxFov_R = stOptions.maxFov_R;

[matImgData,vtZs] = GetImgDataInfo(strFn_Img,strFn_Hdr);
load(strFn_FOVInfo,'clFits','clFOVs','matCt_Md','vtPosZ','GRID_SPACE');
vtZs=round(abs(vtZs));
vtZs_t = vtZs(iSlice_S:end);
matImgData_t = double(matImgData(:,:,iSlice_S:end));
[nHeight,nWidth,nSliceCount] = size(matImgData_t);
%%
nFitCount = size(clFits,1);
vtfParas_P = zeros(nFitCount,2);%[a,z0];
for nFit=1:nFitCount
    vtfParas_P(nFit,:) = [clFits{nFit,1}.a clFits{nFit,1}.z0];
end
%%
hFigs = gobjects(2,1);
hFigs(1) = figure('Name','Optical-Prop','Position',[300,200,600 900]);
subplot(3,1,1);
plot(vtPosZ,vtfParas_P(:,1),'r.');
box('off');
xlabel('obj-pos (um)');
ylabel('a value');
subplot(3,1,2);
plot(vtfParas_P(:,2),vtfParas_P(:,1),'b.');
box('off');
xlabel('samp-pos (um)');
ylabel('a value');
subplot(3,1,3);
plot(vtPosZ,vtfParas_P(:,2),'b.');
[xData, yData] = prepareCurveData( vtPosZ, vtfParas_P(:,2));
ft = fittype( 'a/(x-b)+c', 'independent', 'x', 'dependent', 'y' );
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Display = 'Off';
opts.Lower = [0 -Inf -Inf];
opts.StartPoint = [2e5 0 0];
% Fit model to data.
[fPos, gof] = fit( xData, yData, ft, opts );
x=xData(1):0.5:xData(end);
y=fPos(x);
hold on;
plot(x,y,'r');
text(500,300,['y=' num2str(fPos.a) '/(x-(' num2str(fPos.b) '))+(' num2str(fPos.c) ')']);
text(500,260,['gof = ' num2str(gof.adjrsquare)]);
box('off');
xlabel('obj-pos (um)');
ylabel('samp-pos (um)');

%%
vta = interp1(vtPosZ,vtfParas_P(:,1),vtZs_t,'linear','extrap');
vtz0 = fPos(vtZs_t);
ft = fittype( 'a*(x^2+y^2)+z0', 'independent', {'x', 'y'}, 'dependent', 'z' );
clFits_i = cell(nSliceCount,1);
for nSlice=1:nSliceCount
    clFits_i(nSlice) = {sfit(ft,vta(nSlice),vtz0(nSlice))};
end
%% cross slice line: a1*x^2+b1=a2*x^2+b2  => x^2=(b2-b1)/(a1-a2)
matDelta_a = repmat(vta,[1 nSliceCount])-repmat(vta',[nSliceCount,1]);
matDelta_z = repmat(vtz0,[1 nSliceCount])-repmat(vtz0',[nSliceCount,1]);
sR = -matDelta_z./matDelta_a;
%%
nPosCount = length(vtPosZ);
vtFOVR_P = zeros(nPosCount,1);
for nPos=1:nPosCount
    vtFOVR_P(nPos) = max(abs(clFOVs{nPos,1}(:,1)));
end
%%
ft = fittype( 'poly1' );
opts = fitoptions( 'Method', 'LinearLeastSquares' );
opts.Robust = 'Bisquare';

[fCx_Md, gof_Cx_Md] = fit( vtPosZ, matCt_Md(:,1), ft, opts );
[fCy_Md, gof_Cy_Md] = fit( vtPosZ, matCt_Md(:,2), ft, opts );
[fFov_r, gof_Fov_d] = fit( vtPosZ, vtFOVR_P, ft, opts);
%%
hFigs(2) = figure('Name','Magnification','Position',[300 100 500 900]);
fX=vtPosZ(1):0.5:vtPosZ(end);
subplot(2,1,1)
M_Ref_x = fCx_Md(1000);
plot(vtPosZ, matCt_Md(:,1)/M_Ref_x,'r.');
hold on;
plot(fX,fCx_Md(fX)/M_Ref_x,'b');
plot([1000, 300;1000, 1000],[0.4 1;1 1],'k:');
box off;
xlabel('obj-pos (um)');
ylabel('relative-mag');
title('X-Mag');
axis tight;

subplot(2,1,2)
M_Ref_y = fCy_Md(1000);
plot(vtPosZ, matCt_Md(:,2)/M_Ref_y,'r.');
hold on;
plot(fX,fCy_Md(fX)/M_Ref_y,'b');
plot([1000, 300;1000, 1000],[0.4 1;1 1],'k:');
box off;
xlabel('obj-pos (um)');
ylabel('relative-mag');
title('Y-Mag');
axis tight
%%
matCt_Md_i =[fCx_Md(vtZs_t) fCy_Md(vtZs_t)];
vtfR = fFov_r(vtZs_t);
[X,Y]=meshgrid(1:nWidth,1:nHeight);
Xp3=zeros(size(X,1),size(X,2),nSliceCount);
Yp3=zeros(size(Xp3));
Zp3=zeros(size(Xp3));
lgUse = true(size(Xp3));
for nSlice=1:nSliceCount
    Xp = (X-vtCtm(1))/matCt_Md_i(nSlice,1)*GRID_SPACE; %physical location X
    Yp = (Y-vtCtm(2))/matCt_Md_i(nSlice,2)*GRID_SPACE; %physical location Y
    Xp3(:,:,nSlice) = Xp;
    Yp3(:,:,nSlice) = Yp;
    Zp3(:,:,nSlice) = clFits_i{nSlice}(Xp,Yp);
    if(nSlice<nSliceCount)
        sRn = sR(nSlice+1:end,nSlice);
        sRn = min(sRn(sRn>0));
        if(~isempty(sRn))
            lgUse(:,:,nSlice) = (Xp.^2+Yp.^2)<0.81*sRn;
        end
    end
end
%%
Xp3_Rg = [-maxFov_R,maxFov_R];
Yp3_Rg = [-maxFov_R,maxFov_R];
Zp3_Rg = [vtz0(1)/2 max(Zp3(:))];

vtX = Xp3_Rg(1):OutRes_XY:Xp3_Rg(2);
vtY = Yp3_Rg(1):OutRes_XY:Yp3_Rg(2);
vtZ = Zp3_Rg(1):OutRes_Z:Zp3_Rg(2);

[Xi,Yi,Zi]=meshgrid(vtX,vtY,vtZ);

F = scatteredInterpolant(Xp3(lgUse),Yp3(lgUse),Zp3(lgUse),matImgData_t(lgUse),'linear','none');
matImg_i = F(Xi,Yi,Zi);
%%
strFn_Sav = [strFn_Img(1:end-4) '_Reconstructed.tif'];
writeTiffStack_UInt16(matImg_i,strFn_Sav);

for nF=1:length(hFigs)
    strFigNm = get(hFigs(nF),'Name');
    savefig(hFigs(nF),[strFn_Img(1:end-4) '_' strFigNm '.fig']);
    close(hFigs(nF));
end