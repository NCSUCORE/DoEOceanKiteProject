% Created example test script for Erin -MC

close all;clear;clc
load('mag.mat')
load('pos.mat')

sim_time = 10;

createThreeTetherThreeSurfaceCtrlBus
createConstantUniformFlowEnvironmentBus
thrAttachPtKinematics_bc
createThrTenVecBus

% Platform dynamic parameters
platformMass = 1000*3.5;
platformVolume = 3.5;
objectHeight = platformVolume^(1/3);
platformInertiaMatrix = ((1/6)*platformMass*platformVolume^(2/3)).*eye(3);
initPos = [0 0 100];
initVel = [0 0 0];
initEulAng = [0 0 0]; % Rad
initAngVel = [0 0 0]; % Rad per sec

% Ocean driving force parameters
waveAmp    = 0;
oceanDepth = 100;
wavePeriod = 1;

% Vectors from CoM to anchor tether attachment point, in body/platform frame
anchThrPltfrm(1).posVec = [5 0 0]';
anchThrPltfrm(2).posVec = rotation_sequence([0 0 120]*pi/180)*[5 0 0]';
anchThrPltfrm(3).posVec = rotation_sequence([0 0 -120]*pi/180)*[5 0 0]';

% Vector from ground fixed origin to tether attachment point, in ground frame
anchThrGnd(1).posVec = [100 0 0]';
anchThrGnd(2).posVec = rotation_sequence([0 0 120]*pi/180)*[100 0 0]';
anchThrGnd(3).posVec = rotation_sequence([0 0 -120]*pi/180)*[100 0 0]';

% Vector from CoM to airborne tether attachment point, body/platform frame
airbThrPltfrm(1).posVec = [0 0 10];

% Anchor tether parameters
thrs = OCT.tethers;
thrs.numTethers.setValue(3,'');
thrs.numNodes.setValue(5,'')
thrs.build;

thrs.tether1.initGndNodePos.setValue(anchThrGnd(1).posVec,'m');
thrs.tether1.initAirNodePos.setValue(initPos(:)+anchThrPltfrm(1).posVec(:),'m');
thrs.tether1.initGndNodeVel.setValue([0 0 0],'m/s');
thrs.tether1.initAirNodeVel.setValue([0 0 0],'m/s');
thrs.tether1.diameter.setValue(0.015,'m');
thrs.tether1.youngsMod.setValue(20e9,'Pa');
thrs.tether1.dampingRatio.setValue(0.5,'');
thrs.tether1.dragCoeff.setValue(0.5,'');
thrs.tether1.density.setValue(1300,'kg/m^3');
thrs.tether1.vehicleMass.setValue(6000,'kg');
thrs.tether1.setDragEnable(true,'');
thrs.tether1.setSpringDamperEnable(true,'');
thrs.tether1.setNetBuoyEnable(true,'');

thrs.tether2.initGndNodePos.setValue(anchThrGnd(2).posVec,'m');
thrs.tether2.initAirNodePos.setValue(initPos(:)+anchThrPltfrm(2).posVec(:),'m');
thrs.tether2.initGndNodeVel.setValue([0 0 0],'m/s');
thrs.tether2.initAirNodeVel.setValue([0 0 0],'m/s');
thrs.tether2.diameter.setValue(0.015,'m');
thrs.tether2.youngsMod.setValue(20e9,'Pa');
thrs.tether2.dampingRatio.setValue(0.5,'');
thrs.tether2.dragCoeff.setValue(0.5,'');
thrs.tether2.density.setValue(1300,'kg/m^3');
thrs.tether2.vehicleMass.setValue(6000,'kg');
thrs.tether2.setDragEnable(true,'');
thrs.tether2.setSpringDamperEnable(true,'');
thrs.tether2.setNetBuoyEnable(true,'');

thrs.tether3.initGndNodePos.setValue(anchThrGnd(3).posVec,'m');
thrs.tether3.initAirNodePos.setValue(initPos(:)+anchThrPltfrm(3).posVec(:),'m');
thrs.tether3.initGndNodeVel.setValue([0 0 0],'m/s');
thrs.tether3.initAirNodeVel.setValue([0 0 0],'m/s');
thrs.tether3.diameter.setValue(0.015,'m');
thrs.tether3.youngsMod.setValue(20e9,'Pa');
thrs.tether3.dampingRatio.setValue(0.5,'');
thrs.tether3.dragCoeff.setValue(0.5,'');
thrs.tether3.density.setValue(1300,'kg/m^3');
thrs.tether3.vehicleMass.setValue(6000,'kg');
thrs.tether3.setDragEnable(true,'');
thrs.tether3.setSpringDamperEnable(true,'');
thrs.tether3.setNetBuoyEnable(true,'');

