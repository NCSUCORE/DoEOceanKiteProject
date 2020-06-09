if ~slreportgen.utils.isModelLoaded('OCTModel')
    OCTModel
end
lengthScaleFactor = 1/1;
densityScaleFactor = 1/1;

sim = SIM.sim;
sim.setDuration(2000,'s');

dynamicCalc = '';
SPOOLINGCONTROLLER = 'netZeroSpoolingController';%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ZERO FOR MITCHELLS CONTROL ALLOCATION, ONE OLD CONTROL ALLOCATION MATRIX
controlAllocationBit = 0;
%% Opt stuff (move to mask)
load('1251James.mat')%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
guess=mean(mean(Ten));
ki_iter=guess/60;
kp_iter=guess/60;
kd_iter=0;
TenWidth=1000;
speedRange=[-.4,.4];%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Load components
% Flight Controller
loadComponent('firstBuildPathFollowing');
% Ground station controller
loadComponent('oneDoFGSCtrlBasic');
% High Level Con
loadComponent('constBoothLem')

%PATHGEOMETRY = 'ellipse';
PATHGEOMETRY = 'lemOfBooth';
% Ground station
loadComponent('pathFollowingGndStn');
% Winches
loadComponent('oneDOFWnch');
% Tether
loadComponent('pathFollowingTether');
% Vehicle
loadComponent('pathFollowingVhcl');
% Environment
loadComponent('constXYZT');
%% Choose Path Shape and Set basis parameters for high level controller
%fltCtrl.setFcnName('ellipse','');
% fltCtrl.setFcnName('circleOnSphere','');
fltCtrl.setFcnName('lemOfBooth','');

hiLvlCtrl.basisParams.setValue([1,1.4,.36,0,125],'');% Lemniscate of Booth%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Environment IC's and dependant properties
% Set Values

