clear
clc
close all
cd(fileparts(mfilename('fullpath')));

% load parameters that are common for all simulations
commonSimParameters;
simParams.setDuration(300,'s');

%% simulation sweep parameters
flowSpeed = 2.1;
Z = 200;
thrLength = 600;
fltCtrl.pathElevation_deg	= asind(Z/thrLength);

% Environment IC's and dependant properties
env.water.setflowVec([flowSpeed 0 0],'m/s')

% Set vehicle initial conditions
init_speed = 2*norm(env.water.flowVec.Value);
[init_O_rKite,init_Euler,init_O_vKite,init_OwB,init_Az,init_El,init_OcB] = ...
    getInitConditions(fltCtrl.initPathParameter,fltCtrl.pathWidth_deg,...
    fltCtrl.pathHeight_deg,fltCtrl.pathElevation_deg,thrLength,init_speed);
vhcl.setInitPosVecGnd(init_O_rKite,'m');
initVel = calcBcO(init_Euler)*init_O_vKite;
vhcl.setInitVelVecBdy(initVel,'m/s');
vhcl.setInitEulAng(init_Euler,'rad')
% Initial angular velocity is zero
vhcl.setInitAngVelVec(init_OwB,'rad/s');

% wnch.setTetherInitLength(vhcl,gndStn.posVec.Value,env,thr,env.water.flowVec.Value);
wnch.winch1.initLength.setValue(1*norm(vhcl.initPosVecGnd.Value),'m')

thr.tether1.initAirNodePos.setValue(vhcl.initPosVecGnd.Value(:)...
    +rotation_sequence(vhcl.initEulAng.Value)*vhcl.thrAttchPts_B.posVec.Value,'m');


%% Run Simulation
Simulink.sdi.clear;
simWithMonitor('OCTModel')
tsc = signalcontainer(logsout);

%% processing
% figure('WindowState','maximized');
plotResults(tsc);

% lap results
lapStats = tsc.plotAndComputeLapStats(true);

% sgtitle(sprintf('Elevation: %.1f deg, Tether length: %.1f m, Altitude: %.1f m, Wind speed: %.1f m/s',...
%     baselinePathELSp,baselineThrLengthSP,baselineAltSp,flowSpeed));

% fName = sprintf('E=%.1f,TL=%.1f,VW=%.1f',...
%     baselinePathELSp,baselineThrLengthSP,flowSpeed);

allAxes = findall(gcf,'type','axes');
set(allAxes,'FontSize',13);
% exportgraphics(gcf,[fName,'.png'],'Resolution',600);

%% plots

figure; dynamicFigureLocations;
plot(tsc.positionVec.Time,tsc.turnAngle.Data(:)*180/pi); grid on;
ylabel('Desired turn angle [deg]')

figure; dynamicFigureLocations;
plot(tsc.positionVec.Time,tsc.desiredTanRoll.Data(:)*180/pi); grid on;
ylabel('Tangent roll angle [deg]');
hold on;
plot(tsc.positionVec.Time,tsc.tanRoll.Data(:)*180/pi); grid on;
legend('Desired','Actual');

figure; dynamicFigureLocations;
plot(tsc.positionVec.Time,tsc.ctrlSurfDeflCmd.Data(:,1)); grid on;
ylabel('Aileron deflection [deg]')

figure; dynamicFigureLocations;
plot(tsc.positionVec.Time,tsc.tanRoll.Data(:)./max(abs(tsc.tanRoll.Data(:))))
hold on;
plot(tsc.positionVec.Time,tsc.ctrlSurfDeflCmd.Data(:,1)./max(abs(tsc.ctrlSurfDeflCmd.Data(:,1))))
legend('Tan roll','Aileron def.')

figure; dynamicFigureLocations;
plot(tsc.currentPathVar.Data(:),tsc.turnAngle.Data(:)*180/pi); grid on;
hold on;

%% animations
figure; dynamicFigureLocations;
plotDome;
pathCords = pathCoordEqn(fltCtrl.pathWidth_deg,...
    fltCtrl.pathHeight_deg,fltCtrl.pathElevation_deg,1);
plot3(pathCords(1,:),pathCords(2,:),pathCords(3,:),'k-');
normPos = squeeze(tsc.positionVec.Data./...
    vecnorm(tsc.positionVec.Data));
plot3(normPos(1,:),normPos(2,:),normPos(3,:),'r-');
hold on; grid on; axis equal; view(110,20);
xlabel('Norm. X'); ylabel('Norm. Y'); zlabel('Norm. Z');

%%
cIn = maneuverabilityAdvanced;
cIn.pathWidth = fltCtrl.pathWidth_deg;
cIn.pathHeight = fltCtrl.pathHeight_deg;
cIn.meanElevationInRadians = fltCtrl.pathElevation_deg*pi/180;
cIn.tetherLength = norm(init_O_rKite);

figure; dynamicFigureLocations;
tsc1 = tsc.resample(0.5);
animateRes(tsc1,cIn);