tetherLengths(1) = norm(thrs.tether1.initAirNodePos.Value - thrs.tether1.initGndNodePos.Value);
tetherLengths(2) = norm(thrs.tether2.initAirNodePos.Value - thrs.tether2.initGndNodePos.Value);
tetherLengths(3) = norm(thrs.tether3.initAirNodePos.Value - thrs.tether3.initGndNodePos.Value);

env = ENV.env;
env.addFlow({'water'},'FlowDensities',1000);
env.water.velVec.setValue([1 0 0],'m/s');
grav = env.gravAccel.Value;
rho = env.water.density.Value;

sim('groundStation001_th')

parseLogsout



%%
% Plot position
subplot(3,1,1)
plot(tsc.subBodyPos.Time,squeeze(tsc.subBodyPos.Data(1,:,:)))
grid on
xlabel('Time, t [s]')
ylabel('X Pos [m]')

subplot(3,1,2)
plot(tsc.subBodyPos.Time,squeeze(tsc.subBodyPos.Data(2,:,:)))
grid on
xlabel('Time, t [s]')
ylabel('Y Pos [m]')

subplot(3,1,3)
plot(tsc.subBodyPos.Time,squeeze(tsc.subBodyPos.Data(3,:,:)))
grid on
xlabel('Time, t [s]')
ylabel('Z Pos [m]')

% Plot Euler angles
subplot(3,1,1)
plot(tsc.subBodyPos.Time,squeeze(tsc.eulerAngles.Data(1,:,:))*180/pi)
grid on
xlabel('Time, t [s]')
ylabel('Roll, [deg]')

subplot(3,1,2)
plot(tsc.subBodyPos.Time,squeeze(tsc.eulerAngles.Data(2,:,:))*180/pi)
grid on
xlabel('Time, t [s]')
ylabel('Pitch, [deg]')

subplot(3,1,3)
plot(tsc.subBodyPos.Time,squeeze(tsc.eulerAngles.Data(3,:,:))*180/pi)
grid on
xlabel('Time, t [s]')
ylabel('Yaw, [deg]')

% Animate some stuff

timeStep = 0.1;

% Resample data to the animation framerate
timeVec = 0:timeStep:tsc.subBodyPos.Time(end);
numTethers = numel(tsc.anchThrNodeBusArry);
for ii= 1:numTethers
    tsc.anchThrNodeBusArry(ii).nodePositions = resample(tsc.anchThrNodeBusArry(ii).nodePositions,timeVec);
    tsc.subBodyPos = resample(tsc.subBodyPos,timeVec);
end   


h.fig = figure; % Create figure
h.fig.Position = [1          41        1920         963]; % Set to full screen (1920 pixel display)

% Plot a bunch of stuff at the first time step
% Plot the position
h.position = scatter3(...
    tsc.subBodyPos.Data(1,:,1),...
    tsc.subBodyPos.Data(2,:,1),...
    tsc.subBodyPos.Data(3,:,1),...
    'CData',[1 0 0],'Marker','o','LineWidth',1.5);

grid on
hold on
set(gca,'DataAspectRatio',[1 1 1]);
for ii = 1:numTethers
h.thr(ii) = plot3(...
    tsc.anchThrNodeBusArry(ii).nodePositions.Data(1,:,1),...
    tsc.anchThrNodeBusArry(ii).nodePositions.Data(2,:,1),...
    tsc.anchThrNodeBusArry(ii).nodePositions.Data(3,:,1),...
    'Color','k','Marker','o','LineWidth',1.5);
hold on
end
h.title = title(sprintf('Time = %d',tsc.subBodyPos.Time(1)));

set(gca,'FontSize',24)

for ii = 2:numel(timeVec)
    
    % Update the position dot
    h.position.XData = tsc.subBodyPos.Data(1,:,ii);
    h.position.YData = tsc.subBodyPos.Data(2,:,ii);
    h.position.ZData = tsc.subBodyPos.Data(3,:,ii);
    
    % Update the tether geometry
    for jj = 1:numTethers
        h.thr(jj).XData = tsc.anchThrNodeBusArry(jj).nodePositions.Data(1,:,ii);
        h.thr(jj).YData = tsc.anchThrNodeBusArry(jj).nodePositions.Data(2,:,ii);
        h.thr(jj).ZData = tsc.anchThrNodeBusArry(jj).nodePositions.Data(3,:,ii);
    end
    
    % Update the title
    h.title.String = sprintf('Time = %d',tsc.subBodyPos.Time(ii));
    
    drawnow
    
end