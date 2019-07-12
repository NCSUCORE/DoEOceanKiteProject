% tether000Test_ts.m
% The purpose of this script is to test the tether model
% The goal is to test the tether model as an independent module.
% Try not to unintentionally rely on other model assumptions.
% Only construct objects that are necessary.
% Find 'todo' for tasks that need doing.

%% Set-up test
clearvars; close all; clc;

% Test control parameters
scaleFactor  = 1;
endNodeInitPosition = [55;-55;185;];
endNodeInitVelocity = [-19;0;0];
totalMass = 945.4;       % kg
totalUnstchLength = 200; % m
endNodePath = 'circle';  % available: circle, (not currently working: radial, flight, stationary)

% Results visualization parameters
makeAllPlots = false;
makePathPlot = true; % todo generalize path plot so that you are just ploting whatever path was used
makeTensionsPlot = false; % todo make a plot of all tensions
savePlots = true; % todo(rodney) add basic saveplot functionality

% Must be in workspace for model to run
tetherLength = totalUnstchLength; % m

%% Create busses
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

% tether
% Define variants then make tether object
TETHERS = 'tether000';             % Is this which tether model to use?
VARIANTSUBSYSTEM = 'NNodeTether';  % And this is which variant to use? Do the variante subsystems depend on the model? If so, is there a way to take burden of knowledge off of the developer/user? Maybe a GUI?
thr = OCT.tethers;
thr.setNumTethers(1,'');
thr.setNumNodes(2,'');
thr.build;
thr.tether1.initGndNodePos.setValue(groundStation,'m');
thr.tether1.initAirNodePos.setValue(endNodeInitPosition,'m');
thr.tether1.initGndNodeVel.setValue([0 0 0]','m/s');
thr.tether1.initAirNodeVel.setValue(endNodeInitVelocity,'m/s');
thr.tether1.vehicleMass.setValue(totalMass,'kg');
thr.tether1.youngsMod.setValue(4e9,'Pa');
thr.tether1.dampingRatio.setValue(0.75,'');
thr.tether1.dragCoeff.setValue(0.5,'');
thr.tether1.density.setValue(1300,'kg/m^3');
createThrNodeBus(thr.numNodes.Value); % Can this not be a class method?
thr.tether1.setDragEnable(true,'');
thr.tether1.setSpringDamperEnable(true,'');
thr.tether1.setNetBuoyEnable(true,'');
thr.tether1.diameter.setValue(0.0144,'m');
thr.scale(scaleFactor);

%% Make end node paths
switch endNodePath
    case 'circle'
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
        % path and shape generation
        radius = .4; 
        latCurve = 3*pi/8 ; 
        x = linspace(0,2*pi, 100);%path paramitrization 
        longCurve =0; 
        long1 = radius.*(longCurve+cos(x)); %path longitude
        lat1 = radius.*(latCurve+sin(x)); %path latitude
        positionTopNode = totalUnstchLength *  [ cos(long1).*cos(lat1);
                          sin(long1).*cos(lat1);
                          sin(lat1);];
        radialVelocityBit = 1; 
        constantVelocity = 1;
    case 'radial'
        % todo make line path moving radial to/from ground node
        error('radial endNodePath not currently opperational');
    case 'flight'
        % todo make line path moving along the ground
        error('flight endNodePath not currently opperational');
    case 'stationary'
        % todo make it so that the end point is stationary
        % this is for looking at the wave propegation
        error('stationary endNodePath not currently opperational');
    otherwise
        error('Unknown endNodePath. You must use one of the paths in the switch block.');
end

%% Run the simulation
sim('tether000Test1')
    
%% Visualize the results
% Path plot
if makeAllPlots || makePathPlot
    % todo generalize path plot so that you are just ploting whatever path was used
    %plot sphere
    theta = linspace(0, 2*pi);
    phi = linspace(-pi/2 , pi/2); 
    [theta, phi] = meshgrid(theta, phi); 
    rho = 1; 
    [x,y,z] = sph2cart(theta, phi, rho);
    hfig = figure;
    s = linspace(0,2*pi, 100);
    plot3(positionTopNode(1,:),positionTopNode(2,:), positionTopNode(3,:));
    hold on 
    theta = linspace(0, 2*pi);
    phi = linspace(-pi/2 , pi/2); 
    [theta, phi] = meshgrid(theta, phi); 
    rho = 200; 
    for k = 1:100
        tang =(s-s(k)).*pathDeriv(:,k)+positionTopNode(:,k);
        %velocity plot
        plot3(tang(1,:), tang(2,:), tang(3,:),'LineWidth',3)
        pause(.01)
    end
    hold off
    if savePlots
        warning('savePlots not currently funcitonal. All I did was close the figure.');
        close(hfig);
    end
end % end if makePathPlot

% Tension plot
if makeAllPlots || makeTensionsPlot
    % todo make a plot of all tensions
    error('Tension plot not ready');
end



