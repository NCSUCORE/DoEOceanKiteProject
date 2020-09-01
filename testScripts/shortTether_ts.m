

%% Test script for John to control the kite model 
Simulink.sdi.clear
clear;clc;%close all
%%  Select sim scenario 
%   0 = fig8;   1 = fig8-rotor;   1.1 = fig8-2rotor;   1.2 = fig8-2rotor New Model;
%   2 = fig8-winch;   3 = steady;  4 = LaR;  4.2 = LaR New Model;
simScenario = 4.2;
%%  Set Physical Test Parameters
thrLength = 400;                                            %   m - Initial tether length 
flwSpd = .25;                                               %   m/s - Flow speed 
lengthScaleFactors = 0.8;                                   %   Factor to scale DOE kite to Manta Ray 
el = 30*pi/180;                                             %   rad - Mean elevation angle 
h = 10*pi/180;  w = 40*pi/180;                              %   rad - Path width/height
[a,b] = boothParamConversion(w,h);                          %   Path basis parameters 
%%  Load components
     minLinkDeviation = .01;
     minSoftLength = 200;
     minLinkLength = 1;                                      %   Length at which tether rediscretizes
     reelSpeed = .25;
     
if simScenario == 3
    loadComponent('baselineSteadyLevelFlight');             %   Steady-level flight controller 
elseif simScenario >= 4
    loadComponent('LaRController');                         %   Launch and recovery controller 
else
    loadComponent('pathFollowingCtrlForManta');             %   Path-following controller 
end
loadComponent('oneDoFGSCtrlBasic');                         %   Ground station controller
loadComponent('pathFollowingGndStn');                       %   Ground station
loadComponent('winchManta');                                %   Winches
if simScenario >= 4
     loadComponent('shortTether');                           %   Tether for reeling
%     loadComponent('MantaTether');                           %   Single link tether
else
    loadComponent('MantaTether');                           %   Single link tether
end
loadComponent('idealSensors')                               %   Sensors
loadComponent('idealSensorProcessing')                      %   Sensor processing
if simScenario == 0  || simScenario == 1 || simScenario == 2 
    loadComponent('MantaKiteNACA2412');                     %   Vehicle with 1 rotor 
elseif simScenario == 1.2 || simScenario == 4.2
    loadComponent('newManta2RotNACA2412');                  %   Vehicle with 2 rotors
else
    loadComponent('Manta2RotNACA2412');                     %   Vehicle with 2 rotors
%     loadComponent('Manta2RotEPP552');                       %   Vehicle with 2 rotors
end
%%  Environment Properties 
loadComponent('ConstXYZT');                                 %   Environment
env.water.setflowVec([flwSpd 0 0],'m/s');                   %   m/s - Flow speed vector 
if simScenario == 0 || simScenario == 1 || simScenario == 2 
    ENVIRONMENT = 'environmentManta';                       %   Single turbine 
else
    ENVIRONMENT = 'environmentManta2Rot';                   %   Two turbines 
%     ENVIRONMENT = 'environmentManta4Rot';                   %   Four turbines
end
%%  Set basis parameters for high level controller
% loadComponent('constEllipse');                              %   High level controller
loadComponent('constBoothLem');                             %   High level controller
if strcmpi(PATHGEOMETRY,'ellipse')
    hiLvlCtrl.basisParams.setValue([w,h,el,0*pi/180,thrLength],'[rad rad rad rad m]') % Ellipse
else
    hiLvlCtrl.basisParams.setValue([a,b,el,0*pi/180,thrLength],'[rad rad rad rad m]') % Lemniscate of Booth
end
%%  Ground Station Properties
gndStn.setPosVec([0 0 0],'m')
gndStn.setVelVec([0 0 0],'m/s')
gndStn.initAngPos.setValue(0,'rad');
gndStn.initAngVel.setValue(0,'rad/s');
%%  Vehicle Properties 
vhcl.setICsOnPath(.05,PATHGEOMETRY,hiLvlCtrl.basisParams.Value,gndStn.posVec.Value,(11/2)*norm(env.water.flowVec.Value))
if simScenario >= 3
    vhcl.setICsOnPath(0,PATHGEOMETRY,hiLvlCtrl.basisParams.Value,gndStn.posVec.Value,0)
    vhcl.setInitEulAng([0,0,0]*pi/180,'rad')
