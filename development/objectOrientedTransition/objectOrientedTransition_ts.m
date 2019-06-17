% Script to test the origional model against the modularized model
clear all;clc;

OCTModel_init

load('dsgnAyaz1_2D_Lookup.mat')

% Check that scaling works
scaleFactor = 1;
duration_s = 200;

PLANT = 'modularPlant';

ctrl = threeTetherThreeSurfaceCtrlClass;
ctrl.scale(scaleFactor,1)

simParam = simParamClass;

ini_Rcm_o = [0 0 ctrl.setAltM.Value]';
ini_O_Vcm_o = [0 0 0]';
ini_euler_ang = [0 0 0]';
ini_OwB = [0 0 0]';
initPlatformAngle = 0;
initPlatformAngularVel = 0;

simParam.setInitialConditions('Position',ini_Rcm_o,'Velocity',ini_O_Vcm_o,...
    'EulerAngles',ini_euler_ang,'AngularVelocity',ini_OwB,'PlatformAngle',initPlatformAngle,...
    'PlatformAngularVelocity',initPlatformAngularVel);

simParam = simParam.scale(scaleFactor,1);

thr(1).N                = simParam.N.Value;
thr(1).diameter         = simParam.tether_param.tether_diameter.Value(1);
thr(1).youngsMod        = simParam.tether_param.tether_youngs.Value;
thr(1).density          = simParam.tether_param.tether_density.Value+ simParam.env_param.density.Value;
thr(1).dragCoeff        = simParam.tether_param.CD_cylinder.Value;
thr(1).dampingRatio     = simParam.tether_param.damping_ratio.Value;
thr(1).fluidDensity     = simParam.env_param.density.Value;
thr(1).gravAccel        = simParam.env_param.grav.Value;
thr(1).vehicleMass      = simParam.geom_param.mass.Value;
thr(1).initVhclAttchPt  = simParam.initPosVec.Value +...
    rotation_sequence(simParam.initEulAng.Value)*simParam.tether_imp_nodes.R1n_cm.Value;
thr(1).initGndStnAttchPt = simParam.tether_imp_nodes.R11_g.Value;

thr(2).N                = simParam.N.Value;
thr(2).diameter         = simParam.tether_param.tether_diameter.Value(2);
thr(2).youngsMod        = simParam.tether_param.tether_youngs.Value;
thr(2).density          = simParam.tether_param.tether_density.Value+ simParam.env_param.density.Value;
thr(2).dragCoeff        = simParam.tether_param.CD_cylinder.Value;
thr(2).dampingRatio     = simParam.tether_param.damping_ratio.Value;
thr(2).fluidDensity     = simParam.env_param.density.Value;
thr(2).gravAccel        = simParam.env_param.grav.Value;
thr(2).vehicleMass      = simParam.geom_param.mass.Value;
thr(2).initVhclAttchPt  = simParam.initPosVec.Value +...
    rotation_sequence(simParam.initEulAng.Value)*simParam.tether_imp_nodes.R2n_cm.Value;
thr(2).initGndStnAttchPt = simParam.tether_imp_nodes.R21_g.Value;

thr(3).N                = simParam.N.Value;
thr(3).diameter         = simParam.tether_param.tether_diameter.Value(3);
thr(3).youngsMod        = simParam.tether_param.tether_youngs.Value;
thr(3).density          = simParam.tether_param.tether_density.Value+ simParam.env_param.density.Value;
thr(3).dragCoeff        = simParam.tether_param.CD_cylinder.Value;
thr(3).dampingRatio     = simParam.tether_param.damping_ratio.Value;
thr(3).fluidDensity     = simParam.env_param.density.Value;
thr(3).gravAccel        = simParam.env_param.grav.Value;
thr(3).vehicleMass      = simParam.geom_param.mass.Value;
thr(3).initVhclAttchPt  = simParam.initPosVec.Value +...
    rotation_sequence(simParam.initEulAng.Value)*simParam.tether_imp_nodes.R3n_cm.Value;
thr(3).initGndStnAttchPt = simParam.tether_imp_nodes.R31_g.Value;


