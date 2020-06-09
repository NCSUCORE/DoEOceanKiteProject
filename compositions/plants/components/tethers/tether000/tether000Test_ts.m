% tether000Test_ts.m
% The purpose of this script is to test the tether model
% The goal is to test the tether model as an independent module.
% Try not to unintentionally rely on other model assumptions.
% Only construct objects that are necessary.
% Find 'todo' for tasks that need doing.

%% Set-up test
clear all; close all; clc;

% Test control parameters
simDuration = 30;        % seconds
timeMod = 4; % to modify periods and travel times (ex. circle is timeMod loops per simDuration)
scaleFactor  = 1;
numNodes = 2;            % REMEMBER increasing the number of nodes increases the stiffness, so you need smaller timesteps and/or lower modulus.
%conditions for stationary tether
verticalTether = true;
tetherPerturbationBit = 1; 
numNodesWarning = true;
tetherPerturbationWarning = false;
if numNodesWarning && numNodes >2 
    warning("The number of nodes is %d. If you want more than 2 nodes you can turn this message off in line 16",numNodes)
end

if tetherPerturbationWarning && tetherPerturbationBit == 1
    warning("Tether perturabtion is turned on. This message can be turned off in line 18")
end

endNodeInitPosition = [180;0;180];
endNodeInitVelocity = [0;0;0];
totalMass = 1000;       % kg todo change property name to tetherMass in the tether class
totalUnstchLength = 200; % m 
endNodePath = 'circle';  % available: circle,  radial, flight,(not currently working: stationary)
includeDrag = true;
includeBuoyancy = true;
includeSpringDamper = false;
tetherModulus = 10e9;

%one for x direction, two for y direction, three for z direction
%only for 'flight' 
directionInt = 1;

% Results visualization parameters
makeMovie = true;
makeAllPlots = false;
makePathPlot = true; % todo generalize path plot so that you are just ploting whatever path was used
makeStretchPlot = true;
makeTensionsPlot = true; % todo make a plot of all tensions
% endNodePathPlot = 'stationaryPlot'; 
savePlots = true; % todo(rodney) add basic saveplot functionality

% Must be in workspace for model to run
tetherLength = totalUnstchLength; % m
duration_s = simDuration;

%Time parameters for time series
timeStep = 1 ; % not for the simulation parameters, just for calculation
timeVec = 0:.01:simDuration;

%% Create busses
createThrTenVecBus
thrAttachPtKinematics_bc
createConstantUniformFlowEnvironmentBus

%% Construct objects
% environment
env = ENV.env;
env.addFlow({'water'},'FlowDensities',1000);
env.water.velVec.setValue([5 0 0],'m/s');
env.scale(scaleFactor);

