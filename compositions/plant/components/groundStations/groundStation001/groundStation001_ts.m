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

sim_time = 600;

% number of tethers
N = 4;
sim_param.N = N;

flow = [.1 0 0];

rho = 1000;
vol = 3.5;
h = vol^(1/3);
grav = 9.81;

buoyF = 1.3;
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
CB2CMVec = [0 0 h/4];

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

gndStnMmtArms(1).arm = thr1GndPos;
gndStnMmtArms(2).arm = thr2GndPos;
gndStnMmtArms(3).arm = thr3GndPos;

bodyMmtArms(1).arm = thr1Pt;
bodyMmtArms(2).arm = thr2Pt;
bodyMmtArms(3).arm = thr3Pt;

liftingBodyThrAttch(1).arm = [0 h/2 h/2];
liftingBodyThrAttch(2).arm = [h/2*cosd(30), -h/2*sind(30), h/2];
liftingBodyThrAttch(3).arm = [-h/2*cosd(30), -h/2*sind(30), h/2];

thr(1).N                = sim_param.N;
thr(1).diameter         = dia_t;
thr(1).youngsMod        = E;
thr(1).density          = rho + rho_tether;
thr(1).dragCoeff        = Cd;
thr(1).dampingRatio     = zeta;
thr(1).fluidDensity     = rho;
thr(1).gravAccel        = grav;
thr(1).vehicleMass      = mass;
thr(1).initVhclAttchPt  = initPos + (rotation_sequence(initEulerAngles)*thr1Pt')';
thr(1).initGndStnAttchPt = thr1GndPos;

thr(2).N                = sim_param.N;
thr(2).diameter         = dia_t;
thr(2).youngsMod        = E;
thr(2).density          = rho + rho_tether;
thr(2).dragCoeff        = Cd;
thr(2).dampingRatio     = zeta;
thr(2).fluidDensity     = rho;
thr(2).gravAccel        = grav;
thr(2).vehicleMass      = mass;
thr(2).initVhclAttchPt  = initPos + (rotation_sequence(initEulerAngles)*thr2Pt')';
thr(2).initGndStnAttchPt = thr2GndPos;

thr(3).N                = sim_param.N;
thr(3).diameter         = dia_t;
thr(3).youngsMod        = E;
thr(3).density          = rho + rho_tether;
thr(3).dragCoeff        = Cd;
thr(3).dampingRatio     = zeta;
thr(3).fluidDensity     = rho;
thr(3).gravAccel        = grav;
thr(3).vehicleMass      = mass;
thr(3).initVhclAttchPt  = initPos + (rotation_sequence(initEulerAngles)*thr3Pt')';
thr(3).initGndStnAttchPt = thr3GndPos;

createThrAttachPtKinematicsBus

arms(1).arm = thr1Pt;
arms(2).arm = thr2Pt;
arms(3).arm = thr3Pt;

v = 0.6;
vsquared = v^2;
cd = .8;
A = vol^(2/3);
oceanPeriod = 20;

xOn = 1; % 1 = on, 0 = off
zOn = 1;

% full tension
% initPos = [26.4381, 0, 83.0498];
% avg mag
% initPos = [23.77, 0, 85.0695];
    
waveAmp = 3;
wavePeriod = oceanPeriod;
oceanDepth = 100;
sim('groundStation001_th')

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