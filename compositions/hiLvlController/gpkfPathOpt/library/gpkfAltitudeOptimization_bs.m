% clear
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

%% get equations for expectation and variance for power
% see expectationAndVarianceDerivation
hiLvlCtrl.expectedPow = @(c0,c1,mu,sig,z) mu*(mu^2 + 3*sig^2)*(c0 + c1*z);
hiLvlCtrl.VariancePow = @(c0,c1,mu,sig,z) 3*(3*mu^4*sig^2 + 12*mu^2*sig^4 + 5*sig^6)*(c0 + c1*z)^2;

%% fit curve to power data
% structure of the function
funcStruct = fittype( @(c0,c1,z,vw) (c0 + c1.*z).*vw.^3, ...
    'coefficients',{'c0','c1'}, 'independent', {'z', 'vw'}, ...
    'dependent', 'P' );
hiLvlCtrl.powerFunc = fit( [zz, ff], ppmax, funcStruct );

% store values of the power map
hiLvlCtrl.pMaxVals  = R.Pmax;
hiLvlCtrl.pMaxVals(isnan(R.Pmax))  = 0;
hiLvlCtrl.altVals   = A;
hiLvlCtrl.flowVals  = F;

% add grid for omniscient
hiLvlCtrl.powerGrid   = griddedInterpolant(hiLvlCtrl.flowVals,...
    hiLvlCtrl.altVals,hiLvlCtrl.pMaxVals);
% sotre vales of the elevation and tether lenght grid
hiLvlCtrl.elevationGrid   = griddedInterpolant(hiLvlCtrl.flowVals,...
    hiLvlCtrl.altVals,R.EL);
hiLvlCtrl.thrLenGrid   = griddedInterpolant(hiLvlCtrl.flowVals,...
    hiLvlCtrl.altVals,R.thrL);

%% mid level control for tether length and elevation angle trajectory opt
hiLvlCtrl.midLvlCtrl.dLMax = 5;
hiLvlCtrl.midLvlCtrl.dLMin = -1;
hiLvlCtrl.midLvlCtrl.dTMax = 2;
hiLvlCtrl.midLvlCtrl.dTMin = -2;
hiLvlCtrl.midLvlCtrl.LMax  = 1500;
hiLvlCtrl.midLvlCtrl.LMin  = 400;
hiLvlCtrl.midLvlCtrl.TMax  = 40;
hiLvlCtrl.midLvlCtrl.TMin  = 10;
hiLvlCtrl.midLvlCtrl.predHorz  = 4;
hiLvlCtrl.midLvlCtrl.dt  = hiLvlCtrl.mpckfgpTimeStep/hiLvlCtrl.midLvlCtrl.predHorz;
hiLvlCtrl.midLvlCtrl.pFunc = @(Lthr,elev,z) 0;
hiLvlCtrl.midLvlCtrl.LthrPenaltyWeight = 1;
hiLvlCtrl.midLvlCtrl.TPenaltyWeight    = 1;

%% plot
testZ = linspace(altitude(1),altitude(end),30);
testF = linspace(flwSpd(1),flwSpd(end)*1.0,20);
[ZZ,FF] = meshgrid(testZ,testF);
PP = hiLvlCtrl.powerFunc(ZZ,FF);
residual = R.Pmax - hiLvlCtrl.powerFunc(A,F);
rmsePow = sqrt(sum(residual(~isnan(residual)).^2,'All')/sum(~isnan(residual),'All'));

surf(F,A,R.Pmax)
hold on
scatter3(FF(:),ZZ(:),PP(:))

figure
contourf(F,A,abs(residual));
hold on;grid on;
xlabel('Flow speed [m/s]')
ylabel('Altitude [m]')
cc = colorbar;
cc.Label.String = 'Absolute Residual [kW]';
cc.Label.Interpreter = 'latex';

figure
contourf(F,A,R.Pmax)
hold on;grid on;
xlabel('Flow [m/s]');
ylabel('Altitude [m]');
cc = colorbar;
cc.Label.String = 'Power [kW]';
cc.Label.Interpreter = 'latex';

%% save file
saveFile = saveBuildFile('hiLvlCtrl',mfilename,'variant','HILVLCONTROLLER');
save(saveFile,'PATHGEOMETRY','-append')

