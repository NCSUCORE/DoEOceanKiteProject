clear
clc
close all
cd(fileparts(mfilename('fullpath')));

% clear;clc;close all
simParams = SIM.simParams;
simParams.setDuration(500,'s');
dynamicCalc = '';

%% Load components
% Flight Controller
% loadComponent('pathFollowingCtrlAddedMass');
loadComponent('guidanceLawPathFollowingWater');
% fltCtrl.rudderGain.setValue(0,'')
% SPOOLINGCONTROLLER = 'netZeroSpoolingControllerEllipsePath';
SPOOLINGCONTROLLER = 'netZeroSpoolingController';
% Ground station controller
loadComponent('oneDoFGSCtrlBasic');
% High level controller
% loadComponent('constEllipse');
loadComponent('constBoothLem');
% Ground station
loadComponent('pathFollowingGndStn');
% Winches
loadComponent('oneDOFWnch');
% Tether
loadComponent('pathFollowingTether');
% Sensors
loadComponent('idealSensors')
% Sensor processing
loadComponent('idealSensorProcessing')
% Vehicle
loadComponent('fullScale1thr');
% loadComponent('pathFollowingVhclForComp')
% loadComponent('sensitivityAnalysis');              %   Load vehicle 

% Environment
% loadComponent('CNAPsNoTurbJosh');
% loadComponent('CNAPsTurbJames');
% loadComponent('CNAPsTurbMitchell');
loadComponent('ConstXYZT');

%% main parameters
thrLength = 100;

%% Environment IC's and dependant properties
env.water.setflowVec([2 0 0],'m/s')

%% Set basis parameters for high level controller
% hiLvlCtrl.initBasisParams.setValue([0.8,1.4,-20*pi/180,0*pi/180,125],'[]') % Lemniscate of Booth
hiLvlCtrl.basisParams.setValue([1.5,2.3,-.3,180*pi/180,125],'[rad rad rad rad m]') % Lemniscate of Booth
%% Ground Station IC's and dependant properties
gndStn.setPosVec([0 0 0],'m')
gndStn.initAngPos.setValue(0,'rad');
gndStn.initAngVel.setValue(0,'rad/s');

%% Set vehicle initial conditions
init_speed = 4*norm(env.water.flowVec.Value);
[init_O_rKite,init_Euler,init_O_vKite,init_OwB,init_Az,init_El,init_OcB] = ...
    getInitConditions(fltCtrl.initPathParameter,fltCtrl.pathWidth_deg,...
    fltCtrl.pathHeight_deg,fltCtrl.pathElevation_deg,thrLength,init_speed);
vhcl.setInitPosVecGnd(init_O_rKite,'m');
initVel = calcBcO(init_Euler)*init_O_vKite;
vhcl.setInitVelVecBdy(initVel,'m/s');
vhcl.setInitEulAng(init_Euler,'rad')
% Initial angular velocity is zero
vhcl.setInitAngVelVec(init_OwB,'rad/s');


%% Tethers IC's and dependant properties
thr.tether1.initGndNodePos.setValue(gndStn.thrAttch1.posVec.Value(:)...
    +gndStn.posVec.Value(:),'m');
thr.tether1.initAirNodePos.setValue(vhcl.initPosVecGnd.Value(:)...
    +rotation_sequence(vhcl.initEulAng.Value)*vhcl.thrAttchPts_B.posVec.Value,'m');

thr.tether1.initGndNodeVel.setValue([0 0 0]','m/s');
thr.tether1.initAirNodeVel.setValue(vhcl.initVelVecBdy.Value(:),'m/s');

thr.tether1.vehicleMass.setValue(vhcl.mass.Value,'kg');


%% Winches IC's and dependant properties
% wnch.setTetherInitLength(vhcl,gndStn.posVec.Value,env,thr,env.water.flowVec.Value);
wnch.winch1.initLength.setValue(norm(vhcl.initPosVecGnd.Value),'m')
 
%% Run Simulation
simWithMonitor('OCTModel')
tsc = signalcontainer(logsout);
tsc1 = tsc.resample(0.1);

%% processing
figure('WindowState','maximized');
plotResults(tsc);

% lap results
figure('WindowState','maximized');
lapStats = tsc.plotAndComputeLapStats;

% sgtitle(sprintf('Elevation: %.1f deg, Tether length: %.1f m, Altitude: %.1f m, Wind speed: %.1f m/s',...
%     baselinePathELSp,baselineThrLengthSP,baselineAltSp,flowSpeed));

% fName = sprintf('E=%.1f,TL=%.1f,VW=%.1f',...
%     baselinePathELSp,baselineThrLengthSP,flowSpeed);

allAxes = findall(gcf,'type','axes');
set(allAxes,'FontSize',13);
% exportgraphics(gcf,[fName,'.png'],'Resolution',600);

%% plots

figure; dynamicFigureLocations;
plot(tsc.positionVec.Time,tsc.turnAngle.Data(:)*180/pi); grid on;
ylabel('Desired turn angle [deg]')

figure; dynamicFigureLocations;
plot(tsc.positionVec.Time,tsc.desiredTanRoll.Data(:)*180/pi); grid on;
ylabel('Tangent roll angle [deg]');
hold on;
plot(tsc.positionVec.Time,tsc.tanRoll.Data(:)*180/pi); grid on;
legend('Desired','Actual');

figure; dynamicFigureLocations;
plot(tsc.positionVec.Time,tsc.ctrlSurfDeflCmd.Data(:,1)); grid on;
ylabel('Aileron deflection [deg]')

figure; dynamicFigureLocations;
plot(tsc.positionVec.Time,tsc.tanRoll.Data(:)./max(abs(tsc.tanRoll.Data(:))))
hold on;
plot(tsc.positionVec.Time,tsc.ctrlSurfDeflCmd.Data(:,1)./max(abs(tsc.ctrlSurfDeflCmd.Data(:,1))))

%% animations
cIn = maneuverabilityAdvanced;
cIn.pathWidth = fltCtrl.pathWidth_deg;
cIn.pathHeight = fltCtrl.pathHeight_deg;
cIn.meanElevationInRadians = fltCtrl.pathElevation_deg*pi/180;
cIn.tetherLength = norm(init_O_rKite); 

figure; dynamicFigureLocations;
animateRes(tsc1,cIn);



