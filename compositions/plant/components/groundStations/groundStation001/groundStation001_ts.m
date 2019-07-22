close all;clc

load('mag.mat')
load('pos.mat')
% run this to load tether tension data %
% clear

% run this to set magnitude to zero %
mag.Data = zeros;

% % run this to set magnitude to average magnitude %
% mag.Data = mean(mag.Data)*ones(size(mag.Data));
% 
% % run this to set average direction %
% for i = 1:3
%     position.Data(:,i) = mean(position.Data(:,i))*ones(size(position.Data(:,i)));
% end

% create buses
createThreeTetherThreeSurfaceCtrlBus
createConstantUniformFlowEnvironmentBus
createThrAttachPtKinematicsBus
createThrTenVecBus

% simulation time
sim_time = 300;

% geometry of platform
platformVolume = 3.5;
objectHeight = platformVolume^(1/3);
% platform properties
buoyF = 1.5;
platformMass = 1000*platformVolume/buoyF;
platformInertiaMatrix = ((1/6)*platformMass*objectHeight^2).*eye(3);

% initial conditions
initPos = [0 0 100];
initVel = [1e-3 0 0];
initEulAng = (pi/180).*[0 0 0];
initAngVel = [0 0 0];

%
vhcl = OCT.vehicle;
vhcl.mass.setValue(platformMass,'kg');
vhcl.volume.setValue(platformVolume,'m^3');
vhcl.Ixx.setValue(platformInertiaMatrix(1,1),'kg*m^2');
vhcl.Iyy.setValue(platformInertiaMatrix(2,2),'kg*m^2');
vhcl.Izz.setValue(platformInertiaMatrix(3,3),'kg*m^2');
vhcl.Ixy.setValue(0,'kg*m^2');
vhcl.Ixz.setValue(0,'kg*m^2');
vhcl.Iyz.setValue(0,'kg*m^2');
vhcl.setICs('InitPos',initPos,'InitEulAng',initEulAng);
vhcl.centOfBuoy.setValue([0 0 objectHeight/4],'m');

% environmental properties
env = ENV.env;
env.addFlow({'water'},'FlowDensities',1000);
env.water.velVec.setValue([0 0 0],'m/s');
grav = env.gravAccel.Value;
rho = env.water.density.Value;

CB2CMVec = [0 0 objectHeight/4];

% distance from previously calculated tether tension to center of mass
airTethDist = [0 0 objectHeight/2];

% Vectors from CoM to anchor tether attachment point, in body/platform frame
anchThrPltfrm(1).posVec = [0 1 0]';
anchThrPltfrm(2).posVec = [cosd(30) -.5 0]';
anchThrPltfrm(3).posVec = [-cosd(30) -.5 0]';

dist = 100;
% Vector from ground fixed origin to tether attachment point, in ground frame
anchThrGnd(1).posVec = dist.*anchThrPltfrm(1).posVec;
anchThrGnd(2).posVec = dist.*anchThrPltfrm(2).posVec;
anchThrGnd(3).posVec = dist.*anchThrPltfrm(3).posVec;

% (theoretical) tether attachment points for a lifting body on platform
airbThrPltfrm(1).posVec = [0 1/2 1/2]';

% number of tethers
numNodes = 4;

thrs = OCT.tethers;
thrs.numTethers.setValue(3,'');
thrs.numNodes.setValue(numNodes,'')
thrs.build;

thrs.tether1.initGndNodePos.setValue(anchThrGnd(1).posVec,'m');
thrs.tether1.initAirNodePos.setValue(initPos(:)+rotation_sequence(initEulAng)*anchThrPltfrm(1).posVec(:),'m');
thrs.tether1.initGndNodeVel.setValue([0 0 0],'m/s');
thrs.tether1.initAirNodeVel.setValue(initVel,'m/s');
thrs.tether1.diameter.setValue(.05,'m');
thrs.tether1.youngsMod.setValue(3.8e9,'Pa');
thrs.tether1.dampingRatio.setValue(.05,'');
thrs.tether1.dragCoeff.setValue(.5,'');
thrs.tether1.density.setValue(1300,'kg/m^3');
thrs.tether1.vehicleMass.setValue(platformMass,'kg');
thrs.tether1.setDragEnable(true,'');
thrs.tether1.setSpringDamperEnable(true,'');
thrs.tether1.setNetBuoyEnable(true,'');
tetherLengths(1) = norm(thrs.tether1.initAirNodePos.Value-thrs.tether1.initGndNodePos.Value);