gndStnMmtArms(1).arm = simParam.tether_imp_nodes.R11_g.Value;
gndStnMmtArms(2).arm = simParam.tether_imp_nodes.R21_g.Value;
gndStnMmtArms(3).arm = simParam.tether_imp_nodes.R31_g.Value;

lftBdyMmtArms(1).arm = simParam.tether_imp_nodes.R1n_cm.Value;
lftBdyMmtArms(2).arm = simParam.tether_imp_nodes.R2n_cm.Value;
lftBdyMmtArms(3).arm = simParam.tether_imp_nodes.R3n_cm.Value;


ctrl.elevonPitchKp.Value   = 0;
ctrl.elevonPitchKi.Value   = 0;
ctrl.elevonPitchKd.Value   = 0;
ctrl.elevonPitchTau.Value  = 1;

ctrl.elevonRollKp.Value   = 0;
ctrl.elevonRollKi.Value   = 0;
ctrl.elevonRollKd.Value   = 0;
ctrl.elevonRollTau.Value  = 1;

ctrl.tetherAltitudeKp.Value   = 0;
ctrl.tetherAltitudeKi.Value   = 0;
ctrl.tetherAltitudeKd.Value   = 0;
ctrl.tetherAltitudeTau.Value  = 1;

ctrl.tetherPitchKp.Value   = 0;
ctrl.tetherPitchKi.Value   = 0;
ctrl.tetherPitchKd.Value   = 0;
ctrl.tetherPitchTau.Value  = 1;

ctrl.tetherRollKp.Value   = 0;
ctrl.tetherRollKi.Value   = 0;
ctrl.tetherRollKd.Value   = 0;
ctrl.tetherRollTau.Value  = 1;

for ii = 1:length(simParam.unstretched_l.Value)
    winch(ii).initLength = simParam.unstretched_l.Value(ii);
    winch(ii).maxSpeed  = ctrl.winc_vel_up_lims.Value;
    winch(ii).timeConst = simParam.winch_time_const.Value;
    winch(ii).maxAccel = inf;
end

createOrigionalPlantBus;
createConstantUniformFlowEnvironmentBus;

% Calculate setpoints
timeVec = 0:0.1:duration_s;
set_alt = timeseries(ctrl.setAltM.Value*ones(size(timeVec)),timeVec);
set_pitch = timeseries(ctrl.setRollDeg.Value*ones(size(timeVec)),timeVec);
set_roll = timeseries(ctrl.setPitchDeg.Value*ones(size(timeVec)),timeVec);
set_roll.Data = 0*sign(sin(timeVec/(2*pi*200)));
set_roll.Data(timeVec<200) = 0;

switch numel(thr)
    case 3
        createThreeTetherThreeSurfaceCtrlBus;
        CONTROLLER = 'threeTetherThreeSurfaceCtrl';
        caseDescriptor = '3 Tethers';
        
    case 1
        createOneTetherThreeSurfaceCtrlBus;
        CONTROLLER = 'oneTetherThreeSurfaceCtrl';
        caseDescriptor = '1 Tether';
end

if  ctrl.elevonPitchKp.Value == 0
    caseDescriptor = [caseDescriptor ' Open Loop'];
else
    caseDescriptor = [caseDescriptor ' Closed Loop'];
end
caseDescriptor = {caseDescriptor,sprintf('%d Nodes ',thr(1).N)};

fileName = [caseDescriptor{1} caseDescriptor{2} '.gif'];
fileName = strrep(fileName,' ','');
try
sim('OCTModel')
catch
end
parseLogsout

%%
timeVec = 0:1:tsc.winchSpeedCommands.Time(end);

numTethers = numel(tsc.thrNodeBus);
for ii= 1:numTethers
    tsc.thrNodeBus(ii).nodePositions = resample(tsc.thrNodeBus(ii).nodePositions,timeVec);
    tsc.thrAttchPtAirBus(ii).posVec = resample(tsc.thrAttchPtAirBus(ii).posVec,timeVec);
