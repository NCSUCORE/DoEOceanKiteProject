close all;clc

% need tension data files to run next two lines of code
load('mag.mat')
load('pos.mat')
% run this to load tether tension data %
% clear

% run this to set magnitude of tension data to zero %
% mag.Data = zeros;

% run this to set magnitude of tension data to average magnitude %
% mag.Data = mean(mag.Data)*ones(size(mag.Data));

% run this to set constant average direction of tension data%
% for i = 1:3
%     position.Data(:,i) = mean(position.Data(:,i))*ones(size(position.Data(:,i)));
% end

% create buses required to run code
createThreeTetherThreeSurfaceCtrlBus
createConstantUniformFlowEnvironmentBus
createThrAttachPtKinematicsBus
createThrTenVecBus

% specify simulation time
sim_time = 300; % (s)

% environmental properties
env = ENV.env;
env.addFlow({'water'},'FlowDensities',1000);    % density (kg/m^3)
env.water.velVec.setValue([0 0 0],'m/s');
grav = env.gravAccel.Value;                     % grav = 9.81 m/s^2
rho = env.water.density.Value;

% geometry of platform
platformVolume = 3.5;                       % (m^3)
objectHeight = platformVolume^(1/3);        % assuming a cube (m)
% platform properties
buoyF = 1.5;                                % buoyancy factor (unitless)
platformMass = platformVolume*(rho/buoyF);
platformInertiaMatrix = ((1/6)*platformMass*objectHeight^2).*eye(3); % assuming a cube

% initial conditions
initPos = [0 0 100];            % from ocean floor (m)
initVel = [1e-3 0 0];              % (m/s)
initEulAng = (pi/180).*[0 0 0]; % vector input in degrees, converted to radians
initAngVel = [0 0 0];           % (rad/s)

% distance FROM center of mass TO center of buoyancy
CB2CMVec = [0 0 objectHeight/4];    % (m)

% distance from airborne tether tension to center of mass
airTethDist = [0 0 objectHeight/2]; % (m)

% Vectors from CoM to anchor tether attachment point, in body/platform frame
anchThrPltfrm(1).posVec = [0 1 0]';             % (m)
anchThrPltfrm(2).posVec = [cosd(30) -.5 0]';    % (m)
anchThrPltfrm(3).posVec = [-cosd(30) -.5 0]';   % (m)

% Vector from ground fixed origin to tether attachment point, in ground frame
dist = 100;
anchThrGnd(1).posVec = dist.*anchThrPltfrm(1).posVec;   % (m)
    anchThrGnd(1).posVec(3) = 0;                        % in case z ~= 0
anchThrGnd(2).posVec = dist.*anchThrPltfrm(2).posVec;   % (m)
    anchThrGnd(2).posVec(3) = 0;                        % in case z ~= 0
anchThrGnd(3).posVec = dist.*anchThrPltfrm(3).posVec;   % (m)
    anchThrGnd(3).posVec(3) = 0;                        % in case z ~= 0

% tether attachment points for lifting body on platform, in body/platform frame
airbThrPltfrm(1).posVec = airTethDist;  % (m)

% anchor tethers
numNodes = 4;                           % number of nodes

thr = OCT.tethers;                      % initiate tether creation
thr.numTethers.setValue(3,'');          % three tethers
thr.numNodes.setValue(numNodes,'')      % set number of nodes
thr.build;                              % builds three tethers in code

% set tether 1 properties
thr.tether1.initGndNodePos.setValue(anchThrGnd(1).posVec,'m'); % initial anchor node position
thr.tether1.initAirNodePos.setValue(initPos(:)+rotation_sequence(initEulAng)*anchThrPltfrm(1).posVec(:),'m'); % initial body node position in ground frame
thr.tether1.initGndNodeVel.setValue([0 0 0],'m/s');  % initial velocity of anchor node
thr.tether1.initAirNodeVel.setValue(initVel,'m/s');  % initial velocity of body node
thr.tether1.diameter.setValue(.05,'m');              % tether diameter
thr.tether1.youngsMod.setValue(3.8e9,'Pa');          % tether Young's Modulus
thr.tether1.dampingRatio.setValue(.05,'');           % zeta, damping ratio
thr.tether1.dragCoeff.setValue(.5,'');               % drag coefficient for intermediate nodes
thr.tether1.density.setValue(1300,'kg/m^3');         % tether density
thr.tether1.vehicleMass.setValue(platformMass,'kg'); % mass of platform for damping coefficient calculations
thr.tether1.setDragEnable(true,'');                  % intermediate nodes experience drag
thr.tether1.setSpringDamperEnable(true,'');          % tether has damping
thr.tether1.setNetBuoyEnable(true,'');               % intermediate nodes have buoyancy
% calculate tether length using initial positions of anchor and body nodes
tetherLengths(1) = norm(thr.tether1.initAirNodePos.Value-thr.tether1.initGndNodePos.Value);

