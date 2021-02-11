clear
clc
close all

HILVLCONTROLLER = 'gpkfAltitudeOpt';
PATHGEOMETRY = 'lemOfBooth';

loadComponent('ayazAirborneSynFlow');

% z grid
xMeasure            = env.water.zGridPoints.Value;
% spatial covarirance kernel
spatialCovFn        = env.water.spatialCovFn;
% temporal covariance kernel
temporalCovFn       = env.water.temporalCovFn;
% mean function
meanFn              = env.water.meanFn;
% spatial covariance amplitude
spatialCovAmp       = env.water.spatialCovAmp.Value;
% spatial length scale
spatialLengthScale  = env.water.spatialLengthScale.Value;
% temporal length scale
temporalLengthScale = env.water.temporalLengthScale.Value;
% noise variance
noiseVar            = env.water.noiseVariance.Value;

% fast state estimate time step in MINUTES
fastTimeStep  = 10/60;
% MPC KFGP time step in MINUTES
mpckfgpTimeStep = 5;
% mpc prediction horizon
predictionHorz  = 6;
% MPC constants
exploitationConstant = 1;
explorationConstant  = 1;


hiLvlCtrl.spatialCovFn         = spatialCovFn;
hiLvlCtrl.temporalCovFn        = temporalCovFn;
hiLvlCtrl.meanFn               = meanFn;
hiLvlCtrl.kfgpTimeStep         = fastTimeStep;
hiLvlCtrl.xMeasure             = xMeasure;
hiLvlCtrl.spatialCovAmp        = spatialCovAmp;
hiLvlCtrl.spatialLengthScale   = spatialLengthScale;
hiLvlCtrl.temporalCovAmp       = 1;
hiLvlCtrl.temporalLengthScale  = temporalLengthScale;
hiLvlCtrl.noiseVariance        = noiseVar;
hiLvlCtrl.meanFnProps          = env.water.meanFnProps.Value;

%% mpc controller properties
hiLvlCtrl.mpckfgpTimeStep      = mpckfgpTimeStep;
hiLvlCtrl.predictionHorz       = predictionHorz;
hiLvlCtrl.exploitationConstant = exploitationConstant;
hiLvlCtrl.explorationConstant  = explorationConstant;
hiLvlCtrl.rateLimit            = 1*0.15;
hiLvlCtrl.maxStepChange        = 200;
hiLvlCtrl.minVal               = 100;
hiLvlCtrl.maxVal               = 1000;

%% extract values from power map
load('PowStudyAir_V6-22.mat');
[A,F] = meshgrid(altitude,flwSpd);
ppmax = R.Pmax(:);
zz    = A(:);
ff    = F(:);
locateNan = isnan(ppmax);
ppmax(locateNan) = [];
ff(locateNan) = [];
zz(locateNan) = [];

hiLvlCtrl.powerFunc = fit([ff, zz],ppmax,'poly31');
hiLvlCtrl.pMaxVals  = R.Pmax;
hiLvlCtrl.pMaxVals(isnan(R.Pmax))  = 0;
hiLvlCtrl.altVals   = A;
hiLvlCtrl.flowVals  = F;
hiLvlCtrl.powerGrid   = griddedInterpolant(hiLvlCtrl.flowVals,...
    hiLvlCtrl.altVals,hiLvlCtrl.pMaxVals);

testFit = polyfit(F(:,2),R.Pmax(:,2),3);
fNew = linspace(0.5*F(1,2),1.5*F(end,2),101);
pNew = polyval(testFit,fNew);

%% plot
testZ = linspace(altitude(1),altitude(end),30);
testF = linspace(flwSpd(1),flwSpd(end)*1.5,20);
[ZZ,FF] = meshgrid(testZ,testF);
PP = hiLvlCtrl.powerGrid(FF(:),ZZ(:));
for ii = 1:numel(FF(:))
[PP2(ii),~] = convertWindStatsToPowerStats(F,A,R.Pmax,...
    ZZ(ii),FF(ii),0);
end

scatter3(ff,zz,ppmax)
hold on
surf(F,A,R.Pmax)
scatter3(FF(:),ZZ(:),PP(:))

figure
contourf(F,A,R.Pmax)
xlabel('Flow [m/s]');
ylabel('Altitude [m]');
cc = colorbar;
cc.Label.String = 'Power [kW]';
cc.Label.Interpreter = 'latex';

figure
plot(F(:,2),R.Pmax(:,2),'-o');
hold on
plot(fNew,pNew);

saveFile = saveBuildFile('hiLvlCtrl',mfilename,'variant','HILVLCONTROLLER');
save(saveFile,'PATHGEOMETRY','-append')

