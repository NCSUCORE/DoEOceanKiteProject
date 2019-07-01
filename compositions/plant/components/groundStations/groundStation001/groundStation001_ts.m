clc
format compact
close all

% run this to load tether tension data
% clear
% load('custom_constant_baseline_1106_104556.mat')

% actual data %
% position = tsc.positionGFC;
% mag = tsc.tetherTensionMag;

% average mag %
% mag.Data = mean(mag.Data)*ones(size(mag.Data));

% average direction %
% for i = 1:3
%     position.Data(:,i) = mean(position.Data(:,i))*ones(size(position.Data(:,i)));
% end

% createConstantUniformFlowEnvironmentBus

sim_time = 360;

% number of tethers
N = 4;
sim_param.N = N;

flow = [.1 0 0];

rho = 1000;
vol = 3.5;
h = vol^(1/3);
grav = 9.81;

buoyF = 1.5;
mass = rho*vol/buoyF;
m = mass;

inertiaMatrix = eye(3);

thr1Pt = [0 1 -.5];
thr1GndPos = [0 50 0];
thr1GndVel = [0 0 0];
thr2Pt = [cosd(30),-sind(30),-.5];
thr2GndPos = [50*cosd(30), -50*sind(30), 0];
thr2GndVel = [0 0 0];
thr3Pt = [-cosd(30),-sind(30),-.5];
thr3GndPos = [-50*cosd(30), -50*sind(30), 0];
thr3GndVel = [0 0 0];
CB2CMVec = [0 0 0];

dia_t = 0.05;
E = 3.8e9;
zeta = 0.05;
rho_tether = 300;
Cd = 0.5;

initPos = [0 0 100];
initVel = [0 0 0];
initEulerAngles = [0 0 0];
initAngVel = [0 0 0];

tetherLengths = (norm(initPos+thr1Pt-thr1GndPos))*ones(3,1);

gndStnMmtArms(1).posVec = thr1GndPos;
gndStnMmtArms(2).posVec = thr2GndPos;
gndStnMmtArms(3).posVec = thr3GndPos;

bodyMmtArms(1).posVec = thr1Pt;
bodyMmtArms(2).posVec = thr2Pt;
bodyMmtArms(3).posVec = thr3Pt;

liftingBodyThrAttch(1).posVec = [0 1/2 1/2];
liftingBodyThrAttch(2).posVec = [1/2*cosd(30), -1/2*sind(30), 1/2];
liftingBodyThrAttch(3).posVec = [-1/2*cosd(30), -1/2*sind(30), 1/2];