% set tether 2 properties
thr.tether2.initGndNodePos.setValue(anchThrGnd(2).posVec,'m'); % initial anchor node position
thr.tether2.initAirNodePos.setValue(initPos(:)+rotation_sequence(initEulAng)*anchThrPltfrm(2).posVec(:),'m'); % initial body node position in ground frame
thr.tether2.initGndNodeVel.setValue([0 0 0],'m/s');  % initial velocity of anchor node
thr.tether2.initAirNodeVel.setValue(initVel,'m/s');  % initial velocity of body node
thr.tether2.diameter.setValue(.05,'m');              % tether diameter
thr.tether2.youngsMod.setValue(3.8e9,'Pa');          % tether Young's Modulus
thr.tether2.dampingRatio.setValue(.05,'');           % zeta, damping ratio
thr.tether2.dragCoeff.setValue(.5,'');               % drag coefficient for intermediate nodes
thr.tether2.density.setValue(1300,'kg/m^3');         % tether density
thr.tether2.vehicleMass.setValue(platformMass,'kg'); % mass of platform for damping coefficient calculations
thr.tether2.setDragEnable(true,'');                  % intermediate nodes experience drag
thr.tether2.setSpringDamperEnable(true,'');          % tether has damping
thr.tether2.setNetBuoyEnable(true,'');               % intermediate nodes have buoyancy
% calculate tether length using initial positions of anchor and body nodes
tetherLengths(2) = norm(thr.tether2.initAirNodePos.Value-thr.tether2.initGndNodePos.Value);

% set tether 3 properties
thr.tether3.initGndNodePos.setValue(anchThrGnd(3).posVec,'m');
thr.tether3.initAirNodePos.setValue(initPos(:)+rotation_sequence(initEulAng)*anchThrPltfrm(3).posVec(:),'m'); % initial body node position in ground frame
thr.tether3.initGndNodeVel.setValue([0 0 0],'m/s');  % initial velocity of anchor node
thr.tether3.initAirNodeVel.setValue(initVel,'m/s');  % initial velocity of body node
thr.tether3.diameter.setValue(.05,'m');              % tether diameter
thr.tether3.youngsMod.setValue(3.8e9,'Pa');          % tether Young's Modulus
thr.tether3.dampingRatio.setValue(.05,'');           % zeta, damping ratio
thr.tether3.dragCoeff.setValue(.5,'');               % drag coefficient for intermediate nodes
thr.tether3.density.setValue(1300,'kg/m^3');         % tether density
thr.tether3.vehicleMass.setValue(platformMass,'kg'); % mass of platform for damping coefficient calculations
thr.tether3.setDragEnable(true,'');                  % intermediate nodes experience drag
thr.tether3.setSpringDamperEnable(true,'');          % tether has damping
thr.tether3.setNetBuoyEnable(true,'');               % intermediate nodes have buoyancy
% calculate tether length using initial positions of anchor and body nodes
tetherLengths(3) = norm(thr.tether3.initAirNodePos.Value-thr.tether3.initGndNodePos.Value);

% anchor tether winches
wnch = OCT.winches;                                     % initiate winch creation
wnch.setNumWinches(thr.numTethers.Value,'');            % number of winches = number of tethers
wnch.build;                                             % builds winches in code

wnch.winch1.maxSpeed.setValue(0.4,'m/s');               % set maximum speed
wnch.winch1.timeConst.setValue(.1,'s');                 % set time constant
wnch.winch1.maxAccel.setValue(.5,'m/s^2')               % set maximum accleration
wnch.winch1.initLength.setValue(tetherLengths(1),'m')   % set initial length

