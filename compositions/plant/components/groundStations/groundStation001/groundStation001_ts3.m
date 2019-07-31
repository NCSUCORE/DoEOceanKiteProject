clear;clc;
close all

createAnchorThetherCtrlBus
createWaveFlowEnvironmentBus
createThrAttachPtKinematicsBus
createThrTenVecBus

WINCH            = 'winch000';

sim_time = 100;

env = ENV.env;
env.addFlow({'water'},{'waveFlow'},'FlowDensities',1000)
env.water.density.setValue(1000,'kg/m^3');
env.water.wavePeriod.setValue(20,'s');
env.water.waveAmplitude.setValue(1.5,'m');
env.water.oceanDepth.setValue(105,'m');
env.water.pltfrmAppFlwMag.setValue(0,'m/s');
env.water.flowVelocityVec.setValue([0 0 0]','m/s');

gndStn = OCT.sixDoFStation;

buoyF = 1.5;
gndStn.setVolume(3.5,'m^3');
gndStn.setMass(gndStn.volume.Value*(env.water.density.Value/buoyF),'kg');
gndStn.setInertiaMatrix(((1/6)*gndStn.mass.Value*gndStn.volume.Value^(2/3)).*eye(3),'kg*m^2');
gndStn.setCentOfBuoy([0 0 gndStn.volume.Value^(1/3)/2],'m');

gndStn.setDragCoefficient(0.8,'');

dist = 100;
gndStn.airThrAttchPt.setPosVec([0 0 ((gndStn.volume.Value)^(1/3))/2],'m');
gndStn.bdyThrAttchPt1.setPosVec([0 1 0],'m');
gndStn.bdyThrAttchPt2.setPosVec([cosd(30) -.5 0],'m');
gndStn.bdyThrAttchPt3.setPosVec([-cosd(30) -.5 0],'m');
gndStn.gndThrAttchPt1.setPosVec(dist.*gndStn.bdyThrAttchPt1.posVec.Value,'m');
gndStn.gndThrAttchPt2.setPosVec(dist.*gndStn.bdyThrAttchPt2.posVec.Value,'m');
gndStn.gndThrAttchPt3.setPosVec(dist.*gndStn.bdyThrAttchPt3.posVec.Value,'m');

gndStn.setInitPos([0 0 100],'m');
gndStn.setInitEulAng([0 0 0],'rad');
gndStn.setInitVel([1e-3 0 0],'m/s');
gndStn.setInitAngVel([0 0 0],'rad/s');

gndStn.anchThrs.setNumNodes(4,'');
gndStn.anchThrs.setNumTethers(3,'');
gndStn.anchThrs.build;

% set tether 1 properties
gndStn.anchThrs.tether1.initGndNodePos.setValue(gndStn.gndThrAttchPt1.posVec.Value,'m'); % initial anchor node position
gndStn.anchThrs.tether1.initAirNodePos.setValue(gndStn.initPos.Value(:)+rotation_sequence(gndStn.initEulAng.Value)*gndStn.bdyThrAttchPt1.posVec.Value(:),'m'); % initial body node position in ground frame
gndStn.anchThrs.tether1.initGndNodeVel.setValue([0 0 0],'m/s');  % initial velocity of anchor node
gndStn.anchThrs.tether1.initAirNodeVel.setValue(gndStn.initVel.Value,'m/s');  % initial velocity of body node
gndStn.anchThrs.tether1.diameter.setValue(.05,'m');              % tether diameter
gndStn.anchThrs.tether1.youngsMod.setValue(3.8e9,'Pa');          % tether Young's Modulus
gndStn.anchThrs.tether1.dampingRatio.setValue(.05,'');           % zeta, damping ratio
gndStn.anchThrs.tether1.dragCoeff.setValue(.5,'');               % drag coefficient for intermediate nodes
gndStn.anchThrs.tether1.density.setValue(1300,'kg/m^3');         % tether density
gndStn.anchThrs.tether1.vehicleMass.setValue(gndStn.mass.Value,'kg'); % mass of platform for damping coefficient calculations
% gndStn.anchThrs.tether1.setDragEnable(true,'');                  % intermediate nodes experience drag
% gndStn.anchThrs.tether1.setSpringDamperEnable(true,'');          % tether has damping
% gndStn.anchThrs.tether1.setNetBuoyEnable(true,'');               % intermediate nodes have buoyancy
% calculate tether length using initial positions of anchor and body nodes
tetherLengths(1) = norm(gndStn.anchThrs.tether1.initAirNodePos.Value(:)-gndStn.anchThrs.tether1.initGndNodePos.Value(:));

% set tether 2 properties
gndStn.anchThrs.tether2.initGndNodePos.setValue(gndStn.gndThrAttchPt2.posVec.Value,'m'); % initial anchor node position
gndStn.anchThrs.tether2.initAirNodePos.setValue(gndStn.initPos.Value(:)+rotation_sequence(gndStn.initEulAng.Value)*gndStn.bdyThrAttchPt2.posVec.Value(:),'m'); % initial body node position in ground frame
gndStn.anchThrs.tether2.initGndNodeVel.setValue([0 0 0],'m/s');  % initial velocity of anchor node
gndStn.anchThrs.tether2.initAirNodeVel.setValue(gndStn.initVel.Value,'m/s');  % initial velocity of body node
gndStn.anchThrs.tether2.diameter.setValue(.05,'m');              % tether diameter
gndStn.anchThrs.tether2.youngsMod.setValue(3.8e9,'Pa');          % tether Young's Modulus
gndStn.anchThrs.tether2.dampingRatio.setValue(.05,'');           % zeta, damping ratio
gndStn.anchThrs.tether2.dragCoeff.setValue(.5,'');               % drag coefficient for intermediate nodes
gndStn.anchThrs.tether2.density.setValue(1300,'kg/m^3');         % tether density
gndStn.anchThrs.tether2.vehicleMass.setValue(gndStn.mass.Value,'kg'); % mass of platform for damping coefficient calculations
% gndStn.anchThrs.tether2.setDragEnable(true,'');                  % intermediate nodes experience drag
% gndStn.anchThrs.tether2.setSpringDamperEnable(true,'');          % tether has damping
% gndStn.anchThrs.tether2.setNetBuoyEnable(true,'');               % intermediate nodes have buoyancy
% calculate tether length using initial positions of anchor and body nodes
tetherLengths(2) = norm(gndStn.anchThrs.tether2.initAirNodePos.Value(:)-gndStn.anchThrs.tether2.initGndNodePos.Value(:));

% set tether 3 properties
gndStn.anchThrs.tether3.initGndNodePos.setValue(gndStn.gndThrAttchPt3.posVec.Value,'m');
gndStn.anchThrs.tether3.initAirNodePos.setValue(gndStn.initPos.Value(:)+rotation_sequence(gndStn.initEulAng.Value)*gndStn.bdyThrAttchPt3.posVec.Value(:),'m'); % initial body node position in ground frame
gndStn.anchThrs.tether3.initGndNodeVel.setValue([0 0 0],'m/s');  % initial velocity of anchor node
gndStn.anchThrs.tether3.initAirNodeVel.setValue(gndStn.initVel.Value,'m/s');  % initial velocity of body node
gndStn.anchThrs.tether3.diameter.setValue(.05,'m');              % tether diameter
gndStn.anchThrs.tether3.youngsMod.setValue(3.8e9,'Pa');          % tether Young's Modulus
gndStn.anchThrs.tether3.dampingRatio.setValue(.05,'');           % zeta, damping ratio
gndStn.anchThrs.tether3.dragCoeff.setValue(.5,'');               % drag coefficient for intermediate nodes
gndStn.anchThrs.tether3.density.setValue(1300,'kg/m^3');         % tether density
gndStn.anchThrs.tether3.vehicleMass.setValue(gndStn.mass.Value,'kg'); % mass of platform for damping coefficient calculations
% gndStn.anchThrs.tether3.setDragEnable(true,'');                  % intermediate nodes experience drag
% gndStn.anchThrs.tether3.setSpringDamperEnable(true,'');          % tether has damping
% gndStn.anchThrs.tether3.setNetBuoyEnable(true,'');               % intermediate nodes have buoyancy
% calculate tether length using initial positions of anchor and body nodes
tetherLengths(3) = norm(gndStn.anchThrs.tether3.initAirNodePos.Value(:)-gndStn.anchThrs.tether3.initGndNodePos.Value(:));

% anchor tether winches
wnch = OCT.winches;                                     % initiate winch creation
wnch.setNumWinches(gndStn.anchThrs.numTethers.Value,'');            % number of winches = number of tethers
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

% run simulation
sim('groundStation001_th')

% save data to workspace as tsc
parseLogsout

%% Position
figure
subplot(3,1,1)
plot(tsc.posVecGnd.Time,squeeze(tsc.posVecGnd.Data(1,:,:)))
grid on
title('Position')
subplot(3,1,2)
plot(tsc.posVecGnd.Time,squeeze(tsc.posVecGnd.Data(2,:,:)))
grid on
subplot(3,1,3)
plot(tsc.posVecGnd.Time,squeeze(tsc.posVecGnd.Data(3,:,:)))
grid on

%% Euler Angles
figure
subplot(3,1,1)
plot(tsc.posVecGnd.Time,squeeze(tsc.eulerAngleVec.Data(1,:,:)))
grid on
title('Euler Angles')
subplot(3,1,2)
plot(tsc.posVecGnd.Time,squeeze(tsc.eulerAngleVec.Data(2,:,:)))
grid on
subplot(3,1,3)
plot(tsc.posVecGnd.Time,squeeze(tsc.eulerAngleVec.Data(3,:,:)))
grid on

%% Y Components of Forces
figure
subplot(5,1,1)
plot(tsc.posVecGnd.Time,squeeze(tsc.FNetAirbThrGnd.Data(2,:,:)))
grid on
subplot(5,1,2)
plot(tsc.posVecGnd.Time,squeeze(tsc.FNetAnchThrGnd.Data(2,:,:)))
grid on
subplot(5,1,3)
plot(tsc.posVecGnd.Time,squeeze(tsc.FGravGnd.Data(2,:,:)))
grid on
subplot(5,1,4)
plot(tsc.posVecGnd.Time,squeeze(tsc.FBuoyGnd.Data(2,:,:)))
grid on
subplot(5,1,5)
plot(tsc.posVecGnd.Time,squeeze(tsc.oceanForceGnd.Data(2,:,:)))
grid on

linkaxes(findall(gcf,'Type','axes'),'x');

%% Plot anchor tethers at first time step
timeVec = 0:1:tsc.posVecGnd.Time(end);
fileName = 'animation.gif';
for ii= 1:3
    tsc.anchThrNodeBusArry(ii).nodePositions = resample(tsc.anchThrNodeBusArry(ii).nodePositions,timeVec);
end
figure
h.thr1 = plot3(...
    tsc.anchThrNodeBusArry(1).nodePositions.Data(1,:,1),...
    tsc.anchThrNodeBusArry(1).nodePositions.Data(2,:,1),...
    tsc.anchThrNodeBusArry(1).nodePositions.Data(3,:,1),...
    'LineWidth',1.5,'Color','k','Marker','o');
xlabel('x position')
ylabel('y position')
zlabel('z position')
hold on
grid on
h.thr2 = plot3(...
    tsc.anchThrNodeBusArry(2).nodePositions.Data(1,:,1),...
    tsc.anchThrNodeBusArry(2).nodePositions.Data(2,:,1),...
    tsc.anchThrNodeBusArry(2).nodePositions.Data(3,:,1),...
    'LineWidth',1.5,'Color','k','Marker','o');
h.thr3 = plot3(...
    tsc.anchThrNodeBusArry(3).nodePositions.Data(1,:,1),...
    tsc.anchThrNodeBusArry(3).nodePositions.Data(2,:,1),...
    tsc.anchThrNodeBusArry(3).nodePositions.Data(3,:,1),...
    'LineWidth',1.5,'Color','k','Marker','o');
h.title = title(sprintf('Time = %.1f',timeVec(1)));
set(gca,'FontSize',24')

frame = getframe(gcf );
im = frame2im(frame);
[imind,cm] = rgb2ind(im,256);

imwrite(imind,cm,fileName,'gif', 'Loopcount',inf,'DelayTime',0.2);
for ii = 2:numel(timeVec)
    h.thr1.XData =  tsc.anchThrNodeBusArry(1).nodePositions.Data(1,:,ii);
    h.thr1.YData =  tsc.anchThrNodeBusArry(1).nodePositions.Data(2,:,ii);
    h.thr1.ZData =  tsc.anchThrNodeBusArry(1).nodePositions.Data(3,:,ii);
    
    h.thr2.XData =  tsc.anchThrNodeBusArry(2).nodePositions.Data(1,:,ii);
    h.thr2.YData =  tsc.anchThrNodeBusArry(2).nodePositions.Data(2,:,ii);
    h.thr2.ZData =  tsc.anchThrNodeBusArry(2).nodePositions.Data(3,:,ii);
    
    h.thr3.XData =  tsc.anchThrNodeBusArry(3).nodePositions.Data(1,:,ii);
    h.thr3.YData =  tsc.anchThrNodeBusArry(3).nodePositions.Data(2,:,ii);
    h.thr3.ZData =  tsc.anchThrNodeBusArry(3).nodePositions.Data(3,:,ii);
    
    h.title.String = sprintf('Time = %.1f',timeVec(ii));
    frame = getframe(gcf );
    im = frame2im(frame);
    [imind,cm] = rgb2ind(im,256);
    imwrite(imind,cm,fileName,'gif','WriteMode','append');
    drawnow
end