thrs.tether2.initGndNodePos.setValue(anchThrGnd(2).posVec,'m');
thrs.tether2.initAirNodePos.setValue(initPos(:)+rotation_sequence(initEulAng)*anchThrPltfrm(2).posVec(:),'m');
thrs.tether2.initGndNodeVel.setValue([0 0 0],'m/s');
thrs.tether2.initAirNodeVel.setValue(initVel,'m/s');
thrs.tether2.diameter.setValue(.05,'m');
thrs.tether2.youngsMod.setValue(3.8e9,'Pa');
thrs.tether2.dampingRatio.setValue(.05,'');
thrs.tether2.dragCoeff.setValue(.5,'');
thrs.tether2.density.setValue(1300,'kg/m^3');
thrs.tether2.vehicleMass.setValue(platformMass,'kg');
thrs.tether2.setDragEnable(true,'');
thrs.tether2.setSpringDamperEnable(true,'');
thrs.tether2.setNetBuoyEnable(true,'');
tetherLengths(2) = norm(thrs.tether2.initAirNodePos.Value-thrs.tether2.initGndNodePos.Value);

thrs.tether3.initGndNodePos.setValue(anchThrGnd(3).posVec,'m');
thrs.tether3.initAirNodePos.setValue(initPos(:)+rotation_sequence(initEulAng)*anchThrPltfrm(3).posVec(:),'m');
thrs.tether3.initGndNodeVel.setValue([0 0 0],'m/s');
thrs.tether3.initAirNodeVel.setValue(initVel,'m/s');
thrs.tether3.diameter.setValue(.05,'m');
thrs.tether3.youngsMod.setValue(3.8e9,'Pa');
thrs.tether3.dampingRatio.setValue(.05,'');
thrs.tether3.dragCoeff.setValue(.5,'');
thrs.tether3.density.setValue(1300,'kg/m^3');
thrs.tether3.vehicleMass.setValue(platformMass,'kg');
thrs.tether3.setDragEnable(true,'');
thrs.tether3.setSpringDamperEnable(true,'');
thrs.tether3.setNetBuoyEnable(true,'');
tetherLengths(3) = norm(thrs.tether3.initAirNodePos.Value-thrs.tether3.initGndNodePos.Value);

wins = OCT.winches;
wins.setNumWinches(3,'');
wins.build;
wins.setTetherInitLength(vhcl,env,thrs);

wins.winch1.maxSpeed.setValue(0.4,'m/s');
wins.winch1.timeConst.setValue(1,'s');
wins.winch1.maxAccel.setValue(inf,'m/s^2')

wins.winch2.maxSpeed.setValue(0.4,'m/s');
wins.winch2.timeConst.setValue(1,'s');
wins.winch2.maxAccel.setValue(inf,'m/s^2')

wins.winch3.maxSpeed.setValue(0.4,'m/s');
wins.winch3.timeConst.setValue(1,'s');
wins.winch3.maxAccel.setValue(inf,'m/s^2')

ctrl = CTR.controller;
ctrl.add('FPIDNames',{'surge','sway','heave'},...
    'FPIDErrorUnits',{'m','m','m'},...
    'FPIDOutputUnits',{'m/s','m/s','m/s'});
ctrl.add('GainNames',{'thrAllocationMat'},...
    'GainUnits',{'1/s'});
ctrl.add('SaturationNames',{'outputSat'});
ctrl.add('SetpointNames',{'surgeSP','swaySP','heaveSP'},...
    'SetpointUnits',{'m','m','m'});