wnch.winch2.maxSpeed.setValue(0.4,'m/s');               % set maximum speed
wnch.winch2.timeConst.setValue(.1,'s');                 % set time constant
wnch.winch2.maxAccel.setValue(.5,'m/s^2')               % set maximum accleration
wnch.winch2.initLength.setValue(tetherLengths(2),'m')   % set initial length

wnch.winch3.maxSpeed.setValue(0.4,'m/s');               % set maximum speed
wnch.winch3.timeConst.setValue(.1,'s');                 % set time constant
wnch.winch3.maxAccel.setValue(.5,'m/s^2')               % set maximum accleration
wnch.winch3.initLength.setValue(tetherLengths(3),'m')   % set initial length

% create anchor tether winch controller
% initiate controller creation
ctrl = CTR.controller;
% create surge, sway, and heave controller
ctrl.add('FPIDNames',{'surge','sway','heave'},...
    'FPIDErrorUnits',{'m','m','m'},...
    'FPIDOutputUnits',{'m/s','m/s','m/s'});
% create control allocation matrix
ctrl.add('GainNames',{'thrAllocationMat'},...
    'GainUnits',{'1/s'});
% create set points for each controller
ctrl.add('SetpointNames',{'surgeSP','swaySP','heaveSP'},...
    'SetpointUnits',{'m','m','m'});

ctrl.surge.kp.setValue(.05,'(m/s)/(m)');                        % proportional gain
ctrl.surge.kd.setValue(12*ctrl.surge.kp.Value,'(m/s)/(m/s)');   % derivative gain
ctrl.surge.tau.setValue(.1,'s');                                % time constant

ctrl.sway.kp.setValue(.05,'(m/s)/(m)');                         % proportional gain
ctrl.sway.kd.setValue(12*ctrl.sway.kp.Value,'(m/s)/(m/s)');     % derivative gain
ctrl.sway.tau.setValue(.1,'s');                                 % time constant

ctrl.heave.kp.setValue(.15,'(m/s)/(m)');                        % proportional gain
ctrl.heave.kd.setValue(12*ctrl.heave.kp.Value,'(m/s)/(m/s)');   % derivative gain
ctrl.heave.tau.setValue(.1,'s');                                % time constant

% set set points as a time series
timeV = 0:.1:sim_time;
ctrl.surgeSP.Value = timeseries(0*ones(size(timeV)),timeV);     % constant surge set point
ctrl.surgeSP.Value.DataInfo.Units = 'm';    % set units
ctrl.swaySP.Value = timeseries(0*ones(size(timeV)),timeV);      % constant sway set point
ctrl.surgeSP.Value.DataInfo.Units = 'm';    % set units
ctrl.heaveSP.Value = timeseries(100*ones(size(timeV)),timeV);   % constant heave set point
ctrl.surgeSP.Value.DataInfo.Units = 'm';    % set units

% tether control allocation matrix
% use zero vectors to turn individual controllers on and off (or set
% proportional gain to zero)
surgeVec = [0 -.5 .5]';                             % symmetric tether 2 and 3
surgeVec = surgeVec/norm(surgeVec);                 % normalize
% surgeVec = [0 0 0]';
swayNum = -dist + sqrt(dist^2+1-2*dist*cosd(60));   % geometric analysis for sway
swayVec = [-1 -swayNum -swayNum]';                  % symmetric tether 1 and tethers 2&3
swayVec = swayVec/norm(swayVec);                    % normalize
% swayVec = [0 0 0]';
heaveVec = [1 1 1]';                                % all tethers move together
heaveVec = heaveVec/norm(heaveVec);                 % normalize
% heaveVec = [0 0 0]';

% create matrix using vectors above
ctrl.thrAllocationMat.setValue([surgeVec,swayVec,heaveVec],'1/s')

% properties for circulation force
v = 0;                      % velocity of ocean current (m/s)
vsquared = v^2;
cd = .8;                    % drag coefficient assuming a cube
A = objectHeight^2;         % projected area of a cube ('m^2')
oceanPeriod = 20;           % period (s)
xOn = 1;                    % 1 = on, 0 = off
zOn = 1;                    % 1 = on, 0 = off

% ocean properties for variable buoyancy calculations
waveAmp = 1.5;              % amplitude (m)
wavePeriod = oceanPeriod;   % period (s)
oceanDepth = 105;           % mean ocean depth (m)

% run simulation
sim('groundStation001_th')

% save data to workspace as tsc
parseLogsout

