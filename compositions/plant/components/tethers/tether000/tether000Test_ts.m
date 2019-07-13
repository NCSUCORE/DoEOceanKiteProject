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
numNodes = 4;            % REMEMBER increasing the number of nodes increases the stiffness, so you need smaller timesteps and/or lower modulus.
%conditions for stationary tether
verticalTether = true;
tetherPerturbationBit = 1; 
numNodesWarning = true;
tetherPerturbationWarning = true;
if numNodesWarning && numNodes >2 
    warning("The number of nodes is %d. If you want more than 2 nodes you can turn this message off in line 16",numNodes)
end

if tetherPerturbationWarning && tetherPerturbationBit == 1  
    warning("Tether perturabtion is turned on. This message can be turned off in line 18")
end

endNodeInitPosition = [55;-55;185;];
endNodeInitVelocity = [-19;0;0];
totalMass = 945.4;       % kg todo change property name to tetherMass in the tether class
totalUnstchLength = 200; % m 
endNodePath = 'stationary';  % available: circle,  radial, flight,(not currently working: stationary)
includeDrag = true;
includeBuoyancy = true;
includeSpringDamper = true;

%one for x direction, two for y direction, three for z direction
%only for 'flight' 
directionInt = 1;

% Results visualization parameters
makeAllPlots = true;
makePathPlot = true; % todo generalize path plot so that you are just ploting whatever path was used
makeStretchPlot = true;
makeTensionsPlot = false; % todo make a plot of all tensions
endNodePathPlot = 'stationaryPlot';
savePlots = true; % todo(rodney) add basic saveplot functionality

% Must be in workspace for model to run
tetherLength = totalUnstchLength; % m
duration_s = simDuration;

%Time parameters for time series
timeStep = 1 ; % not for the simulation parameters, just for calculation
timeVec = 0:.01:simDuration;
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
        
        if verticalTether
        thr.tether1.initAirNodePos.setValue([0;0;200],'m');
        end
        if  tetherPerturbationBit == 1
        %this is hard coding,and there is a better way to do this
        %perturbing node
        nodeToPerturb = 2;
         
        nodePerturbAmount = 1000; %meters
        %where the node was from to begin with
        defaultInitialConditions = thr.tether1.initNodePos.Value;
        %where you are putting it now
        nodeLocationChange = defaultInitialConditions(:,nodeToPerturb) + [0;nodePerturbAmount;0];
        %making the inital conditions for the middle node again
        thr.tether1.initNodePos.setValue([defaultInitialConditions(:,1),nodeLocationChange],'m');
       
        end 
        
        positionTopNode = (thr.tether1.initAirNodePos.Value) * ones(1,numel(timeVec));
        velocityTopNode = [1;1;1]*zeros(1,numel(timeVec));
         endNodePos = timeseries(positionTopNode,timeVec);
         endNodeVel = timeseries(velocityTopNode,timeVec);
              
    otherwise
        error('Unknown endNodePath. You must use one of the paths in the switch block.');
end

%% Run the simulation
sim('tether000Test1')
    
%% Get results
parseLogsout

%% Visualize the results

%cool thing that mitchell did 
% Change anything with "Interpreter" in the name to use Latex formatting
        filename1='pathPlot.png';
        filename2='airNodeTensionPlot.png';
        filename3='grdNodeTensionPlot.png';
        filename4='stretchPlot.png';
props = get(groot, 'factory');
fnames = fieldnames(props);
fnames = fnames(contains(fnames,'interpreter','IgnoreCase',true));
for ii = 1:length(fnames)
   propName = strrep(fnames{ii},'factory','default');
   set(groot,propName,'latex')
end

% Change figure backgrounds to white
set(groot,'defaultfigurecolor','w')

