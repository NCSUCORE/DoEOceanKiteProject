% Copyright 2015, All Rights Reserved
% Code by Steven L. Brunton
% For Paper, "Discovering Governing Equations from Data:
%        Sparse Identification of Nonlinear Dynamical Systems"
% by S. L. Brunton, J. L. Proctor, and J. N. Kutz

clear all, close all, clc
% generate Data
thrSweep = [2000 3000 4000];
altSweep = 1;
flwSweep = [1.25];%0.5:0.25:2;
flowMult = 0.1:0.1:1;
shearLayer = [200:200:1800];
xTrain = meshgrid(thrSweep,altSweep,shearLayer);
[n,m,r] = size(xTrain);
numCase = n*m*r;
powGen = zeros(n,m,r);
pathErr = zeros(n,m,r);
dragRatio = zeros(n,m,r);
Pow = cell(n,m,r);
fpath = ['C:\Users\adabney\Documents\Results\2022-08-24_sensitivityStudy\'];

% portR = vhcl.turb1.attachPtVec.Value;
% S = vhcl.fluidRefArea.Value;
% turbD = vhcl.turb1.diameter.Value;
% cp = 0.317*pi*(turbD/2)^2/S;
% ct = 0.470*pi*(turbD/2)^2/S;

xTrain = [];
drag = [];
dragValidate = [];
xValidate = [];
power = [];
powerValidate = [];
energy = [];
energyValidate = [];
coef = [];
coefValidate = [];
dx = [];
dxVal = [];
for j = 1:m
    for k = 1:r
        for qq = 1
            for kk = 1:2
                flwSpd = flwSweep;                                              %   m/s - Flow speed
                altitude = thrSweep(j)/2;                   %   m/m - cross-current and initial altitude\
                thrLength = thrSweep(j);
                fString = 'Sensitivity';
                if kk == 2
                    fString = ['BP' fString];
                end
                if qq == 1
                    filename = sprintf(strcat(fString,'_V-1_shearLayer-%d_Alt-%d_thr-%d.mat'),k*200,altitude,thrLength)
                else
                    filename = sprintf(strcat(fString,'_V-0.75_shearLayer-%d_Alt-%d_thr-%d.mat'),k*200,altitude,thrLength)
                end
                if exist([fpath filename])==2
                    load([fpath filename])
                    portR = vhcl.turb1.attachPtVec.Value;
                    S = vhcl.fluidRefArea.Value;
                    turbD = vhcl.turb1.diameter.Value;
                    cp = 0.317*pi*(turbD/2)^2/S;
                    ct = 0.470*pi*(turbD/2)^2/S;
                    dt = 1;
                    tEnd = tsc.positionVec.Time(end);
                    if tEnd<100
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

                    fluidForce = tsc.FFluidBdy.resample(t).Data;
                    dragForce = squeeze(dot(fluidForce,vApp).*vApp./vAppMag);
                    liftForce = squeeze(fluidForce-dot(fluidForce,vApp).*vApp./vAppMag);

                    cd = sqrt(sum(dragForce.^2))'./dynP;
                    cl = sqrt(sum(liftForce.^2))'./dynP;

                    pow = squeeze(tsc.netPower.resample(t).Data);

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

                    vFlowProj = squeeze(vFlow).*cosd(el).*cosd(az);
                    refEnergyDensity = 1/2*1000*vFlowProj.^3*S;
                    

                    fThr = tsc.FThrNetBdy.resample(t).Data;
                    rotThr = (pagemtimes(rotMat,fThr));
                    rotThr(1,:,:) = 0;
                    thrDrag = pagemtimes(pagetranspose(rotMat),rotThr);
                    thrDragMag = sqrt(sum(rotThr.^2));

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
                    rotThrNorm = squeeze(rotThr)./squeeze(thrDragMag)';

                    sign = [1 0 0]*cross(rVelAppNorm,rotThrNorm);
                    sign = sign./abs(sign);

                    dragAng = (acos(dot(rotThrNorm,rVelAppNorm)).*sign)';
                    
                    cdThr = dot(squeeze(thrDrag),squeeze(vApp))'./dynP;
                    velAng = squeeze(tsc.velAngle.resample(t).Data);
                    b = tsc.basisParams.Data;
                    b(3) = sin(b(3))*b(5); 
                    [pos1,~] = lemBoothNew(0,b,[0,0,0]);
                    t = t-100;
                    pos2 = abs((pos(2:3,:)-pos1(2:3,:))');
                    pos2Mag = sqrt(sum(pos2.^2,2));
                    xTemp = [pos(3,:)'/100 pos2/100 squeeze(vRat) velAng cos(velAng) sin(velAng) squeeze(vApp./vAppMag)' cos(velAng).^2 sin(velAng).^2 sin(eul') cos(eul') squeeze(vRat) ];% squeeze(lift)' posMag'];% tenMag thrTen(3,:)'./thrTen(1,:)'];
                   if rand>0.25
                        xTrain = [xTrain;xTemp];
                        energy = [energy; refEnergyDensity];
                        power = [power; pow];
                        coef = [coef;cl cd];
                        drag = [drag; cdThr dragAng];
                      
                    else
                        xValidate = [xValidate;xTemp];
                        energyValidate = [energyValidate; refEnergyDensity];
                        powerValidate = [powerValidate; pow];
                        coefValidate = [coefValidate; cl cd];
                        dragValidate = [dragValidate;cdThr dragAng];
                    end
                end
            end
        end
    end