ctrl.surge.kp.setValue(1,'(m/s)/(m)');
ctrl.surge.kd.setValue(0*ctrl.surge.kp.Value,'(m/s)/(m/s)');
ctrl.surge.tau.setValue(.1,'s');

ctrl.sway.kp.setValue(1,'(m/s)/(m)');
ctrl.sway.kd.setValue(0*ctrl.sway.kp.Value,'(m/s)/(m/s)');
ctrl.sway.tau.setValue(.1,'s');

ctrl.heave.kp.setValue(1,'(m/s)/(m)');
ctrl.heave.kd.setValue(0*ctrl.heave.kp.Value,'(m/s)/(m/s)');
ctrl.heave.tau.setValue(.1,'s');

ctrl.outputSat.upperLimit.setValue(.4,'');
ctrl.outputSat.lowerLimit.setValue(-.4,'');

timeV = 0:.1:sim_time;
ctrl.surgeSP.Value = timeseries(0*ones(size(timeV)),timeV);
% ctrl.surgeSP.Value.DataInfo.Units = 'm';
ctrl.swaySP.Value = timeseries(0*ones(size(timeV)),timeV);
% ctrl.surgeSP.Value.DataInfo.Units = 'm';
ctrl.heaveSP.Value = timeseries(100*ones(size(timeV)),timeV);
% ctrl.surgeSP.Value.DataInfo.Units = 'm';

surge1 = -dist + sqrt(dist^2+1);
surge1 = 0
surge2 = -dist + sqrt(dist^2+1-2*dist*cosd(30));
surge3 = -dist + sqrt(dist^2+1-2*dist*cosd(120));
surgeVec = [0 0 0]';
% surgeVec = [surge1 surge2 surge3]';
% surgeVec = surgeVec/norm(surgeVec);
swayNum = -dist + sqrt(dist^2+1^2-2*dist*cosd(60));
swayVec = [0 0 0]';
% swayVec = [-1 -swayNum -swayNum]';
% swayVec = swayVec/norm(swayVec);
heaveNum = -sqrt(mean(ctrl.heaveSP.Value.Data)^2+dist^2) + sqrt((mean(ctrl.heaveSP.Value.Data)+1)^2+dist^2);
heaveVec = [0 0 0]';
heaveVec = [heaveNum heaveNum heaveNum]';
heaveVec = heaveVec/norm(heaveVec);

