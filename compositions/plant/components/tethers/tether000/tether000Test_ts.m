%% busses


createThrTenVecBus
createThrAttachPtKinematicsBus
createConstantUniformFlowEnvironmentBus
%%
scaleFactor  = 1;
vhcl = OCT.vehicle;
vhcl.numTethers.setValue(1,'');
vhcl.numTurbines.setValue(2,'');
vhcl.mass.setValue(945.4,'kg')
vhcl.volume.setValue(0.9454,'m^3');
vhcl.build('partDsgn1_lookupTables.mat');

%%
env = ENV.env;
env.addFlow({'water'},'FlowDensities',1000);
% Set Values
env.water.velVec.setValue([1 0 0],'m/s');
% Scale up/down
env.scale(scaleFactor);

%%
% ground station
groundStation = [0;0;0];

%vehicles initial position in ground frame
vehicleInitialPositionGround =  1.0e+02 *...
   [0.541196100146197;
  -0.541196100146197;
   1.847759065022573;];
%water density
rho = 1000;
% gravity
grav = 9.81;
%vehicle initial euler angles
vehicleInitialEulerAngles = [-0.392699081698724  0  -2.356194490192345];

%attachment point on the vehicle in the body frame
bodyAttachmentPoint = [0;0;0];

%vehicle initial velocity
vehicleInitialVelocity = [-19;0;0];

%vehicle mass
vehicleMass = 9.454000000000000e+02;

%variants
TETHERS = 'tether000';
VARIANTSUBSYSTEM = 'NNodeTether';

%tether length
tetherLength = 200;

thr = OCT.tethers;
thr.setNumTethers(1,'');
thr.setNumNodes(2,'');
thr.build;

%rotation sequence rotates body to ground and ground to body 
% Set parameter values
thr.tether1.initGndNodePos.setValue(groundStation,'m');
thr.tether1.initAirNodePos.setValue(vehicleInitialPositionGround+rotation_sequence(vehicleInitialEulerAngles)*bodyAttachmentPoint,'m');
thr.tether1.initGndNodeVel.setValue([0 0 0]','m/s');
thr.tether1.initAirNodeVel.setValue(vehicleInitialVelocity,'m/s');
thr.tether1.vehicleMass.setValue(vehicleMass,'kg');
thr.tether1.youngsMod.setValue(4e9,'Pa');
thr.tether1.dampingRatio.setValue(0.75,'');
thr.tether1.dragCoeff.setValue(0.5,'');
thr.tether1.density.setValue(1300,'kg/m^3');

createThrNodeBus(thr.numNodes.Value);
thr.tether1.setDragEnable(true,'');
thr.tether1.setSpringDamperEnable(true,'');
thr.tether1.setNetBuoyEnable(true,'');


thr.designTetherDiameter(vhcl,env);

% Scale up/down
thr.scale(scaleFactor);


% simulate
sim('tether000Test1')