%% post simulation plots and results

% plot showing distance from ocean surface
figure
oH = oceanDepth + waveAmp*sin(2*pi/(wavePeriod).*tsc.subBodyPos.Time);  % ocean depth as a function of time
diff = squeeze(tsc.subBodyPos.Data(3,:,:)) - oH;                        % platform z-position minus ocean depth
plot(tsc.subBodyPos.Time,diff)
xlabel('Time, t [s]')
ylabel('Distance from Ocean Surface [m]')

% Plot x,y,z position
figure
subplot(3,1,1)
plot(tsc.subBodyPos.Time,squeeze(tsc.subBodyPos.Data(1,:,:)),'k')
hold on
plot(timeV,squeeze(ctrl.surgeSP.Value.Data),'--r')      % plot surge set point (optional)
% plot(timeV,initPos(1).*ones(length(timeV)),'--g')     % plot initial position (optional)
grid on
xlabel('Time, t [s]')
ylabel('X Pos [m]')

subplot(3,1,2)
plot(tsc.subBodyPos.Time,squeeze(tsc.subBodyPos.Data(2,:,:)),'k')
hold on
plot(timeV,squeeze(ctrl.swaySP.Value.Data),'r--')       % plot sway set point (optional)
% plot(timeV,initPos(2).*ones(length(timeV)),'--g')     % plot initial position (optional)
grid on
xlabel('Time, t [s]')
ylabel('Y Pos [m]')

subplot(3,1,3)
plot(tsc.subBodyPos.Time,squeeze(tsc.subBodyPos.Data(3,:,:)),'k')
hold on
% plot(tsc.subBodyPos.Time,oH)
plot(timeV,squeeze(ctrl.heaveSP.Value.Data),'r--')      % plot heave set point (optional)
% plot(timeV,initPos(3).*ones(length(timeV)),'--g')     % plot initial position (optional)
grid on
xlabel('Time, t [s]')
ylabel('Z Pos [m]')

% save image
% saveas(gcf,'imageName.png')

% Plot Euler angles
figure
subplot(3,1,1)
plot(tsc.subBodyPos.Time,squeeze(tsc.eulerAngles.Data(1,:,:))*180/pi,'k')
hold on
plot(tsc.subBodyPos.Time,zeros(length(tsc.subBodyPos.Time)),'--r')  % plot zero axis
grid on
xlabel('Time, t [s]')
ylabel('Roll, [deg]')

subplot(3,1,2)
plot(tsc.subBodyPos.Time,squeeze(tsc.eulerAngles.Data(2,:,:))*180/pi,'k')
hold on
plot(tsc.subBodyPos.Time,zeros(length(tsc.subBodyPos.Time)),'--r')  % plot zero axis
grid on
xlabel('Time, t [s]')
ylabel('Pitch, [deg]')

subplot(3,1,3)
plot(tsc.subBodyPos.Time,squeeze(tsc.eulerAngles.Data(3,:,:))*180/pi,'k')
hold on
plot(tsc.subBodyPos.Time,zeros(length(tsc.subBodyPos.Time)),'--r')  % plot zero axis
grid on
xlabel('Time, t [s]')
ylabel('Yaw, [deg]')

% save euler angle
% saveas(gcf,'imageName_euler.png')

% figure
% tsc.oceanForce.plot
% xlabel('Time, t [s]')
% ylabel('Circulation Force [N]')

% figure
% tsc.tetherLengths.plot
% legend('1','2','3')
% xlabel('Time, t [s]')
% ylabel('Tether Length [m]')

figure
tsc.winchSpeeds.plot
legend('1','2','3')
xlabel('Time, t [s]')
ylabel('Winch Speed [m/s]')
title('')

% save winch speed image
% saveas(gcf,'imageName_winchSpeed.png')

%% create gif animation
timeStep = 1;
% create file name
fileName = 'gifName.gif';

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
% to zoom in on animation, edit limits
% xlim([-2,6])
% ylim([-4,4])
% zlim([92,100])
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

%% run after first section of script to run a partially submerged simulation
% run the second and third (above) scripts to generate plots and data again

% find average position of previous simulation to determine partially
% submerged position
for j = 1:3
    initPos(j) = mean(tsc.subBodyPos.Data(j,:,:));
end
% use z position as new ocean depth
oceanDepth = initPos(3);

sim('groundStation001_th')