% thr(1).numNodes         = sim_param.N;
% thr(1).diameter         = dia_t;
% thr(1).youngsMod        = E;
% thr(1).density          = rho + rho_tether;
% thr(1).dragCoeff        = Cd;
% thr(1).dampingRatio     = zeta;
% thr(1).fluidDensity     = rho;
% thr(1).gravAccel        = grav;
% thr(1).vehicleMass      = mass;
% thr(1).initVhclAttchPt  = initPos + (rotation_sequence(initEulerAngles)*thr1Pt')';
% thr(1).initGndStnAttchPt = thr1GndPos;
% 
% thr(2).numNodes         = sim_param.N;
% thr(2).diameter         = dia_t;
% thr(2).youngsMod        = E;
% thr(2).density          = rho + rho_tether;
% thr(2).dragCoeff        = Cd;
% thr(2).dampingRatio     = zeta;
% thr(2).fluidDensity     = rho;
% thr(2).gravAccel        = grav;
% thr(2).vehicleMass      = mass;
% thr(2).initVhclAttchPt  = initPos + (rotation_sequence(initEulerAngles)*thr2Pt')';
% thr(2).initGndStnAttchPt = thr2GndPos;
% 
% thr(3).numNodes         = sim_param.N;
% thr(3).diameter         = dia_t;
% thr(3).youngsMod        = E;
% thr(3).density          = rho + rho_tether;
% thr(3).dragCoeff        = Cd;
% thr(3).dampingRatio     = zeta;
% thr(3).fluidDensity     = rho;
% thr(3).gravAccel        = grav;
% thr(3).vehicleMass      = mass;
% thr(3).initVhclAttchPt  = initPos + (rotation_sequence(initEulerAngles)*thr3Pt')';
% thr(3).initGndStnAttchPt = thr3GndPos;

thr = OCT.tethers;
thr.numTethers = SIM.parameter('Value',3);
thr.build;

thr.tether1.numNodes        = SIM.parameter('Value',4);
thr.tether1.initGndNodePos  = SIM.parameter('Value',thr1GndPos);
thr.tether1.initAirNodePos  = SIM.parameter('Value',initPos + (rotation_sequence(initEulerAngles)*thr1Pt')');
thr.tether1.initGndNodeVel  = SIM.parameter('Value',[0 0 0]);
thr.tether1.initAirNodeVel  = SIM.parameter('Value',initVel);
thr.tether1.diameter        = SIM.parameter('Value',dia_t);
thr.tether1.youngsMod       = SIM.parameter('Value',E);
thr.tether1.dampingRatio    = SIM.parameter('Value',zeta);
thr.tether1.dragCoeff       = SIM.parameter('Value',Cd);
thr.tether1.density         = SIM.parameter('Value',rho_tether);
thr.tether1.vehicleMass     = SIM.parameter('Value',mass);

thr.tether2.numNodes        = SIM.parameter('Value',4);
thr.tether2.initGndNodePos  = SIM.parameter('Value',thr2GndPos);
thr.tether2.initAirNodePos  = SIM.parameter('Value',initPos + (rotation_sequence(initEulerAngles)*thr2Pt')');
thr.tether2.initGndNodeVel  = SIM.parameter('Value',[0 0 0]);
thr.tether2.initAirNodeVel  = SIM.parameter('Value',initVel);
thr.tether2.diameter        = SIM.parameter('Value',dia_t);
thr.tether2.youngsMod       = SIM.parameter('Value',E);
thr.tether2.dampingRatio    = SIM.parameter('Value',zeta);
thr.tether2.dragCoeff       = SIM.parameter('Value',Cd);
thr.tether2.density         = SIM.parameter('Value',rho_tether);
thr.tether2.vehicleMass     = SIM.parameter('Value',mass);

thr.tether3.numNodes        = SIM.parameter('Value',4);
thr.tether3.initGndNodePos  = SIM.parameter('Value',thr3GndPos);
thr.tether3.initAirNodePos  = SIM.parameter('Value',initPos + (rotation_sequence(initEulerAngles)*thr3Pt')');
thr.tether3.initGndNodeVel  = SIM.parameter('Value',[0 0 0]);
thr.tether3.initAirNodeVel  = SIM.parameter('Value',initVel);
thr.tether3.diameter        = SIM.parameter('Value',dia_t);
thr.tether3.youngsMod       = SIM.parameter('Value',E);
thr.tether3.dampingRatio    = SIM.parameter('Value',zeta);
thr.tether3.dragCoeff       = SIM.parameter('Value',Cd);
thr.tether3.density         = SIM.parameter('Value',rho_tether);
thr.tether3.vehicleMass     = SIM.parameter('Value',mass);

thr = thr.struct('OCT.tether');

createThrAttachPtKinematicsBus

arms(1).posVec = thr1Pt;
arms(2).posVec = thr2Pt;
arms(3).posVec = thr3Pt;

v = 0.6;
vsquared = v^2;
cd = .8;
A = vol^(2/3);
oceanPeriod = 20;

xOn = 0; % 1 = on, 0 = off
zOn = 0;

% full tension
% initPos = [26.4381, 0, 83.0498];
% avg mag
% initPos = [23.77, 0, 85.0695];
    
waveAmp = 3;
wavePeriod = oceanPeriod;
oceanDepth = 115;
sim('groundStation001_th')


%%
dep = get(logsout,7);
figure
dep.Values.plot
subpo = get(logsout,4)
meanz = mean(subpo.Values.Data(3,1,:))
meanx = mean(subpo.Values.Data(1,1,:))

initPos = [meanx, 0, meanz];

oceanDepth = meanz;

sim('groundStation001_th')

figure
dep1 = get(logsout, 7);
dep1.Values.plot


for i = 1:6
    figure(i)
    ylim([-25 5])
end