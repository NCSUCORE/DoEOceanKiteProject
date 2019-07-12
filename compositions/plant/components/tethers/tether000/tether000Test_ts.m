% tether000Test_ts.m
% The purpose of this script is to test the tether model
% The goal is to test the tether model as an independent module.
% Try not to unintentionally rely on other model assumptions
clearvars; close all; clc;

% Simulation control parameters
scaleFactor  = 1;

%% create busses
createThrTenVecBus
createThrAttachPtKinematicsBus
createConstantUniformFlowEnvironmentBus

%% Construct objects
% environment
env = ENV.env;
env.addFlow({'water'},'FlowDensities',1000);
env.water.velVec.setValue([1 0 0],'m/s');
env.scale(scaleFactor);

% ground station
groundStation = [0;0;0];

%vehicles initial position in ground frame

%% Does this stuff need to be in the workspace in order for the model to run?
% If so, I'd recommend init methods on the appropriate classes that put the
% variables into the workspace. The whole point is to take the burden of
% knowing what is supposed to be there off of the developers.
vehicleInitialPositionGround = 100*[0.541196100146197;-0.541196100146197;1.847759065022573;];
vehicleInitialEulerAngles = [-0.392699081698724  0  -2.356194490192345];
bodyAttachmentPoint = [0;0;0]; % attachment point on the vehicle in the body frame
vehicleInitialVelocity = [-19;0;0];  % vehicle initial velocity
vehicleMass = 945.4; % vehicle mass
rho = 1000;  % water density
grav = 9.81; % gravity
tetherLength = 200; % tether length

%% Define Variants
TETHERS = 'tether000';
VARIANTSUBSYSTEM = 'NNodeTether';

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
thr.tether1.diameter.setValue(0.0144,'m');

% Scale up/down
thr.scale(scaleFactor);
%% circular position
syms radius latCurve longCurve x

long= radius.*(longCurve+cos(x)); %path longitude
lat= radius.*(latCurve+sin(x)); %path latitude

%derivatives of phi and lambda with respect to s 
dLambdadS = diff(long,x);
dPhidS = diff(lat,x);

% partial derivatives of gamma with respect to lambda and phi and lambd
syms lambda phi
path = [ cos(lambda).*cos(phi);
         sin(lambda).*cos(phi);
         sin(phi);]; % figure 8 parameter
partialGammaWrtLambda = diff(path,lambda);
partialGammaWrtPhi = diff(path,phi);

% partial derivatives of gamma with respect to lambda and phi and lambda
% and phi plugged in
partialGammaWrtLambda_g = subs(partialGammaWrtLambda,{lambda,phi},{long,lat});
partialGammaWrtPhi_g = subs(partialGammaWrtPhi,{lambda,phi},{long,lat});


tangent = partialGammaWrtLambda_g* dLambdadS + partialGammaWrtPhi_g*dPhidS;




pathDeriv = double(subs(tangent,{x,latCurve,longCurve,radius},{linspace(0,2*pi,100),pi/2,0,.5}));
velocityTopNode = pathDeriv;
%% path and shape generation
radius = .4; 
latCurve = 3*pi/8 ; 
x = linspace(0,2*pi, 100);%path paramitrization 
longCurve =0; 
long1 = radius.*(longCurve+cos(x)); %path longitude
lat1 = radius.*(latCurve+sin(x)); %path latitude

positionTopNode = tetherLength *  [ cos(long1).*cos(lat1);
                  sin(long1).*cos(lat1);
                  sin(lat1);];

radialVelocityBit = 1; 
constantVelocity = 1;

%% simulate
sim('tether000Test1')

    
%% Viz Results

%plot sphere
theta = linspace(0, 2*pi);
phi = linspace(-pi/2 , pi/2); 
[theta, phi] = meshgrid(theta, phi); 
rho = 1; 
[x,y,z] = sph2cart(theta, phi, rho);
surf(x,y,z)

% tangent to path Graphic
s = linspace(0,2*pi, 100);
plot3(positionTopNode(1,:),positionTopNode(2,:), positionTopNode(3,:))
hold on 
theta = linspace(0, 2*pi);
phi = linspace(-pi/2 , pi/2); 
[theta, phi] = meshgrid(theta, phi); 
rho = 200; 
%[x,y,z] = sph2cart(theta, phi, rho);
%surf(x,y,z)
hold on
for k = 1:100

tang =(s-s(k)).*pathDeriv(:,k)+positionTopNode(:,k);
%velocity plot
plot3(tang(1,:), tang(2,:), tang(3,:),'LineWidth',3)
pause(.01)
end