% ctrl.thrAllocationMat.setValue(-1.*[surge1 surge2 surge3;-1 -swayNum -swayNum;-heaveNum -heaveNum -heaveNum]','1/s')
ctrl.thrAllocationMat.setValue([surgeVec,swayVec,heaveVec],'1/s')
ctrl.thrAllocationMat.Value

% circulation data
v = 0;
vsquared = v^2;
cd = .8;
A = platformVolume^(2/3);
oceanPeriod = 15;
xOn = 1; % 1 = on, 0 = off
zOn = 1;

% ocean properties
waveAmp = 1.5;
wavePeriod = oceanPeriod;
oceanDepth = 105;

sim('groundStation001_th')

parseLogsout


%%
close all

parseLogsout
figure
oH = oceanDepth + waveAmp*sin(2*pi/(wavePeriod).*tsc.subBodyPos.Time);
diff = squeeze(tsc.subBodyPos.Data(3,:,:)) - oH;
plot(tsc.subBodyPos.Time,diff)
xlabel('Time, t [s]')
ylabel('Distance from Ocean Surface [m]')

% Plot position
figure
subplot(3,1,1)
plot(tsc.subBodyPos.Time,squeeze(tsc.subBodyPos.Data(1,:,:)),'k')
hold on
plot(timeV,squeeze(ctrl.surgeSP.Value.Data),'r')
grid on
xlabel('Time, t [s]')
ylabel('X Pos [m]')

subplot(3,1,2)
plot(tsc.subBodyPos.Time,squeeze(tsc.subBodyPos.Data(2,:,:)),'k')
hold on
plot(timeV,squeeze(ctrl.swaySP.Value.Data),'r')
grid on
xlabel('Time, t [s]')
ylabel('Y Pos [m]')

subplot(3,1,3)
plot(tsc.subBodyPos.Time,squeeze(tsc.subBodyPos.Data(3,:,:)),'k')
hold on
plot(tsc.subBodyPos.Time,oH)
plot(timeV,squeeze(ctrl.heaveSP.Value.Data),'r')
grid on
xlabel('Time, t [s]')
ylabel('Z Pos [m]')

% Plot Euler angles
figure
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

figure
tsc.tetherLengths.plot
legend('1: pos y','2: pos x, neg y','3: neg x, neg y')

figure
tsc.winchSpeeds.plot
legend('1','2','3')

timeStep = 1;
% fileName = 'sub_circ.gif';

% Resample data to the animation framerate
timeVec = 0:timeStep:tsc.subBodyPos.Time(end);
numTethers = numel(tsc.anchThrNodeBusArry);
for ii= 1:numTethers
    tsc.anchThrNodeBusArry(ii).nodePositions = resample(tsc.anchThrNodeBusArry(ii).nodePositions,timeVec);
    tsc.subBodyPos = resample(tsc.subBodyPos,timeVec);
end   


h.fig = figure; % Create figure
h.fig.Position = [1          41        1920         750]; % Set to full screen (1920 pixel display)

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
% xlim([0,9])
% ylim([-5,3])
% zlim([90,100])
hold on
end
h.title = title(sprintf('Time = %d',tsc.subBodyPos.Time(1)));

set(gca,'FontSize',24)
% 
% frame = getframe(h.fig );
% im = frame2im(frame);
% [imind,cm] = rgb2ind(im,256);

% imwrite(imind,cm,fileName,'gif', 'Loopcount',inf);

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
    
%     frame = getframe(h.fig); 
%     im = frame2im(frame); 
%     [imind,cm] = rgb2ind(im,256);
%     imwrite(imind,cm,fileName,'gif','WriteMode','append','DelayTime',0.05);
    
end

%%

for j = 1:3
    initPos(j) = mean(tsc.subBodyPos.Data(j,:,:));
end
oceanDepth = initPos(3);

sim('groundStation001_th')

parseLogsout

%%

figure
oH = oceanDepth + waveAmp*sin(2*pi/(wavePeriod).*tsc.subBodyPos.Time);
diff = squeeze(tsc.subBodyPos.Data(3,:,:)) - oH;
plot(tsc.subBodyPos.Time,diff)
xlabel('Time, t [s]')
ylabel('Distance from Ocean Surface [m]')
% Plot position
figure
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
hold on
plot(tsc.subBodyPos.Time,oH,'r')
grid on
xlabel('Time, t [s]')
ylabel('Z Pos [m]')

% Plot Euler angles
figure
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

timeStep = 1;
fileName = 'partSub_circ.gif';

% Resample data to the animation framerate
timeVec = 0:timeStep:tsc.subBodyPos.Time(end);
numTethers = numel(tsc.anchThrNodeBusArry);
for ii= 1:numTethers
    tsc.anchThrNodeBusArry(ii).nodePositions = resample(tsc.anchThrNodeBusArry(ii).nodePositions,timeVec);
    tsc.subBodyPos = resample(tsc.subBodyPos,timeVec);
end   


h.fig = figure; % Create figure
h.fig.Position = [1          41        1920         750]; % Set to full screen (1920 pixel display)

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
% xlim([0,9])
% ylim([-5,3])
% zlim([90,100])
hold on
end
h.title = title(sprintf('Time = %d',tsc.subBodyPos.Time(1)));

set(gca,'FontSize',24)

frame = getframe(h.fig );
im = frame2im(frame);
[imind,cm] = rgb2ind(im,256);

imwrite(imind,cm,fileName,'gif', 'Loopcount',inf);

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
    
    frame = getframe(h.fig); 
    im = frame2im(frame); 
    [imind,cm] = rgb2ind(im,256);
    imwrite(imind,cm,fileName,'gif','WriteMode','append','DelayTime',0.05);
    
end