% Path plot
if makeAllPlots || makePathPlot
    parseLogsout
    switch endNodePathPlot
        
        case 'circlePlot'
   
    
            h1 = figure(1);             
                      plot3(positionTopNode(1,:),positionTopNode(2,:), positionTopNode(3,:));
                      hold on 
                     [x,y,z]=sphere;x=tetherLength*x;y=tetherLength*y;z=tetherLength*z;
                      h=surfl(x,y,z);set(h,'FaceAlpha',0.5);shading(gca,'interp')
                      hold off
    
        case 'radialPlot' 
            h1 = figure(1);     
                    [x,y,z]=sphere;x=tetherLength*x;y=tetherLength*y;z=tetherLength*z;
                    h=surfl(x,y,z);set(h,'FaceAlpha',0.5);shading(gca,'interp')
                    hold on               
                    line([positionTopNode(1,1);positionTopNode(1,numel(timeVec))],[[positionTopNode(2,1);positionTopNode(2,numel(timeVec))]],[[positionTopNode(3,1);positionTopNode(3,numel(timeVec))]],'LineWidth',2)
                    hold off
        case 'flightPlot'
            h1 = figure(1);     
                     [x,y,z]=sphere;x=tetherLength*x;y=tetherLength*y;z=tetherLength*z;
                     h=surfl(x,y,z);set(h,'FaceAlpha',0.5);shading(gca,'interp')
                     hold on 
                     line([positionTopNode(1,1);positionTopNode(1,numel(timeVec))],[[positionTopNode(2,1);positionTopNode(2,numel(timeVec))]],[[positionTopNode(3,1);positionTopNode(3,numel(timeVec))]],'LineWidth',2)
                     hold off
                
        case 'stationaryPlot' 
            h1 = figure(1);     
                    [x,y,z]=sphere;x=tetherLength*x;y=tetherLength*y;z=tetherLength*z;
                     h=surfl(x,y,z);set(h,'FaceAlpha',0.5);shading(gca,'interp')
                     hold on 
                     line([0;positionTopNode(1,numel(timeVec))],[[0;positionTopNode(2,numel(timeVec))]],[[0;positionTopNode(3,numel(timeVec))]],'LineWidth',2)
                     hold off
            
    otherwise
        error('Unknown endNodePath. You must use one of the paths in the switch block.');
    end
    

end % end if makePathPlot


% Tension plot
if makeAllPlots || makeTensionsPlot
    
   h2 =  figure(2);
%tsc.airTenVecBusArry.tenVec.plot
plotTime = linspace(0,simDuration,length(squeeze(tsc.airTenVecBusArry.tenVec.data)'));
plot(plotTime,squeeze(tsc.airTenVecBusArry.tenVec.data)') ;
title('Air Node Tension')
xlabel('Time (s)')
ylabel('Tension (N)')

   h3 = figure(3);
%tsc.gndTenVecBusArry.tenVec.plot
plotTime = linspace(0,simDuration,length(squeeze(tsc.gndTenVecBusArry.tenVec.data)'));
plot(plotTime,squeeze(tsc.gndTenVecBusArry.tenVec.data)') ;
title('Ground Node Tension')
xlabel('Time (s)')
ylabel('Tension (N)')
end

if makeAllPlots || makeStretchPlot
% tetherStretch Plot
    h4 = figure(4);
    stretchMat = [];

for q = 1:numel(timeVec)

    
    stretchTemp = norm(positionTopNode(:,q))-totalUnstchLength;
    stretchMat =  [stretchMat, stretchTemp];
    
end 
  plot(timeVec,stretchMat)
  title( 'Tether Stretch')
  xlabel('Time (s)')
  ylabel('Stretch (m)')   
     
   
end
     if savePlots
         
         if makeAllPlots
      saveas(h1,filename1)
      saveas(h2,filename2)
      saveas(h3,filename3)
      saveas(h4,filename4)
         end 
         if ~makeAllPlots
             if makeTensionsPlot
                 saveas(h2,filename2)
                 saveas(h3,filename3)
             end
             if makePathPlot
                 saveas(h1,filename1)
             end
             if makeStretchPlot
                 saveas(h4,filename4)
             end
             
         end
    end


