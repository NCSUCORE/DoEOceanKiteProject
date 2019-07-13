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

 % one for x direction, two for y direction, three for z direction
 %only for 'flight' 
        directionInt = 1;

% Results visualization parameters
makeAllPlots = true;
makePathPlot = true; % todo generalize path plot so that you are just ploting whatever path was used
makeStretchPlot = true;
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

 timeStep = 1 ; % not for the simulation parameters, just for calculation
 timeVec = 0:.01:simDuration;
 
%% Make end node paths
switch endNodePath
    case 'circle'

        

               [az, el, rho] =  cart2sph(thr.tether1.initAirNodePos.Value(1),thr.tether1.initAirNodePos.Value(2),thr.tether1.initAirNodePos.Value(3));
             
               % going one rotation in the amount of time , keeping elev
               % angle and radius the same 
                azimuthMat = linspace(az,2*pi+az,numel(timeVec)); 
                positionTopNodeSpherical = [azimuthMat;el*ones(1,numel(timeVec));rho*ones(1,numel(timeVec))] ;
                
                positionTopNode = [];
                %converting back to cartesian
                for i = 1:numel(timeVec)
                 positionTopNodeSphericalTemp1 = positionTopNodeSpherical(:,i)';
                 [xNew, yNew, zNew] = sph2cart(positionTopNodeSphericalTemp1(1),positionTopNodeSphericalTemp1(2),positionTopNodeSphericalTemp1(3));
                 positionTopNodeTemp = [xNew;yNew;zNew];
                 positionTopNode = [positionTopNode,positionTopNodeTemp];
                end
                
                deriv = diff(positionTopNode')/timeStep;
                %differentiating position to find velocity
                velocityTopNode = [thr.tether1.initAirNodeVel.Value,deriv'];
 
                    
                endNodePos = timeseries(positionTopNode,timeVec);
                endNodeVel = timeseries(velocityTopNode,timeVec);
                
         
    case 'radial'
       % making you go radially outward from your initial radial position
       % coordinates at a constant velocity
         endNodeStepSize= .07; % how much you want to go outward every timestep
         endNodeRadialLocationStepMat = (thr.tether1.initAirNodePos.Value/norm(thr.tether1.initAirNodePos.Value))* ones(1,numel(timeVec))  ;
         initialEndNodeLocationMat  =  (thr.tether1.initAirNodePos.Value) * ones(1,numel(timeVec)) ; 
         stepMat = linspace(0,.07*numel(timeVec),numel(timeVec)) ;
         addMat = stepMat.*endNodeRadialLocationStepMat;
         positionTopNode =  initialEndNodeLocationMat + addMat;
         velocityTopNode = [];
%          for i = 1:numel(timeVec)
%          velocityTopNodeTemp = constantVelocity*(positionTopNode(:,i)/norm(positionTopNode(:,i)));
%          velocityTopNode = [ velocityTopNode, velocityTopNodeTemp];
%          end
                deriv = diff(positionTopNode')/timeStep;
                %differentiating position to find velocity
                velocityTopNode = [thr.tether1.initAirNodeVel.Value,deriv'];
         
           endNodePos = timeseries(positionTopNode,timeVec);
           endNodeVel = timeseries(velocityTopNode,timeVec);
    case 'flight'
        % step 
        endNodeStepSize = .07;
        stepMat = linspace(0,.07*numel(timeVec),numel(timeVec)) ;
        % one for x direction, two for y direction, three for z direction
        if directionInt ==1
            endNodeGrowthDirection = [1;0;0];
        end 
        if directionInt ==2
            endNodeGrowthDirection = [0;1;0];
        end 
        if directionInt ==3
            endNodeGrowthDirection = [0;0;1];
        end 
        initialEndNodeLocationMat  =  (thr.tether1.initAirNodePos.Value) * ones(1,numel(timeVec)) ; 
        addMat =  stepMat.*endNodeGrowthDirection;
        positionTopNode =  initialEndNodeLocationMat + addMat;
        deriv = diff(positionTopNode')/timeStep;
                %differentiating position to find velocity
                velocityTopNode = [thr.tether1.initAirNodeVel.Value,deriv'];
         
           endNodePos = timeseries(positionTopNode,timeVec);
           endNodeVel = timeseries(velocityTopNode,timeVec);
                  
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
   
    
                      figure;             
                      plot3(positionTopNode(1,:),positionTopNode(2,:), positionTopNode(3,:));
                         hold on 
                     [x,y,z]=sphere;x=tetherLength*x;y=tetherLength*y;z=tetherLength*z;
                      h=surfl(x,y,z);set(h,'FaceAlpha',0.5);shading(gca,'interp')
                 hold off
    
        case 'radialPlot' 
            figure;
                    [x,y,z]=sphere;x=tetherLength*x;y=tetherLength*y;z=tetherLength*z;
                    h=surfl(x,y,z);set(h,'FaceAlpha',0.5);shading(gca,'interp')
                    hold on               
                    line([positionTopNode(1,1);positionTopNode(1,numel(timeVec))],[[positionTopNode(2,1);positionTopNode(2,numel(timeVec))]],[[positionTopNode(3,1);positionTopNode(3,numel(timeVec))]],'LineWidth',2)
                    hold off
        case 'flightPlot'
            %why the heck does it still plot radial plot
                 line([positionTopNode(1,1);positionTopNode(1,numel(timeVec))],[[positionTopNode(2,1);positionTopNode(2,numel(timeVec))]],[[positionTopNode(3,1);positionTopNode(3,numel(timeVec))]],'LineWidth',2)
              
               
        case 'stationaryPlot' 
            
             [x,y,z]=sphere;x=tetherLength*x;y=tetherLength*y;z=tetherLength*z;
                     h=surfl(x,y,z);set(h,'FaceAlpha',0.5);shading(gca,'interp')
                     hold on 
                     scatter3(positionTopNode(:,1),positionTopNode(:,2), positionTopNode(:,3))
                     hold off
            
    otherwise
        error('Unknown endNodePath. You must use one of the paths in the switch block.');
    end
    
%     if savePlots
%         %warning('savePlots not currently funcitonal. All I did was close the figure.');
%        filename1="pathPlot.jpg";
%        filename2="gndNodeTensionPlot.jpg";
%        filename3="endNodeTensionPlot.jpg";
%        filename4="stretchPlot.jpg";
%        
%     end
end % end if makePathPlot

% Tension plot
if makeAllPlots || makeTensionsPlot
    
     figure(2)
tsc.airTenVecBusArry.tenVec.plot
title('Ground Node Tension')
xlabel('Time (s)')
ylabel('Tension (N)')
   figure(3)
tsc.gndTenVecBusArry.tenVec.plot
title('Air Node Tension')
xlabel('Time (s)')
ylabel('Tension (N)')
end

if makeAllPlots || makeStretchPlot
% tetherStretch Plot
figure(4)
stretchMat = [];

for q = 1:numel(timeVec)

    
    stretchTemp = norm(positionTopNode(:,q))-totalUnstchLength;
    stretchMat =  [stretchMat, stretchTemp];
    
end 
  plot(timeVec,stretchMat)
  xlabel('Time (s)')
  ylabel('Stretch (m)')   
     
   
end



