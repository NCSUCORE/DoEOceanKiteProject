% Copyright 2015, All Rights Reserved
% Code by Steven L. Brunton
% For Paper, "Discovering Governing Equations from Data:
%        Sparse Identification of Nonlinear Dynamical Systems"
% by S. L. Brunton, J. L. Proctor, and J. N. Kutz

clear all, close all, clc
% generate Data
thrSweep =  [1000 2000];
altSweep = 1;
flwSweep = 0.5:.25:1.25;%[.7:.1:2]
widthVec = 50:4:70;
xgrid = meshgrid(thrSweep,widthVec,flwSweep);
[n,m,r] = size(xgrid);
numCase = n*m*r;
powGen = zeros(n,m,r);
pathErr = zeros(n,m,r);
dragRatio = zeros(n,m,r);
Pow = cell(n,m,r);
fpath = ['C:\Users\adabney\Documents\Results\2022-11-21_tetherModelData\'];

% portR = vhcl.turb1.attachPtVec.Value;
% S = vhcl.fluidRefArea.Value;
% turbD = vhcl.turb1.diameter.Value;
% cp = 0.317*pi*(turbD/2)^2/S;
% ct = 0.470*pi*(turbD/2)^2/S;

xTrain = [];
drag = [];
dragValidate = [];
xValidate = [];
dx = [];
dxVal = [];
for i = 1:n
    for j = 1:m
        for k = 1:r
            a = widthVec(i)

            flwSpd = flwSweep(k);                                              %   m/s - Flow speed
            altitude = thrSweep(j)/2;                   %   m/m - cross-current and initial altitude\
            thrLength = thrSweep(j);
            fName = sprintf('V-%.1f_thr-%d_width-%d.mat',flwSpd,thrLength,a);

            if exist([fpath fName])==2
                load([fpath fName])
                portR = vhcl.turb1.attachPtVec.Value;
                S = vhcl.fluidRefArea.Value;
                turbD = vhcl.turb1.diameter.Value;
                cp = 0.317*pi*(turbD/2)^2/S;
                ct = 0.470*pi*(turbD/2)^2/S;
                dt = 1;
                tEnd = tsc.positionVec.Time(end);
                if tEnd<300
                    continue
                end
                lapNum = tsc.lapNumS.max;
                [idx1,idx2] = tsc.getLapIdxs(lapNum-1);
                t = tsc.airTenVecs.Time(idx1):dt:tsc.airTenVecs.Time(idx2-1);
                % Extract Kite States
                pos = squeeze(tsc.positionVec.resample(t).Data);
                vel = (tsc.velCMvec.resample(t).Data);
                eul = squeeze(tsc.eulerAngles.resample(t).Data);
                angVel = squeeze(tsc.angularVel.resample(t).Data);
                vApp = tsc.vhclVapp.resample(t).Data;
                vAppMag = tsc.vhclVapp.resample(t).mag.Data;
                dynP = squeeze(1/2*1000*vAppMag.^2*vhcl.fluidRefArea.Value);
                vFlow = tsc.vhclFlowVecs.resample(t).mag.Data(:,1,:);
                vRat = vAppMag./vFlow;

                tsc.rotMat
                oCk = tsc.OcK.resample(t).Data;
                kCo = tsc.KcO.resample(t).Data;
                % Extract Kite Rotation Matrices
                el = squeeze(tsc.elevationAngle.resample(t).Data);
                cEl = cosd(el);
                sEl = sind(el);
                one = ones(size(el));
                zero = zeros(size(el));
                rEl = reshape([cEl zero -sEl zero one zero sEl zero cEl]',3,3,[]);

                az = squeeze(tsc.azimuthAngle.resample(t).Data);
                cAz = cosd(az);
                sAz = sind(az);
                rAz = reshape([cAz -sAz zero sAz cAz zero zero zero one]',3,3,[]);
                pCo = pagemtimes(rEl,rAz);
                rotMat = pagemtimes(pCo,oCk);

                fThr = tsc.FThrNetBdy.resample(t).Data;
                rotThr = (pagemtimes(rotMat,fThr));
%                 rotThr(1,:,:) = 0;
                thrDrag = pagemtimes(pagetranspose(rotMat),rotThr);
                thrDragMag = sqrt(sum(thrDrag.^2));

                rVelApp = squeeze(pagemtimes(rotMat,vApp));
                rVelAppTan = rVelApp;
                rVelAppTan(1,:) = 0;
                rVelAppTanMag = sqrt(sum(rVelAppTan.^2));

                rVelFlow = squeeze(pagemtimes(rotMat,vApp));
                rVelFlow = rVelApp;
                rVelAppTan(1,:) = 0;
                rVelAppTanMag = sqrt(sum(rVelAppTan.^2));

                rVelAppMag = sqrt(sum(rVelApp.^2));
                vn = [1; 0; 0];

                rVelAppNorm = rVelAppTan./rVelAppTanMag;
                rotThrNorm = rotThr./thrDragMag;
%                 rotThr = squeeze(rotThr);
                %                     sign = [1 0 0]*cross(rVelAppNorm,rotThrNorm);
                %                     sign = sign./abs(sign);

                %                     dragAng = (acos(dot(rotThrNorm,rVelAppNorm)).*sign)';
%                 thrFApp = dot(squeeze(rotThr(2,:,:)),(squeeze(vApp)./squeeze(vAppMag)')).*squeeze(vApp)./squeeze(vAppMag)';
%                 thrFPerp = squeeze(thrDrag)-thrFApp;
                thrFApp = squeeze(rotThr(2,:,:));
                thrFPerp = squeeze(rotThr(3,:,:));
                thrFRad = squeeze(rotThr(1,:,:));
                cdThr = thrFApp./dynP;
                cdThrPerp = thrFPerp./dynP;
                cdThrRad = thrFRad./dynP;
                velAng = squeeze(tsc.velAngle.resample(t).Data);
                b = tsc.basisParams.Data;
%                 b(3) = sin(b(3))*b(5);
                [pos1,~] = lemBoothNew(0,b,[0,0,0]);
                t = t-100;
                pos2 = (pos-pos1)';
                pos2Mag = sqrt(sum(pos2.^2,2));
                xTemp = [pos(3,:)'/100 pos2/100 squeeze(vRat) velAng cos(velAng) sin(velAng) squeeze(vApp./vAppMag)' cos(velAng).^2 sin(velAng).^2 sin(eul') cos(eul') squeeze(vRat) ];% squeeze(lift)' posMag'];% tenMag thrTen(3,:)'./thrTen(1,:)'];

                xTemp = [pos(3,:)'/100 pos2/100 sin(velAng) squeeze(vApp)'];
                if rand>0.25
                    xTrain = [xTrain;xTemp(1:end,:)];
                    drag = [drag; cdThr cdThrPerp cdThrRad];% dragAng];
                else
                    xValidate = [xValidate;xTemp(1:end,:)];
                    dragValidate = [dragValidate;cdThr cdThrPerp cdThrRad];% dragAng];
                end
            end
        end
    end
end

%% pool Data  (i.e., build library of nonlinear time series)
drag = real(drag);
dragValidate = real(dragValidate);
close all
clc
n = 5;
polyorderN = 2;
usesine = 0;
xTest = xTrain./max(xTrain);
ThetaTotAz = poolData(xTest,n,polyorderN,usesine);
thetaNorm = poolData(max(xTrain),n,polyorderN,usesine);
ThetaValAz = poolData(xValidate,n,polyorderN,usesine);
lambda = .1;      % lambda is our sparsification knob.
XiTotAz = sparsifyDynamics(ThetaTotAz,drag(:,1),lambda,1);
XiTotAz = XiTotAz./thetaNorm'
rmseAz = sqrt(sum((dragValidate(:,1) -ThetaValAz*XiTotAz)'.^2)/numel(dragValidate/3))
termsAz = sum(XiTotAz~=0)



n = 5;
polyorderN = 2;
usesine = 0;
% xTest = xTrain./max(xTrain);
ThetaTotEl = poolData(xTest,n,polyorderN,usesine);
thetaNorm = poolData(max(xTrain),n,polyorderN,usesine);
ThetaValEl = poolData(xValidate,n,polyorderN,usesine);
lambda = .1;      % lambda is our sparsification knob.
XiTotEl= sparsifyDynamics(ThetaTotEl,drag(:,2),lambda,1);
XiTotEl = XiTotEl./thetaNorm';
rmseEl = sqrt(sum((dragValidate(:,2) -ThetaValEl*XiTotEl)'.^2)/numel(dragValidate/3))
termsEl = sum(XiTotEl~=0)

n = 8;
polyorderN = 2;
usesine = 0;
% xTest = xTrain./max(xTrain);
ThetaTotRad = poolData(xTest,n,polyorderN,usesine);
thetaNorm = poolData(max(xTrain),n,polyorderN,usesine);
ThetaValRad = poolData(xValidate,n,polyorderN,usesine);
lambda = 2;      % lambda is our sparsification knob.
XiTotRad= sparsifyDynamics(ThetaTotRad,drag(:,3),lambda,1);
XiTotRad = XiTotRad./thetaNorm';
rmseRad = sqrt(sum((dragValidate(:,3) -ThetaValRad*XiTotRad)'.^2)/numel(dragValidate/3));
termsRad = sum(XiTotRad~=0);

dragEst = [ThetaValAz*XiTotAz ThetaValEl*XiTotEl ThetaValRad*XiTotRad];% ThetaValA*XiTotA];

rmse = sqrt(sum((dragValidate(:,2)' -dragEst')'.^2)/numel(dragValidate/2));
n2 = size(drag);
figure
tL = tiledlayout(n2(2),1);
ylab = {'$C_{D_{el}}$','$C_{D_{az}}$','$C_{D_{rad}}$','$F_z$','ux','uy','uz'};
for i = 1:n2(2)
    nexttile;
    plot(dragValidate(:,i))
    hold on
    plot(dragEst(:,i),'--')
    grid on
    ylabel(ylab{i})
    %     ylim([0 inf])
end
xlabel('Data Point');
legend({'Simulation','LS Estimate'},'Location','SouthEast');
tL.TileSpacing = 'compact';
tL.Padding = 'compact';