end
tsc.positionVec = resample(tsc.positionVec,timeVec);

h.fig = figure('Position',[1          41        1920         963]);

for ii = 1:numTethers
    h.thr(ii) = plot3(...
        squeeze(tsc.thrNodeBus(ii).nodePositions.Data(1,:,1)),...
        squeeze(tsc.thrNodeBus(ii).nodePositions.Data(2,:,1)),....
        squeeze(tsc.thrNodeBus(ii).nodePositions.Data(3,:,1)),...
        'LineWidth',1.5,'LineStyle','--','Color','k','Marker','x');
    hold on
    grid on
    axis equal
    h.thrAtch(ii) = plot3(...
        [tsc.positionVec.Data(1,:,1) tsc.thrAttchPtAirBus(ii).posVec.Data(1,:,1)],...
        [tsc.positionVec.Data(2,:,1) tsc.thrAttchPtAirBus(ii).posVec.Data(2,:,1)],...
        [tsc.positionVec.Data(3,:,1) tsc.thrAttchPtAirBus(ii).posVec.Data(3,:,1)],...
        'LineWidth',1.5,'LineStyle','-','Color','r','Marker','o');
    
    hold on
    zlim([0 205])
    xlim([-10 70])
    ylim([-25 25])
end


h.title = title({caseDescriptor{1},[caseDescriptor{2} sprintf('Time = %.0f',0)]});
set(gca,'FontSize',24')


frame = getframe(h.fig );
im = frame2im(frame);
[imind,cm] = rgb2ind(im,256);

imwrite(imind,cm,fileName,'gif', 'Loopcount',inf);

for ii = 2:length(timeVec)
    h.title.String = {caseDescriptor{1},[caseDescriptor{2} sprintf('Time = %.0f',timeVec(ii))]};
    for jj = 1:numTethers
        h.thr(jj).XData = tsc.thrNodeBus(jj).nodePositions.Data(1,:,ii);
        h.thr(jj).YData = tsc.thrNodeBus(jj).nodePositions.Data(2,:,ii);
        h.thr(jj).ZData = tsc.thrNodeBus(jj).nodePositions.Data(3,:,ii);
        
        h.thrAtch(jj).XData = [tsc.positionVec.Data(1,:,ii) tsc.thrAttchPtAirBus(jj).posVec.Data(1,:,ii)];
        h.thrAtch(jj).YData = [tsc.positionVec.Data(2,:,ii) tsc.thrAttchPtAirBus(jj).posVec.Data(2,:,ii)];
        h.thrAtch(jj).ZData = [tsc.positionVec.Data(3,:,ii) tsc.thrAttchPtAirBus(jj).posVec.Data(3,:,ii)];
        
    end
    zlim([0 205])
    xlim([-10 70])
    ylim([-25 25])
    drawnow
    frame = getframe(h.fig );
    im = frame2im(frame);
    [imind,cm] = rgb2ind(im,256);
    imwrite(imind,cm,fileName,'gif','WriteMode','append');
end
%%
figure('Position',[1          41        1920         963]);
subplot(4,1,1)
tsc.eulerAngles.plot

subplot(4,1,2)
tsc.angleOfAttackDeg.plot

subplot(4,1,3)
tsc.netPitchMomentCoeff.plot
grid on
hold on
tsc.CMy.plot('LineStyle','--')
plot(tsc.angleOfAttackDeg.Time,interp2(Cmtot_2D_Tbl.Breakpoints(1).Value,Cmtot_2D_Tbl.Breakpoints(2).Value,Cmtot_2D_Tbl.Table.Value',squeeze(tsc.angleOfAttackDeg.Data),0))

subplot(4,1,4)
tsc.MAeroBdy.plot
linkaxes(findall(gcf,'Type','Axes'),'x')

%% Code to calculate pitch moment coefficient
interp2(Cmtot_2D_Tbl.Breakpoints(1).Value,Cmtot_2D_Tbl.Breakpoints(2).Value,Cmtot_2D_Tbl.Table.Value,5,0)

%%
figure
subplot(3,1,1)