% Make a vehicle solely for the tether2 diameter method.
vhcl = OCT.vehicle;
vhcl.numTethers.setValue(1,'');
vhcl.numTurbines.setValue(2,'');
vhcl.build('partDsgn1_lookupTables.mat');
vhcl.Ixx.setValue(6303,'kg*m^2');
vhcl.Iyy.setValue(2080.7,'kg*m^2');
vhcl.Izz.setValue(8320.4,'kg*m^2');
vhcl.Ixy.setValue(0,'kg*m^2');
vhcl.Ixz.setValue(81.87,'kg*m^2');
vhcl.Iyz.setValue(0,'kg*m^2');
vhcl.volume.setValue(0.9454,'m^3');
vhcl.mass.setValue(945.4,'kg'); 
vhcl.centOfBuoy.setValue([0 0 0]','m');
vhcl.thrAttch1.posVec.setValue([0 0 0]','m');
vhcl.turbine1.diameter.setValue(0,'m');
vhcl.turbine1.axisUnitVec.setValue([1 0 0]','');
vhcl.turbine1.attachPtVec.setValue([-1.25 -5 0]','m');
vhcl.turbine1.powerCoeff.setValue(0.5,'');
vhcl.turbine1.dragCoeff.setValue(0.8,'');
vhcl.turbine2.diameter.setValue(0,'m');
vhcl.turbine2.axisUnitVec.setValue([1 0 0]','');
vhcl.turbine2.attachPtVec.setValue([-1.25  5 0]','m');
vhcl.turbine2.powerCoeff.setValue(0.5,'');
vhcl.turbine2.dragCoeff.setValue(0.8,'');
vhcl.scale(scaleFactor);

% tether
% Define variants then make tether object
TETHERS = 'tether000';             % Is this which tether model to use?
VARIANTSUBSYSTEM = 'NNodeTether';  % And this is which variant to use? Do the variante subsystems depend on the model? If so, is there a way to take burden of knowledge off of the developer/user? Maybe a GUI?
thr = OCT.tethers;
thr.setNumTethers(1,'');
thr.setNumNodes(numNodes,'');
thr.build;
thr.tether1.initGndNodePos.setValue([0;0;0],'m');
thr.tether1.initAirNodePos.setValue(endNodeInitPosition,'m');
thr.tether1.initGndNodeVel.setValue([0 0 0]','m/s');
thr.tether1.initAirNodeVel.setValue(endNodeInitVelocity,'m/s');
thr.tether1.vehicleMass.setValue(totalMass,'kg');
thr.tether1.youngsMod.setValue(tetherModulus,'Pa');
thr.tether1.dampingRatio.setValue(0.75,'');
thr.tether1.dragCoeff.setValue(0.5,'');
thr.tether1.density.setValue(1300,'kg/m^3');
createThrNodeBus(thr.numNodes.Value); % Can this not be a class method? 
thr.tether1.setDragEnable(true,'');
thr.tether1.setSpringDamperEnable(true,'');
thr.tether1.setNetBuoyEnable(true,'');
%thr.tether1.diameter.setValue(0.0144,'m');
thr.designTetherDiameter(vhcl,env);
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
        azimuthMat = linspace(az,2*pi*timeMod+az,numel(timeVec));
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
            %perturbing node
            nodeToPerturb = 2; % Cannot be ground or end
            nodePerturbAmount = [0;1000;0]; %meters
            defaultInitialConditions = thr.tether1.initNodePos.Value;
            defaultInitialConditions(:,nodeToPerturb-1)=nodePerturbAmount;
            thr.tether1.setInitNodePos(defaultInitialConditions,'m');
            %thr.tether1.initNodePos.setValue([defaultInitialConditions(:,1),nodeLocationChange],'m');
        end
        positionTopNode = (thr.tether1.initAirNodePos.Value) * ones(1,numel(timeVec));
        velocityTopNode = [1;1;1]*zeros(1,numel(timeVec));
        endNodePos = timeseries(positionTopNode,timeVec);
        endNodeVel = timeseries(velocityTopNode,timeVec);
    otherwise
        error('Unknown endNodePath. You must use one of the paths in the switch block.');
end % end switch endNodePath

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
w = 600; h = 400;
if makeAllPlots || makePathPlot
    hfig = figure('Position',[700 400 w h]);
    plot3(positionTopNode(1,:),positionTopNode(2,:), positionTopNode(3,:));
    % If/when it becomes possible to specify a path for internal nodes
    % we'll add that.
    axis([-1.1*max(max(abs(positionTopNode(1,:))),max(abs(positionTopNode(2,:)))) 1.1*max(max(abs(positionTopNode(1,:))),max(abs(positionTopNode(2,:))))...
            -max(max(abs(positionTopNode(1,:))),max(abs(positionTopNode(2,:)))) 1.1*max(max(abs(positionTopNode(1,:))),max(abs(positionTopNode(2,:))))...
            0 1.1*max(abs(positionTopNode(3,:)))]);
    aa = gca;
    aa.DataAspectRatio = [1 1 max(abs(positionTopNode(3,:)))/max(max(abs(positionTopNode(1,:))),max(abs(positionTopNode(2,:))))];
    view(-50,15);
    title(['Path = ' endNodePath]);
    xlabel('x (m)'); ylabel('y (m)'); zlabel('z (m)');
    if savePlots
        % todo switch to export_fig if we actually need to use these
        if ~exist('dump','dir')
            mkdir('dump');
        end
        saveas(hfig,['dump\' endNodePath '_drag' num2str(includeDrag) '_buoy' num2str(includeBuoyancy) '_spring' num2str(includeSpringDamper) '_mod' num2str(tetherModulus,'%3.2e') '.png']);
    end
end % end if makePathPlot

% Tension plot
if makeAllPlots || makeTensionsPlot
    hfig = figure('Position',[100 100 w h]);
    plotTime = tsc.gndTenVecBusArry.tenVec.Time;
    tension = squeeze(tsc.airTenVecBusArry.tenVec.data);
    plot(plotTime,tension);
    hold on
    plot(plotTime,vecnorm(tension),'--k');
    hold off
    legend({'x','y','z','mag'},'Location','best');
    title(['Air Node Tension | Drag:' num2str(includeDrag) ' Buoy:' num2str(includeBuoyancy) ' Spring:' num2str(includeSpringDamper)]);
    xlabel('Time (s)'); ylabel('Tension (N)');
    if savePlots
        % todo switch to export_fig if we actually need to use these
        if ~exist('dump','dir')
            mkdir('dump');
        end
        saveas(hfig,['dump\airtension_' endNodePath '_drag' num2str(includeDrag) '_buoy' num2str(includeBuoyancy) '_spring' num2str(includeSpringDamper) '_mod' num2str(tetherModulus,'%3.2e') '.png']);
    end

    hfig = figure('Position',[700 100 w h]);
    tension = squeeze(tsc.airTenVecBusArry.tenVec.data);
    plot(plotTime,tension);
    hold on
    plot(plotTime,vecnorm(tension),'--k');
    hold off
    legend({'x','y','z','mag'},'Location','best');
    title(['Ground Node Tension | Drag:' num2str(includeDrag) ' Buoy:' num2str(includeBuoyancy) ' Spring:' num2str(includeSpringDamper)]);
    xlabel('Time (s)'); ylabel('Tension (N)');
    if savePlots
        % todo switch to export_fig if we actually need to use these
        if ~exist('dump','dir')
            mkdir('dump');
        end
        saveas(hfig,['dump\gndtension_' endNodePath '_drag' num2str(includeDrag) '_buoy' num2str(includeBuoyancy) '_spring' num2str(includeSpringDamper) '_mod' num2str(tetherModulus,'%3.2e') '.png']);
    end
end

if makeAllPlots || makeStretchPlot
    % tetherStretch Plot
    hfig = figure('Position',[100 400 w h]);
    stretchMat = [];    
    for q = 1:numel(timeVec)
        stretchTemp = norm(positionTopNode(:,q))-totalUnstchLength;
        stretchMat =  [stretchMat, stretchTemp];        
    end
    plot(timeVec,stretchMat)
    title( 'Tether Stretch')
    xlabel('Time (s)')
    ylabel('Stretch (m)')
    if savePlots
        % todo switch to export_fig if we actually need to use these
        if ~exist('dump','dir')
            mkdir('dump');
        end
        saveas(hfig,['dump\stretch_' endNodePath '_drag' num2str(includeDrag) '_buoy' num2str(includeBuoyancy) '_spring' num2str(includeSpringDamper) '_mod' num2str(tetherModulus,'%3.2e') '.png']);
    end
end

if makeMovie
    temp = tsc.thrNodeBus.nodePositions.Data;
    hfig = figure('Position',[700 600 w h]);
    for i=1:1:numel(tsc.thrNodeBus.nodePositions.Time)
        for j = 1:1:numNodes
            plot3(temp(1,j,i),temp(2,j,i),temp(3,j,i),'*k');
            hold on
        end        
        axis([-1.1*max(abs(temp(2,end,end)),abs(temp(1,end,end))) 1.1*max(abs(temp(2,end,end)),abs(temp(1,end,end)))...
            -1.1*max(abs(temp(2,end,end)),abs(temp(1,end,end))) 1.1*max(abs(temp(2,end,end)),abs(temp(1,end,end)))...
            0 1.1*abs(temp(3,end,end))]);
        view(-50,15);
        title(['Path = ' endNodePath]);
        xlabel('x (m)'); ylabel('y (m)'); zlabel('z (m)');
        frms(i) = getframe(hfig);
        hold off
    end
    if ~exist('dump','dir')
        mkdir('dump');
    end
    writerObj = VideoWriter(['dump\' endNodePath '_drag' num2str(includeDrag) '_buoy' num2str(includeBuoyancy) '_spring' num2str(includeSpringDamper) '_mod' num2str(tetherModulus,'%3.2e') '.avi']);
    writerObj.FrameRate = 10;
    open(writerObj);
    writeVideo(writerObj, frms);
    close(writerObj);
end