end
%% pool Data  (i.e., build library of nonlinear time series)
drag = real(drag);
dragValidate = real(dragValidate);
close all
n = 10;
polyorderN = 2;
usesine = 0;
xTest = xTrain./abs(max(xTrain));
ThetaTotD = poolData(xTest,n,polyorderN,usesine);

ThetaValD = poolData(xValidate,n,polyorderN,usesine);

% 
% 
% % lambda = .1;      % lambda is our sparsification knob.
% XiTotD = sparsifyDynamicsNL(ThetaTotD,drag(:,1),lambda,1);
% 
% m = 10;
% polyorder = 2;
% usesine = 0;
% ThetaTotA = poolData(xTrain(:,[1 2 3 4 5 6 7 8 9 10]),m,polyorder,usesine);
% ThetaValA = poolData(xValidate(:,[1 2 3 4 5 6 7 8 9 10]),m,polyorder,usesine);
% lambda = .5;      % lambda is our sparsification knob.
% XiTotA = sparsifyDynamics(ThetaTotA,drag(:,2),lambda,1);

n = size(ThetaTotD);
lambda = 0.05;
opts = optimoptions('fminunc',MaxFunctionEvaluations=1e4);
beta = zeros(n(2),1);
for i = 1:10
f = @(x)dragEst(ThetaTotD,power,energy,coef,x,cp,ct);
[beta,err] = fminunc(f,beta,opts);
ThetaTotD(:,abs(beta)<lambda) = 0;
beta(abs(beta)<lambda) = 0;
end
cdThr = ThetaTotD*beta;
powerEst = powEst(ThetaTotD,power,energy,coef,beta,cp,ct);
plot(power,powerEst)
sum(beta~=0)
figure
plot(cdThr)
hold on
plot(drag(:,1))
% poolDataLIST({'z','path_y','path_z','vAug','cGam'},XiTotD,n,1,polyorderN,usesine);
% poolDataLIST({'z','y','zp','vAug','gam','cGam','sGam','u','v','w'},beta,n,1,polyorderN,usesine);


function J = dragEst(theta,pow,energy,coef,beta,cp,ct)
    cdThr = theta*beta;
    cl = coef(:,1);
    cd = coef(:,2);
    coefPow = cl.^3*4*cp./(cd+4*ct+cdThr).^3;
    power = energy.*coefPow;

    J = sqrt(sum((pow-power).^2)/numel(pow));
end

function power = powEst(theta,pow,energy,coef,beta,cp,ct)
    cdThr = theta*beta;
    cl = coef(:,1);
    cd = coef(:,2);
    coefPow = cl.^3*4*cp./(cd+4*ct+cdThr).^3;
    power = energy.*coefPow;

end