end
if simScenario == 0 || simScenario == 2 
    vhcl.turb1.setDiameter(0,'m')
end
%%  Tethers Properties
thr.tether1.initGndNodePos.setValue(gndStn.thrAttch1.posVec.Value(:)+gndStn.posVec.Value(:),'m');
thr.tether1.initAirNodePos.setValue(vhcl.initPosVecGnd.Value(:)...
    +rotation_sequence(vhcl.initEulAng.Value)*vhcl.thrAttchPts_B.posVec.Value,'m');
thr.tether1.initGndNodeVel.setValue([0 0 0]','m/s');
thr.tether1.initAirNodeVel.setValue(vhcl.initVelVecBdy.Value(:),'m/s');
thr.tether1.vehicleMass.setValue(vhcl.mass.Value,'kg');
thr.tether1.setDensity(env.water.density.Value,thr.tether1.density.Unit);
thr.tether1.setDiameter(0.007,thr.tether1.diameter.Unit);
thr.tether1.setYoungsMod(thr.tether1.youngsMod.Value*1.2,thr.tether1.youngsMod.Unit);
%%  Winches Properties
wnch.setTetherInitLength(vhcl,gndStn.posVec.Value,env,thr,env.water.flowVec.Value);
wnch.winch1.LaRspeed.setValue(reelSpeed,'m/s');
%%  Controller User Def. Parameters and dependant properties
fltCtrl.setFcnName(PATHGEOMETRY,''); % PATHGEOMETRY is defined in fig8ILC_bs.m
fltCtrl.setInitPathVar(vhcl.initPosVecGnd.Value,...
    hiLvlCtrl.basisParams.Value,gndStn.posVec.Value);
if simScenario ~= 2
    fltCtrl.setFirstSpoolLap(1000,'');
end
fltCtrl.rudderGain.setValue(0,'')
if simScenario == 1.2
    fltCtrl.setElevatorReelInDef(-20,'deg')
else 
    fltCtrl.setElevatorReelInDef(0,'deg')
end
fltCtrl.tanRoll.setKp(fltCtrl.tanRoll.kp.Value*1,fltCtrl.tanRoll.kp.Unit);
%%  Steady-flight controller parameters 
if simScenario >= 3
    vhcl.setInitEulAng([0,0,0]*pi/180,'rad');
    fltCtrl.LaRelevationSP.setValue(35,'deg');          fltCtrl.LaRelevationSPErr.setValue(1,'deg');        %   Elevation setpoints
    fltCtrl.pitchSP.kp.setValue(10,'(deg)/(deg)');      fltCtrl.pitchSP.ki.setValue(.001,'(deg)/(deg*s)');    %   Elevation angle outer-loop controller 
    fltCtrl.elevCmd.kp.setValue(200,'(deg)/(rad)');     fltCtrl.elevCmd.ki.setValue(5,'(deg)/(rad*s)');    %   Elevation angle inner-loop controller 
%     fltCtrl.elevCmd.kp.setValue(0,'(deg)/(rad)');       fltCtrl.elevCmd.ki.setValue(0,'(deg)/(rad*s)');
    fltCtrl.pitchAngleMax.upperLimit.setValue(45,'');   fltCtrl.pitchAngleMax.lowerLimit.setValue(-45,'');
    fltCtrl.setNomSpoolSpeed(reelSpeed,'m/s');                fltCtrl.setSpoolCtrlTimeConstant(5,'s');
    wnch.winch1.elevError.setValue(2,'deg');
    vhcl.turb1.setPowerCoeff(0,'');
end
tRef = [0  250 500 750 1000 1250 1500 1750 2000 2250 2500 2750 3000];
pSP =  [30 30  30  30  30   40   40   40   40   40   40   40   40];    
thr.tether1.dragEnable.setValue(0,'');
% vhcl.rBridle_LE.setValue([0,0,0]','m');
%%  Set up critical system parameters and run simulation
simParams = SIM.simParams;  simParams.setDuration(10000,'s');  dynamicCalc = '';
simWithMonitor('OCTModel')
%%  Log Results 
tsc = signalcontainer(logsout);
dt = datestr(now,'mm-dd_HH-MM');
if simScenario == 0
    filename = sprintf(strcat('Manta_EL-%.1f_w-%.1f_h-%.1f_',dt,'.mat'),el*180/pi,w*180/pi,h*180/pi);
    fpath = fullfile(fileparts(which('OCTProject.prj')),'Results','Manta\');
elseif simScenario == 1
    filename = sprintf(strcat('Turb_EL-%.1f_D-%.2f_w-%.1f_h-%.1f_',dt,'.mat'),el*180/pi,vhcl.turb1.diameter.Value,w*180/pi,h*180/pi);
    fpath = fullfile(fileparts(which('OCTProject.prj')),'Results','Manta','Rotor\');
elseif simScenario == 1.1
    filename = sprintf(strcat('Turb2_V-%.2f_EL-%.1f_D-%.2f_w-%.1f_h-%.1f_',dt,'.mat'),flwSpd,el*180/pi,vhcl.turb1.diameter.Value,w*180/pi,h*180/pi);
    fpath = fullfile(fileparts(which('OCTProject.prj')),'Results','Manta','Rotor\');
elseif simScenario == 1.2
    filename = sprintf(strcat('Turb2_V-%.2f_EL-%.1f_D-%.2f_w-%.1f_h-%.1f_',dt,'.mat'),flwSpd,el*180/pi,vhcl.turb1.diameter.Value,w*180/pi,h*180/pi);
    fpath = fullfile(fileparts(which('OCTProject.prj')),'Results','Manta 2.0','Rotor\');
elseif simScenario == 2
    filename = sprintf(strcat('Winch_EL-%.1f_Thr-%d_w-%.1f_h-%.1f_',dt,'.mat'),el*180/pi,thrLength,w*180/pi,h*180/pi);
    fpath = fullfile(fileparts(which('OCTProject.prj')),'Results','Manta','Winch\');
elseif simScenario == 3
    filename = sprintf(strcat('Steady_EL-%.1f_kp-%.2f_ki-%.2f_kd-%.2f_',dt,'.mat'),el*180/pi,fltCtrl.pitchMoment.kp.Value,fltCtrl.pitchMoment.ki.Value,fltCtrl.pitchMoment.kd.Value);
    fpath = fullfile(fileparts(which('OCTProject.prj')),'Results','Manta','Steady\');
elseif simScenario == 4
%     filename = sprintf(strcat('LaR_EL-%.1f_SP-%.1f_t-%.1f_Wnch-%.1f_',dt,'.mat'),el*180/pi,fltCtrl.LaRelevationSP.Value,simParams.duration.Value,fltCtrl.nomSpoolSpeed.Value);
%     filename = sprintf(strcat('Elevation_kp-%.1f_ki-%.2f_',dt,'.mat'),fltCtrl.pitchSP.kp.Value,fltCtrl.pitchSP.ki.Value);
    filename = sprintf(strcat('PitchStep_kp-%.1f_ki-%.1f_',dt,'.mat'),fltCtrl.elevCmd.kp.Value,fltCtrl.elevCmd.ki.Value);
    fpath = fullfile(fileparts(which('OCTProject.prj')),'Results','Manta','LaR\');
elseif simScenario == 4.2
%     filename = sprintf(strcat('LaR_EL-%.1f_SP-%.1f_t-%.1f_Wnch-%.1f_',dt,'.mat'),el*180/pi,fltCtrl.LaRelevationSP.Value,simParams.duration.Value,fltCtrl.nomSpoolSpeed.Value);
    filename = sprintf(strcat('Elevation_kp-%.1f_ki-%.3f_',dt,'.mat'),fltCtrl.pitchSP.kp.Value,fltCtrl.pitchSP.ki.Value);
%     filename = sprintf(strcat('Pitch_kp-%.1f_ki-%.1f_',dt,'.mat'),fltCtrl.elevCmd.kp.Value,fltCtrl.elevCmd.ki.Value);
    fpath = fullfile(fileparts(which('OCTProject.prj')),'Results','Manta 2.0','LaR\');
end
% save(strcat(fpath,filename),'tsc','vhcl','thr','fltCtrl','env','simParams','LIBRARY','gndStn')
%%  Animate Simulation 
% if simScenario <= 2
%     vhcl.animateSim(tsc,2,'PathFunc',fltCtrl.fcnName.Value,...
%         'GifTimeStep',.05,'PlotTracer',true,'FontSize',12,'Pause',false,...
%         'ZoomIn',1==1,'SaveGif',1==0,'GifFile',strrep(filename,'.mat','.gif'));
% else
%     vhcl.animateSim(tsc,2,'View',[0,0],...
%         'GifTimeStep',.05,'PlotTracer',true,'FontSize',12,'ZoomIn',1==1,...
%         'SaveGif',1==0,'GifFile',strrep(filename,'.mat','0.gif'));
% end
%%  Plot Results
if simScenario < 3
    tsc.plotFlightResults(vhcl,env,'plot1Lap',1==1,'plotS',1==1,'Vapp',false,'plotBeta',1==1)
%     tsc.plotTanAngles('plot1Lap',true,'plotS',true)
%     tsc.plotPower(vhcl,env,'plot1Lap',true,'plotS',true,'Lap1',1,'Color',[0 0 1],'plotLoyd',false)
else
    tsc.plotLaR(fltCtrl);
%     simStabilityCheck
end
% set(gcf,'OuterPosition',[347.4000  192.2000  590.4000  652.0000]);
%%  Compare to old results 
% tsc.turbEnrg.Data(1,1,end)
% load('C:\Users\John Jr\Desktop\Manta Ray\Model\Results\Manta\Rotor\Turb2_V-0.25_EL-30.0_D-0.56_w-40.0_h-15.0_08-04_10-56.mat')
% tsc.turbEnrg.Data(1,1,end)



figure(5)
    clear('AirTen1')
    clear('GndTen1')
    for jj = 1:size(tsc.airTenVecs.Data(:,:),2)
        AirTen1(1,jj) = norm(tsc.airTenVecs.Data(:,jj));
        GndTen1(1,jj) = norm(tsc.gndNodeTenVecs.Data(:,jj));
    end
    %%
    hold on
    plot(tsc.airTenVecs.Time,AirTen1,'g')
    title('Kite Tension for Reel In')
    hold on
    plot(tsc.gndNodeTenVecs.Time,GndTen1,'m')
    yyaxis right;
    plot(tsc.tetherLengths.Time,tsc.tetherLengths.Data(1,:),'r')
    plot(tsc.tetherLengths.Time,ceil(tsc.tetherLengths.Data(1,:).*.01).*100,'b')
    %plot(tsc.tetherLengths.Time,ceil(tsc.tetherLengths.Data(1,:).*.01).*100)
    hold off
    ylabel('Tether Length (m)')
    set(gca,'YColor','k');
    yyaxis left;
    title('Ground (AUV) Tension')
    xlabel('Time (s)')
    ylabel('Force (N)')
    legend('Air Tension tether','Ground Tension','Tether Length','Links Reeled Out')

%%

% 
% Plotting
%Euler Angles
figure(1)
    subplot(3,1,1)
    plot(tsc.eulerAngles.Time,tsc.eulerAngles.Data(1,:))
    title('Euler Angles')
    subplot(3,1,2)   
    plot(tsc.eulerAngles.Time,tsc.eulerAngles.Data(2,:))
    hold on 
    subplot(3,1,3) 
    plot(tsc.eulerAngles.Time,tsc.eulerAngles.Data(3,:))
    hold on 
    %legend('Current tether','New Tether')
    xlabel('Time (s)')
    ylabel('Angle (rad)')

%Positions
figure(2)
    subplot(3,1,1)
    plot(tsc.positionVec.Time,tsc.positionVec.Data(1,:))
    hold on 
    title('Kite Positions')
    subplot(3,1,2)   
    plot(tsc.positionVec.Time,tsc.positionVec.Data(2,:))
    hold on 
    subplot(3,1,3) 
    plot(tsc.positionVec.Time,tsc.positionVec.Data(3,:))
    hold on 
    %legend('Current tether','New Tether')
    xlabel('Time (s)')
    ylabel('Position (m)')
%Velocities
figure(3)
    subplot(3,1,1)
    plot(tsc.velocityVec.Time,tsc.velocityVec.Data(1,:))
    hold on 
    title('Kite Velocities')
    subplot(3,1,2)   
    plot(tsc.velocityVec.Time,tsc.velocityVec.Data(2,:))
    hold on 
    subplot(3,1,3) 
    plot(tsc.velocityVec.Time,tsc.velocityVec.Data(3,:))
    hold on 
    %legend('Current tether','New Tether')
    xlabel('Time (s)')
    ylabel('Velocity (m/s)')
%Angular Velocities
figure(4)
    subplot(3,1,1)
    plot(tsc.angularVel.Time,tsc.angularVel.Data(1,:))
    hold on 
    title('Kite Angular Velocities')
    subplot(3,1,2)   
    plot(tsc.angularVel.Time,tsc.angularVel.Data(2,:))
    hold on 
    subplot(3,1,3) 
    plot(tsc.angularVel.Time,tsc.angularVel.Data(3,:))
    hold on 
    %legend('Current tether','New Tether')
    xlabel('Time (s)')
    ylabel('Ang Vel (rad/sec)')



% vhcl.animateSim(tsc,10,'SaveGif',false)

% % This is the section where the simulation parameters are set. Mainly the
% Simulink.sdi.clear
% clear;clc;close all
% simParams = SIM.simParams;
% simParams.setDuration(20,'s');
% 
% dynamicCalc = '';
% 
% % set tether number "000 or 001"
% 
% TetherNum = 001;
% %%
% %%%1
% MinLinkLength    = 1;a=1;b=0;c=0;%[.01,.1,1,10];a=1;b=0;c=0;
% A = MinLinkLength;
% minLinkDeviation = .1;
% minSoftLength    = 0;
% % for ii = 1:length(MinLinkLength)
% 
% %
% %%.1
% % MinLinkDeviation = [.0001,.001,.01,.1];a=0;b=1;c=0;
% % A = MinLinkDeviation;
% % minLinkLength     = 1;
% % minSoftLength     = 0;
% % for ii = 1:length(MinLinkDeviation)
%  
% %%
% %%%1
% % MinSoftLength   = 0; a=0;b=0;c=1;%[.001,.01,.1,1];a=0;b=0;c=1;
% % A = MinSoftLength;
% % minLinkLength    = .01;
% % minLinkDeviation = .001;
% %for ii = 1:length(MinSoftLength)
%   
%     %% Load components
% ii = 1;
% for TetherNum = 001%[000, 001]
%     %This is the section where all of the objects, simulation parameters and
%     %variant subsystem identifiers are loaded into the model
% 
%     % Flight Controller
% %     loadComponent('newSpoolCtrl');
%     loadComponent('LaRController');
%     %loadComponent('fullCycleCtrl');
%     %loadComponent('pathFollowingCtrlForILC');
% 
%     % Ground station controller
%     loadComponent('oneDoFGSCtrlBasic');
%     % High level controller
%     loadComponent('constBoothLem');
%     % Ground station
%     loadComponent('pathFollowingGndStn');
%     % Winches
%     loadComponent('oneDOFWnch');
%     % Tether
%     if TetherNum==000
%         loadComponent('shortTetherCompare');
%     elseif TetherNum==001
%         loadComponent('shortTether');
%     end
% 
%     % Vehicle
% %     loadComponent('fullScale1thr');
%     loadComponent('MantaFullScale1thr');
%     % Environment
%     loadComponent('constXYZT');
%     % Sensors
%     loadComponent('idealSensors')
%     % Sensor processing
%     loadComponent('idealSensorProcessing')
% 
%     %%
% %     if a==1
% %         thr.tether1.setMinLinkLength(MinLinkLength(ii),'m');
% %     end
% %     if b==1
% %         thr.tether1.setMinLinkDeviation(MinLinkDeviation(ii),'m');
% %     end
% %     if c==1
% %         thr.tether1.setMinSoftLength(MinSoftLength(ii),'m');
% %     end
%     %% Environment IC's and dependant properties
% 
%     %if you are using constant flow, this is where the constant flow speed is
%     %set
%     env.water.setflowVec([.25 0 0],'m/s')
% 
%     %% Set basis parameters for high level controller
% 
%     %This is where the path parameters are set. The first value dictates the
%     %width of the figure eight, the second determines the height, the third
%     %determines the center of the paths elevation angle, the four sets the path
%     %centers azimuth angle, the fifth is the initial tether length
%     hiLvlCtrl.basisParams.setValue(...
%         [.8,1.6,30*pi/180,0*pi/180,400],...
%         '[rad rad rad rad m]') % Lemniscate of Booth
% 
% 
%     %% Ground Station IC's and dependant properties
% 
%     % this is where the ground station initial parameters are set. 
%     gndStn.setPosVec([0 0 0],'m')
%     gndStn.setVelVec([0 0 0],'m/s')
%     gndStn.initAngPos.setValue(0,'rad');
%     gndStn.initAngVel.setValue(0,'rad/s');
% 
%     %% Set vehicle initial conditions
% 
%     %This is where the vehicle initial conditions are aet.
% %     vhcl.setICsOnPath(...
% %         0,... % Initial path position
% %         PATHGEOMETRY,... % Name of path function
% %         hiLvlCtrl.basisParams.Value,... % Geometry parameters
% %         gndStn.posVec.Value,... % Center point of path sphere
% %         (11/2)*norm(env.water.flowVec.Value)) % Initial speed
%     vhcl.setICsOnPath(0,PATHGEOMETRY,hiLvlCtrl.basisParams.Value,gndStn.posVec.Value,0)
%     vhcl.setInitEulAng([0,0,0]*pi/180,'rad')
%     %% Tethers IC's and dependant properties'
% 
%     % This is where the Kite tether initial conditions and parameter values are set
% 
%     if TetherNum==000 %Tether000
%         thr.tether1.initGndNodePos.setValue(gndStn.thrAttch1.posVec.Value(:)...
%             +gndStn.posVec.Value(:),'m');
%         thr.tether1.initAirNodePos.setValue(vhcl.initPosVecGnd.Value(:)...
%             +rotation_sequence(vhcl.initEulAng.Value)*vhcl.thrAttchPts_B.posVec.Value,'m');
%         thr.tether1.initGndNodeVel.setValue([0 0 0]','m/s');
%         thr.tether1.initAirNodeVel.setValue(vhcl.initVelVecBdy.Value(:),'m/s');
%         thr.tether1.vehicleMass.setValue(vhcl.mass.Value,'kg');
%     elseif TetherNum==001%Tether001
%         thr.tether1.setInitGndNodePos(gndStn.thrAttch1.posVec.Value(:)...
%             +gndStn.posVec.Value(:),'m');
%         thr.tether1.setInitAirNodePos(vhcl.initPosVecGnd.Value(:)...
%             +rotation_sequence(vhcl.initEulAng.Value)*vhcl.thrAttchPts_B.posVec.Value,'m');
%         thr.tether1.setInitGndNodeVel([0 0 0]','m/s');
%         thr.tether1.setInitAirNodeVel(vhcl.initVelVecBdy.Value(:),'m/s');
%         thr.tether1.setVehicleMass(vhcl.mass.Value,'kg');
%     end
% 
% 
%     %% Winches IC's and dependant properties
%     %this sets the initial tether length that the winch has spooled out
%     wnch.setTetherInitLength(vhcl,gndStn.posVec.Value,env,thr,env.water.flowVec.Value);
% 
%     %% Controller User Def. Parameters and dependant properties
% 
%     % This is where the path geometry is set, (lemOfBooth is figure eight, race track, ellipse,ect...) 
%     fltCtrl.setFcnName(PATHGEOMETRY,''); % PATHGEOMETRY is defined in fig8ILC_bs.m
%     % Set initial conditions
%     fltCtrl.setInitPathVar(vhcl.initPosVecGnd.Value,...
%         hiLvlCtrl.basisParams.Value,...
%         gndStn.posVec.Value);
% % fltCtrl.setInitTL(400,'m')
% 
%     %% Run the simulation
%     % this is where the simulation is commanded to run
%     if a==1
%         minLinkLength = MinLinkLength(ii);
%     end
%     if b==1
%         minLinkDeviation = MinLinkDeviation(ii);
%     end
%     if c==1
%         minSoftLength = MinSoftLength(ii);
%     end
%     
%     simWithMonitor('OCTModel')
%     tsc = signalcontainer(logsout);
% 
%     %this stores all of the logged signals from the model. To veiw, type
% %     %tsc.signalname.data to view data, tsc.signalname.plot to plot etc.
% %     if TetherNum == 000
% %         tsc = signalcontainer(logsout);
% %     elseif TetherNum == 001
% %         tsc2 = signalcontainer(logsout);
% %     end
% 
% %    tsc{ii} = signalcontainer(logsout);
% %     %vhcl.animateSim(tsc,.5)
%     %%
%     % figure(2)
%     % Tension = [];
%     % for ii=1:size(tsc.airTenVecs.Data,3)
%     %     Tension(ii) = norm(tsc.airTenVecs.Data(:,:,ii));
%     % end
%     % plot(tsc.airTenVecs.Time,Tension)
% end
% %%
% vhcl.animateSim(tsc,2,'View',[0,0],'FigPos',[488-00 342 560 420],...
%     'GifTimeStep',.05,'PlotTracer',true,'FontSize',12,...
%     'Pause',false,'ZoomIn',false,'SaveGif',true,'GifFile','Tether_Reelin_V-1.gif');
% %     'Pause',false,'ZoomIn',true,'SaveGif',true,'GifFile','Tether_Reelin_V-1.gif');
% 
% %%
% % for ii = 1:length(A)
% %     for jj = 1:size(tsc{ii}.airTenVecs.Data(:,:),2)
% %         AirTen(ii,jj) = norm(tsc{ii}.airTenVecs.Data(:,jj));
% %         GndTen(ii,jj) = norm(tsc{ii}.gndNodeTenVecs.Data(:,jj));
% %     end
% % end
% 
% 
% %%
% 
% % for ii = 1:length(A)
% %     clear('AirTen')
% %     clear('GndTen')
% %     for jj = 1:size(tsc{ii}.airTenVecs.Data(:,:),2)
% %         AirTen(1,jj) = norm(tsc{ii}.airTenVecs.Data(:,jj));
% %         GndTen(1,jj) = norm(tsc{ii}.gndNodeTenVecs.Data(:,jj));
% %     end
% %     subplot(2,1,1)
% %     hold on
% %     plot(tsc{ii}.airTenVecs.Time,AirTen)
% %     hold off
% %     title('Kite Tension')
% %     subplot(2,1,2)
% %     hold on
% %     plot(tsc{ii}.gndNodeTenVecs.Time,GndTen)
% %     hold off
% %     title('Ground (AUV) Tension')
% %     xlabel('Time (s)')
% % end
% % 
% % if a==1
% %     legend(num2str(MinLinkLength(1)),num2str(MinLinkLength(2)),num2str(MinLinkLength(3)),num2str(MinLinkLength(4)),'Location','northeast')
% % end
% % if b==1
% %     legend(num2str(MinLinkDeviation(1)),num2str(MinLinkDeviation(2)),num2str(MinLinkDeviation(3)),num2str(MinLinkDeviation(4)),'Location','northeast')
% % end
% % if c==1
% %     legend(num2str(MinSoftLength(1)),num2str(MinSoftLength(2)),num2str(MinSoftLength(3)),num2str(MinSoftLength(4)),'Location','northeast')
% % end
% 
% 
% % 
% % Plotting
% %Euler Angles
% figure(1)
%     subplot(3,1,1)
%     plot(tsc.eulerAngles.Time,tsc.eulerAngles.Data(1,:))
%     hold on 
%     plot(tsc2.eulerAngles.Time,tsc2.eulerAngles.Data(1,:))
%     title('Euler Angles')
%     subplot(3,1,2)   
%     plot(tsc.eulerAngles.Time,tsc.eulerAngles.Data(2,:))
%     hold on 
%     plot(tsc2.eulerAngles.Time,tsc2.eulerAngles.Data(2,:))
%     subplot(3,1,3) 
%     plot(tsc.eulerAngles.Time,tsc.eulerAngles.Data(3,:))
%     hold on 
%     plot(tsc2.eulerAngles.Time,tsc2.eulerAngles.Data(3,:))
%     legend('Current tether','New Tether')
%     xlabel('Time (s)')
%     ylabel('Angle (rad)')
% 
% %Positions
% figure(2)
%     subplot(3,1,1)
%     plot(tsc.positionVec.Time,tsc.positionVec.Data(1,:))
%     hold on 
%     plot(tsc2.positionVec.Time,tsc2.positionVec.Data(1,:))
%     title('Kite Positions')
%     subplot(3,1,2)   
%     plot(tsc.positionVec.Time,tsc.positionVec.Data(2,:))
%     hold on 
%     plot(tsc2.positionVec.Time,tsc2.positionVec.Data(2,:))
%     subplot(3,1,3) 
%     plot(tsc.positionVec.Time,tsc.positionVec.Data(3,:))
%     hold on 
%     plot(tsc2.positionVec.Time,tsc2.positionVec.Data(3,:))
%     legend('Current tether','New Tether')
%     xlabel('Time (s)')
%     ylabel('Position (m)')
% %Velocities
% figure(3)
%     subplot(3,1,1)
%     plot(tsc.velocityVec.Time,tsc.velocityVec.Data(1,:))
%     hold on 
%     plot(tsc2.velocityVec.Time,tsc2.velocityVec.Data(1,:))
%     title('Kite Velocities')
%     subplot(3,1,2)   
%     plot(tsc.velocityVec.Time,tsc.velocityVec.Data(2,:))
%     hold on 
%     plot(tsc2.velocityVec.Time,tsc2.velocityVec.Data(2,:))
%     subplot(3,1,3) 
%     plot(tsc.velocityVec.Time,tsc.velocityVec.Data(3,:))
%     hold on 
%     plot(tsc2.velocityVec.Time,tsc2.velocityVec.Data(3,:))
%     legend('Current tether','New Tether')
%     xlabel('Time (s)')
%     ylabel('Velocity (m/s)')
% %Angular Velocities
% figure(4)
%     subplot(3,1,1)
%     plot(tsc.angularVel.Time,tsc.angularVel.Data(1,:))
%     hold on 
%     plot(tsc2.angularVel.Time,tsc2.angularVel.Data(1,:))
%     title('Kite Angular Velocities')
%     subplot(3,1,2)   
%     plot(tsc.angularVel.Time,tsc.angularVel.Data(2,:))
%     hold on 
%     plot(tsc2.angularVel.Time,tsc2.angularVel.Data(2,:))
%     subplot(3,1,3) 
%     plot(tsc.angularVel.Time,tsc.angularVel.Data(3,:))
%     hold on 
%     plot(tsc2.angularVel.Time,tsc2.angularVel.Data(3,:))
%     legend('Current tether','New Tether')
%     xlabel('Time (s)')
%     ylabel('Ang Vel (rad/sec)')
% 
%%

% 
%     
%     vhcl.animateSim(tsc2,.5,'SaveGif',false)
vhcl.animateSim(tsc,.5,'SaveGif',true)