env.water.flowVec.setValue([1,0,0],'m/s')%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
flowspeed = norm(env.water.flowVec.Value);
%% Ground Station IC's and dependant properties
gndStn.initAngPos.setValue(0,'rad');
gndStn.initAngVel.setValue(0,'rad/s');
%gndStn.thrAttch1.velVec.setValue([0 0 0]','m/s');
%% Set vehicle initial conditions
vhcl.setICsOnPath(...
    .4,... % Initial path position
    fltCtrl.fcnName.Value,... % Name of path function
    hiLvlCtrl.basisParams.Value,... % Geometry parameters
    gndStn.posVec.Value,... %Path Center Point
    (11.5/2)*flowspeed) % Initial speed
vhcl.setAddedMISwitch(false,''); %true to have added mass on
%% Tethers IC's and dependant properties
thr.tether1.initGndNodePos.setValue(gndStn.thrAttch1.posVec.Value(:),'m');
thr.tether1.initAirNodePos.setValue(vhcl.initPosVecGnd.Value(:)+rotation_sequence(vhcl.initEulAng.Value)*vhcl.thrAttchPts.posVec.Value,'m');
thr.tether1.initGndNodeVel.setValue([0 0 0]','m/s');
thr.tether1.initAirNodeVel.setValue(vhcl.initVelVecBdy.Value(:),'m/s');
thr.tether1.vehicleMass.setValue(vhcl.mass.Value,'kg');
thr.tether1.density.setValue(1000,'kg/m^3');
%% winches IC's and dependant properties
wnch.setTetherInitLength(vhcl,gndStn.posVec.Value,env,thr,env.water.flowVec.Value);
%% ALL Controller Properties
%General
fltCtrl.setInitPathVar(vhcl.initPosVecGnd.Value,hiLvlCtrl.basisParams.Value,gndStn.posVec.Value)
fltCtrl.setStartControl(0,'s')

%Level 1, Velocity Angle Selection
fltCtrl.setSearchSize(.5,'');
fltCtrl.perpErrorVal.setValue(3*pi/180,'rad')

%Level 2, Tangent Roll Selection
fltCtrl.maxBank.upperLimit.setValue(45*pi/180,'');
fltCtrl.maxBank.lowerLimit.setValue(-45*pi/180,'');


fltCtrl.tanRoll.kp.setValue(.2,'(rad)/(rad)');
% fltCtrl.tanRoll.kp.setValue(0,'(rad)/(rad)');
fltCtrl.tanRoll.ki.setValue(0,'(rad)/(rad*s)');
fltCtrl.tanRoll.kd.setValue(0,'(rad)/(rad/s)');
fltCtrl.tanRoll.tau.setValue(.01,'s');

%Level 3 Moment Selection


fltCtrl.rollMoment.kp.setValue((1e4)/(10*pi/180),'(N*m)/(rad)')
% fltCtrl.rollMoment.kp.setValue(0,'(N*m)/(rad)')
fltCtrl.rollMoment.ki.setValue(0,'(N*m)/(rad*s)');
fltCtrl.rollMoment.kd.setValue((2e4)/(10*pi/180),'(N*m)/(rad/s)');
fltCtrl.rollMoment.tau.setValue(.001,'s');

fltCtrl.yawMoment.kp.setValue((1e3)/(10*pi/180),'(N*m)/(rad)');
% fltCtrl.yawMoment.ki.setValue(0,'(N*m)/(rad*s)');
% fltCtrl.yawMoment.kd.setValue(0,'(N*m)/(rad/s)');
% fltCtrl.yawMoment.tau.setValue(0.001,'s');

%Control Allocation
allMat = zeros(4,3);
allMat(1,1)=-1/(2*vhcl.portWing.GainCL.Value(2)*...
    vhcl.portWing.refArea.Value*abs(vhcl.portWing.aeroCentPosVec.Value(2)));
allMat(2,1)=-1*allMat(1,1);
allMat(3,2)=-1/(vhcl.hStab.GainCL.Value(2)*...
    vhcl.hStab.refArea.Value*abs(vhcl.hStab.aeroCentPosVec.Value(1)));
allMat(4,3)= 1/(vhcl.vStab.GainCL.Value(2)*...
    vhcl.vStab.refArea.Value*abs(vhcl.vStab.aeroCentPosVec.Value(1)));
% allMat = [-1.1584         0         0;
%           1.1584         0         0;
%           0             -2.0981    0;
%           0              0         4.8067];
fltCtrl.ctrlAllocMat.setValue(allMat,'(deg)/(m^3)');

fltCtrl.controlSigMax.upperLimit.setValue(20,'')
fltCtrl.controlSigMax.lowerLimit.setValue(-20,'')

%Winch Controller
fltCtrl.traditionalBool.setValue(0,'')

fltCtrl.winchSpeedIn.setValue(-flowspeed/3,'m/s')
fltCtrl.winchSpeedOut.setValue(flowspeed/3,'m/s')

fltCtrl.elevatorReelInDef.setValue(20,'deg')

fltCtrl.setMinR(100,'m')
fltCtrl.setMaxR(200,'m')

%      fltCtrl.outRanges.setValue([0.49   1.0000;
%                                  2.0000    2.0000],''); %circle
fltCtrl.outRanges.setValue( [0         0.1250;%%%%%%%%%%%%%%lemOfBoot
    0.3450    0.6250;
    0.8500    1.0000;],'');
%
%      fltCtrl.outRanges.setValue( [0.15    0.4;
%                                   0.6    .85;],'');
%% Scale
% scale environment
%env.scale(sim.lengthScaleFactor.Value,sim.densityScaleFactor.Value);
% scale vehicle
vhcl.scale(sim.lengthScaleFactor.Value,sim.densityScaleFactor.Value);
vhcl.calcFluidDynamicCoefffs;
% scale ground station
gndStn.scale(sim.lengthScaleFactor.Value,sim.densityScaleFactor.Value);
% scale tethers
thr.scale(sim.lengthScaleFactor.Value,sim.densityScaleFactor.Value);
% scale winches
wnch.scale(sim.lengthScaleFactor.Value,sim.densityScaleFactor.Value);
% scale controller
fltCtrl.scale(sim.lengthScaleFactor.Value,sim.densityScaleFactor.Value);
%% Run the simulation
simWithMonitor('OCTModel')
parseLogsout;
% inds=find(abs(tsc.closestPathVariable.Data(2:end)-tsc.closestPathVariable.Data(1:end-1))>.95);
% if ~isempty(inds)
%     disp(tsc.tetherLengths.Data(inds(2:end))-tsc.tetherLengths.Data(inds(1:end-1)))
%     disp(tsc.tetherLengths.Data(inds(end)))
% end
% plotTetherLengths
% kiteAxesPlot
%stopCallback