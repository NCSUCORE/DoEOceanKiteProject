simParams = SIM.simParams;
simParams.setDuration(500,'s');
dynamicCalc = '';

%% Load components
% Flight Controller
loadComponent('guidanceLawPathFollowingWater');
% spooling controller
SPOOLINGCONTROLLER = 'netZeroSpoolingController';
% Ground station controller
loadComponent('oneDoFGSCtrlBasic');
% High level controller
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
% Environment
loadComponent('ConstXYZT');

%% Set basis parameters for high level controller
hiLvlCtrl.basisParams.setValue([1.5,2.3,-.3,180*pi/180,125],'[rad rad rad rad m]') % Lemniscate of Booth

%% Ground Station IC's and dependant properties
gndStn.setPosVec([0 0 0],'m')
gndStn.initAngPos.setValue(0,'rad');
gndStn.initAngVel.setValue(0,'rad/s');

%% Tethers IC's and dependant properties
thr.tether1.initGndNodePos.setValue(gndStn.thrAttch1.posVec.Value(:)...
    +gndStn.posVec.Value(:),'m');

thr.tether1.initGndNodeVel.setValue([0 0 0]','m/s');
thr.tether1.initAirNodeVel.setValue(vhcl.initVelVecBdy.Value(:),'m/s');

thr.tether1.vehicleMass.setValue(vhcl.mass.Value,'kg');







