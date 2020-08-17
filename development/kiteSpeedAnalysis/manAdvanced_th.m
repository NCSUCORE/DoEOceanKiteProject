clear
clc
% close all
fIdx = 1;

%% initailize
[a,b] = boothParamConversion(40*pi/180,15*pi/180);      % Path basis parameters
cIn = maneuverabilityAdvanced;
cIn.aBooth = a;
cIn.bBooth = b;
cIn.tetherLength = 60;
cIn.meanElevationInRadians = 30*pi/180;

%% test inertial position calculation
azimuth = 0*pi/180;
elevation = 45*pi/180;
G_rCM = cIn.calcInertialPosition(azimuth,elevation);

%% test apparent velocity calculation
heading = 0*pi/180;
tgtPitch = 0*pi/180;
roll = 0*pi/180;

G_vFlow = [1;0;0];      % flow vel in ground frame
T_vKite = [2;0;0];      % kite vel in tangent (North-East-Down) frame

B_vApp = cIn.calcApparentVelInBodyFrame(G_vFlow,T_vKite,...
    azimuth,elevation,heading,tgtPitch,roll);

%% test angle of attack and side-slip angle calculation
AoA = cIn.calcAngleOfAttackInRadians(B_vApp)*180/pi;
SSA = cIn.calcSideSlipAngleInRadians(B_vApp)*180/pi;

%% test drag and lift direction calculation
uDrag = cIn.calcDragDirection(B_vApp);
uWingLift = cIn.calcHsurfLiftDirection(B_vApp);
uVsLift = cIn.calcVstabLiftDirection(B_vApp);

%% test wing force and moment calculation
cIn.wingChord = 1;
cIn.wingAspectRatio = 10;
cIn.wingAeroCenter = [0.25;0;0];

% wing loads
wingLoads = cIn.calcWingLoads(B_vApp);

%% test h-stab force and moment calculation
cIn.hstabChord = 0.5;
cIn.hstabAspectRatio = 10;
cIn.hstabAeroCenter = [-5;0;0];
cIn.hstabControlSensitivity = 0.08;
elevatorDeflection = 0;

% h-stab loads
hstabLoads = cIn.calchStabLoads(B_vApp,elevatorDeflection);

%% test v-stab force and moment calculation
cIn.vstabChord = 0.5;
cIn.vstabAspectRatio = 10;
cIn.vstabAeroCenter = [-5;0;-0.5];

% v-stab loads
vstabLoads = cIn.calcvStabLoads(B_vApp);

%% test buoyancy force and moment calculation
cIn.buoyFactor = 1.0;
cIn.centerOfBuoy = [0.0;0;0];
cIn.mass = 3e3;

buoyLoads = cIn.calcBuoyLoads(azimuth,elevation,heading,tgtPitch,roll);

%% test gravity force and moment calculation
B_Fgrav = cIn.calcGravForce(azimuth,elevation,heading,tgtPitch,roll);
netWeight = buoyLoads.force + B_Fgrav;

%% test tether force and moment calculation
cIn.bridleLocation = [0;0;0];
thrLoads = cIn.calcTetherLoads(G_vFlow,T_vKite,azimuth,elevation,...
    heading,tgtPitch,roll,elevatorDeflection);

%% test path tangent calculation
pathParam = linspace(0,2*pi,51);
pathAzimAndElev = cIn.pathAndTangentEqs.AzimAndElev(pathParam);
pathCoords      = cIn.pathAndTangentEqs.PathCoords(pathParam);
pathTangents    = cIn.pathAndTangentEqs.PathTangents(pathParam);
reqHeadingAngle = cIn.pathAndTangentEqs.reqHeading(pathParam);

%% test calculation of required roll over the path
H_vKite = 8*G_vFlow;
reqRoll = cIn.calcRequiredRoll(G_vFlow,H_vKite,pathParam);

%% test acheivable velocity calcualtion
solVals = cIn.getAttainableVelocityOverPath(G_vFlow,...
    tgtPitch,pathParam);

%% test pitch stability calculation
% % elevator deflection required to trim
% reqDe = cIn.calcElevatorDefForTrim(G_vFlow,T_vKite,...
%     azimuth,elevation,heading,tgtPitch,roll);

% test pitch stability ananlysis function
tgtPitchSweep = linspace(-20,20,41)*pi/180;
% res = cIn.pitchStabilityAnalysis(G_vFlow,T_vKite,azimuth,elevation,...
%     heading,tgtPitchSweep,roll,elevatorDeflection);

%% test plotting functions
fIdx = fIdx+1;
figure(fIdx);
set(gcf,'Position',[0 0 2*560 2*420]);
cIn.plotAeroCoefficients;


% fIdx = fIdx+1;
% figure(fIdx);
% set(gcf,'Position',[18 417 560 420]);
% cIn.plotDome;
% hold on;
% grid on;
% view(100,35);
% axis equal;
%
% pAxes = cIn.plotBodyFrameAxes(azimuth,elevation,...
%     heading,tgtPitch,roll);
%
% pVels = cIn.plotVelocities(G_vFlow,T_vKite,azimuth,elevation);
% pLem = cIn.plotLemniscate;
% pTanVec = cIn.plotTangentVec(pi/6);
%
% fIdx = fIdx+1;
% figure(fIdx);
% cIn.plotPathRadiusOfCurvature;
%
% fIdx = fIdx+1;
% figure(fIdx);
% cIn.plotPathHeadingAngle;

% fIdx = fIdx+1;
% figure(fIdx);
% set(gcf,'Position',[20 60 560*3 420*2]);
% pTgt = cIn.plotPitchStabilityAnalysisResults(G_vFlow,T_vKite,azimuth,...
%     elevation,heading,tgtPitchSweep,roll,elevatorDeflection);

% fIdx = fIdx+1;
% figure(fIdx);
% cIn.plotRollAngle(pathParam,reqRoll);


%% test animation functions



fIdx = fIdx+10;
figure(fIdx);
set(gcf,'Position',[0 0 560*2.5 420*2]);
cIn.makeFancyAnimation(pathParam,'animate',true,...
    'addKiteTrajectory',true,...
    'rollInRad',solVals.roll_path,...
    'headingVel',solVals.vH_path,...
    'waitForButton',true);

