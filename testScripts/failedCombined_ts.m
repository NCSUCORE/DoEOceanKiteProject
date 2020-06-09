% clear;clc;close all
% elevConsts=[-30:5:15 20:1:30];
% clear pitchDeg elevationDeg
% for i=1:length(elevConsts)
simParams = SIM.simParams;
simParams.setDuration(1500,'s');
dynamicCalc = '';
%% Variables to be put into a takeoff controller object
% % choice=2-1;
% % steptime=0;
% % fprintf("Scaled pool time = %g\n",(steptime+10)*sqrt(1/20))
% % elevConst=elevConsts(i);%elevConsts(i);%elevConsts(i);
% % pitchSP=0*pi/180; %degrees
% % kpPitch=100; %N*M per degree
% % kpYaw=5.7296e+02;
% elevSPDeg=timeseries(30);
% % elevSP=timeseries(linspace(20*pi/180,80*pi/180,100),linspace(0,2000,100));
% kpElev=-1; %deg/deg
% kdElev=12*kpElev;
% kiElev=.005*kpElev;
% TLSP=80;
% nonCrossWinchGain = 1.5;

%% Load components
% Flight Controller
loadComponent('newSpoolCtrl');
fltCtrl.setRudderGain(0,'')
SPOOLINGCONTROLLER = 'UniversalSpoolingController';
fltCtrl.setIntraDrift(10,'m');
fltCtrl.setInitCtrlVec([.25 .22 0 0 0 0 0 0],'')
% Ground station controller
loadComponent('oneDoFGSCtrlBasic');
% High level controller
loadComponent('constBoothLem')
% Ground station
loadComponent('pathFollowingGndStn');
% Winches
loadComponent('oneDOFWnch');
% Tether
loadComponent('pathFollowingTether');
% Vehicle
loadComponent('fullScale1thr');
vstruct=vhcl.struct('OCT.aeroSurf');
maxDeflUps=[vstruct.maxCtrlDef];
maxDeflDns=[vstruct.minCtrlDef];
% Environment
loadComponent('constXYZT');
% loadComponent('CNAPsTurbJames');
%  loadComponent('CNAPsMitchell');
% Sensors
loadComponent('idealSensors')
% Sensor processing
loadComponent('idealSensorProcessing')
%% Environment IC's and dependant properties
 env.water.setflowVec([1.5 0 0],'m/s')
%% Set basis parameters for high level controller
% hiLvlCtrl.initBasisParams.setValue([0.8,1.4,-20*pi/180,0*pi/180,125],'[]') % Lemniscate of Booth
hiLvlCtrl.basisParams.setValue([.6,1.6,.36,0,fltCtrl.initTL.Value],'[rad rad rad rad m]') % Lemniscate of Booth
% hiLvlCtrl.basisParams.setValue([1,1.4,20*pi/180,-.5,125],'') % Lemniscate of Booth
%% Ground Station IC's and dependant properties
gndStn.setPosVec([0 0 0],'m')
gndStn.initAngPos.setValue(0,'rad');
gndStn.initAngVel.setValue(0,'rad/s');

%% Set vehicle initial conditions
% vhcl.setICsOnPath(...
%     .75,... % Initial path position
%     PATHGEOMETRY,... % Name of path function
%     [1,1.4,20*pi/180,-.5,125],... % Geometry parameters
%     gndStn.posVec.Value,... % Center point of path sphere
%     1)%(11/2)*norm(env.water.flowVec.Value)) % Initial speed
% vhcl.setAddedMISwitch(false,'');
vhcl.setInitAngVelVec([0 0 0],'rad/s')
vhcl.setInitEulAng([0*pi/180 0*pi/180 0],'rad')
initelev = 20;
initTL = hiLvlCtrl.basisParams.Value(end);
vhcl.setInitPosVecGnd([initTL*cosd(initelev),0,initTL*sind(initelev)],'m')
vhcl.setInitVelVecBdy([-1 0 0],'m/s')
% vhcl.setICsOnPath(...
%     .25,... % Initial path position
%     PATHGEOMETRY,... % Name of path function
%     hiLvlCtrl.basisParams.Value,... % Geometry parameters
%     gndStn.posVec.Value,... % Center point of path sphere
%     .1*(11/2)*norm([ 1 0 0 ])) % Initial speed
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
wnch.setTetherInitLength(vhcl,gndStn.posVec.Value,env,thr,[ 1 0 0]);

%% Controller User Def. Parameters and dependant properties
fltCtrl.setFcnName(PATHGEOMETRY,''); % PATHGEOMETRY is defined in fig8ILC_bs.m
% Set initial conditions
fltCtrl.setInitPathVar(vhcl.initPosVecGnd.Value,...
    hiLvlCtrl.basisParams.Value,...
    gndStn.posVec.Value);

% fltCtrl.setInitPathVar(vhcl.initPosVecGnd.Value,...
%     hiLvlCtrl.basisParams.Value,...
%     gndStn.posVec.Value);
simWithMonitor('OCTModel')
tsc = signalcontainer(logsout);
comparisonRange=[min(tsc.currentState.Time(and(tsc.currentState.Data(1:end-1) == 1,tsc.currentState.Data(2:end) == 2))),max(tsc.currentState.Time(and(tsc.currentState.Data(1:end-1) == 1,tsc.currentState.Data(2:end) == 2)))];
fprintf('Comparison Range = [%5.1f %5.1f]\n',comparisonRange(1), comparisonRange(2))
tsc.powersummary(comparisonRange)
% pitchDeg(i)=tsc.eulerAngles.Data(2,1,end)*180/pi;
% elevationDeg(i)=tsc.elevdeg.Data(end);
% end
% LUT = Simulink.LookupTable;
% timeVec = linspace(0,1);
% LUT.Table.Value = env.waterTurb.frequencyDomainEqParams.Value.Data(:,:,:,:,[],:);
% LUT.Breakpoints(1).Value = env.water.xGridPoints.Value;
% LUT.Breakpoints(2).Value = env.water.yGridPoints.Value;
% LUT.Breakpoints(3).Value = env.water.zGridPoints.Value;
% LUT.Breakpoints(4).Value = 1:size(LUT.Table.Value,4);
% LUT.Breakpoints(5).Value = 1:size(LUT.Table.Value,5);
% LUT.Breakpoints(6).Value = env.waterTurb.frequencyDomainEqParams.Value.Time;
% LUT.StructTypeInfo.Name = 'LUT';