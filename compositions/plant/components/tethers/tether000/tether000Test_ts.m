% tether000Test_ts.m
% The purpose of this script is to test the tether model
% The goal is to test the tether model as an independent module.
% Try not to unintentionally rely on other model assumptions.
% Only construct objects that are necessary.
% Find 'todo' for tasks that need doing.

%% Set-up test
clear all; close all; clc;

% Test control parameters
simDuration = 20;        % seconds
scaleFactor  = 1;
numNodes = 2;            % REMEMBER increasing the number of nodes increases the stiffness, so you need smaller timesteps and/or lower modulus.
endNodeInitPosition = [55;-55;185;];
endNodeInitVelocity = [-19;0;0];
totalMass = 945.4;       % kg todo change property name to tetherMass in the tether class
totalUnstchLength = 200; % m 
endNodePath = 'radial';  % available: circle, (not currently working: radial, flight, stationary)
includeDrag = true;
includeBuoyancy = true;
includeSpringDamper = true;
constantVelocity = 1;

% Results visualization parameters
makeAllPlots = true;
makePathPlot = true; % todo generalize path plot so that you are just ploting whatever path was used
makeTensionsPlot = false; % todo make a plot of all tensions
endNodePathPlot = 'radialPlot';
savePlots = true; % todo(rodney) add basic saveplot functionality

% Must be in workspace for model to run
tetherLength = totalUnstchLength; % m
duration_s = simDuration;

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
thr.setNumNodes(numNodes,'');
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
thr.tether1.dragEnable.setValue(includeDrag,'');
thr.tether1.netBuoyEnable.setValue(includeBuoyancy,'');
thr.tether1.springDamperEnable.setValue(includeSpringDamper,'');

%% Make end node paths
switch endNodePath
    case 'circle'
        
        oneLoop = 10;  % how fast (in seconds) you want to complete one loop; 
        endPathParametrization = 2*pi*(simDuration/oneLoop); % last value in the path parameterization vector
        %lookupTableResolutionBooster = 100;  %more points in the lookup table
        
        
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
        pathDeriv = double(subs(tangent,{x,latCurve,longCurve,radius},{linspace(0,endPathParametrization,simDuration),pi/2,0,.5}));
        velocityTopNode = constantVelocity*pathDeriv;
        % path and shape generation
        radius = .4; 
        latCurve = 3*pi/8 ; 
        x = linspace(0,endPathParametrization, simDuration ); %path paramitrization 
        longCurve =0; 
        long1 = radius.*(longCurve+cos(x)); %path longitude
        lat1 = radius.*(latCurve+sin(x)); %path latitude
        positionTopNode = totalUnstchLength *  [ cos(long1).*cos(lat1);
                          sin(long1).*cos(lat1);
                          sin(lat1);];
       
        
    case 'radial'
        % todo make line path moving radial to/from ground node
       % error('radial endNodePath not currently opperational');
       
       % making you go radially outward from your initial radial
       % coordinates
       endNodeStepSize= 2;
        endNodeRadialLocationStepMat = (thr.tether1.initAirNodePos.Value/norm(thr.tether1.initAirNodePos.Value))* ones(1,simDuration)  ;
          initialEndNodeLocationMat  =  (thr.tether1.initAirNodePos.Value) * ones(1,simDuration) ; 
                stepMat = 0:endNodeStepSize:endNodeStepSize*simDuration-1 ;
           addMat = stepMat.*endNodeRadialLocationStepMat;
         positionTopNode =  initialEndNodeLocationMat + addMat;
         velocityTopNode =   positionTopNode;
         
    case 'flight'
        % todo make line path moving along the ground
        error('flight endNodePath not currently opperational');
    case 'stationary'
      
        % this is for looking at the wave propegation
        positionTopNode = thr.tether1.initAirNodePos.Value*ones(1,simDuration);
        velocityTopNode = [1;1;1]*zeros(1,simDuration);
    otherwise
        error('Unknown endNodePath. You must use one of the paths in the switch block.');
end

%% Run the simulation
sim('tether000Test1')
    
%% Get results
parseLogsout

%% Visualize the results
% Path plot
if makeAllPlots || makePathPlot
    parseLogsout
    switch endNodePathPlot
        
        case 'circlePlot'
    %plot sphere
    
                      figure(1); 
                      s = linspace(0,endPathParametrization,simDuration);
                      plot3(positionTopNode(1,:),positionTopNode(2,:), positionTopNode(3,:));
                         hold on 
                     [x,y,z]=sphere;x=tetherLength*x;y=tetherLength*y;z=tetherLength*z;
                      h=surfl(x,y,z);set(h,'FaceAlpha',0.5);shading(gca,'interp')
                 for k =1:simDuration
                     tang =(s-s(k)).*pathDeriv(:,k)+positionTopNode(:,k);
                     %velocity plot
                     plot3(tang(1,:), tang(2,:), tang(3,:),'LineWidth',3)
                     pause(.01)
                 end
                     hold off
    
        case 'radialPlot' 
                     [x,y,z]=sphere;x=tetherLength*x;y=tetherLength*y;z=tetherLength*z;
                     h=surfl(x,y,z);set(h,'FaceAlpha',0.5);shading(gca,'interp')
                     hold on 
                     plot3(positionTopNode(:,1),positionTopNode(:,2), positionTopNode(:,3))
                     hold off
        case 'stationaryFlight' 
            
             [x,y,z]=sphere;x=tetherLength*x;y=tetherLength*y;z=tetherLength*z;
                     h=surfl(x,y,z);set(h,'FaceAlpha',0.5);shading(gca,'interp')
                     hold on 
                     scatter3(positionTopNode(:,1),positionTopNode(:,2), positionTopNode(:,3))
                     hold off
            
    otherwise
        error('Unknown endNodePath. You must use one of the paths in the switch block.');
    end
    
    if savePlots
        warning('savePlots not currently funcitonal. All I did was close the figure.');
       % close(hfig);
    end
end % end if makePathPlot

% Tension plot
if makeAllPlots || makeTensionsPlot
    
     figure(2)
tsc.airTenVecBusArry.tenVec.plot
title('Ground Node Tension')
xlabel('time (s)')
ylabel('Tension (N)')
   figure(3)
tsc.gndTenVecBusArry.tenVec.plot
title('Air Node Tension')
xlabel('time (s)')
ylabel('Tension (N)')
     
     
    %error('Tension plot not ready');
end



