%% Test script for pool test simulation of the kite model
clear;clc;close all;
Simulink.sdi.clear
%%  Set Test Parameters
saveSim = 0;               %   Flag to save results
runLin = 0;                %   Flag to run linearization
thrArray = 2.68;%[200:400:600];%:25:600];
altitudeArray = 1.5;%[100:200:300];%150:25:300];
flwSpdArray = -0.0001;%[0.1:0.1:.5]; 
inc = [-6:2:-2];
towArray = rpm2speed([50 65 80]);%[0.5:.15:.8];
distFreq = 0;
distAmp = 0;
pertVec = [0 1 0];
for i = 1:length(inc)
    for j = 1:length(towArray)
thrLength = 3;  altitude = thrLength*sin(40/180*pi);                 %   Initial tether length/operating altitude/elevation angle 
flwSpd = -.0001 ;                                   %   m/s - Flow speed
Tmax = 38;                                                  %   kN - Max tether tension 
h = 25*pi/180;  w = 100*pi/180;                             %   rad - Path width/height
[a,b] = boothParamConversion(w,h);                          %   Path basis parameters
%%  Load components
fpath = fullfile(fileparts(which('OCTProject.prj')),...
    'vehicleDesign\Tether\Tension\');
maxT = load([fpath,sprintf('TmaxStudy_%dkN.mat',Tmax)]);
el = asin(altitude/thrLength);
    loadComponent('exp_slCtrl');   
% loadComponent('pathFollowCtrlExp');                         %   Path-following controller with AoA control
% FLIGHTCONTROLLER = 'pathFollowingControllerExp';
loadComponent('oneDoFGSCtrlBasic');                         %   Ground station controller
% loadComponent('MantaGndStn');                             %   Ground station
loadComponent('raftGroundStation');  


loadComponent('winchManta');                                %   Winches
loadComponent('MantaTether');                               %   Manta Ray tether
loadComponent('idealSensors')                               %   Sensors
loadComponent('idealSensorProcessing')                      %   Sensor processing
loadComponent('Manta2RotXFoil_AR8_b8_exp_3dPrinted');                %   AR = 8; 8m span
SIXDOFDYNAMICS        = "sixDoFDynamicsCoupledFossen12int";
%%  Environment Properties
loadComponent('ConstXYZT');                                 %   Environment
env.water.setflowVec([flwSpd 0 0],'m/s');                   %   m/s - Flow speed vector
    ENVIRONMENT = 'environmentManta2RotBandLin';            %   Two turbines
%%  Set basis parameters for high level controller

loadComponent('constBoothLem');        %   High level controller
% PATHGEOMETRY = 'lemOfBoothInv'
% hiLvlCtrl.elevationLookup.setValue(maxT.R.EL,'deg');
% 
% hiLvlCtrl.ELctrl.setValue(1,'');
% hiLvlCtrl.ELslew.setValue(0.25,'deg/s');
% hiLvlCtrl.ThrCtrl.setValue(1,'');

hiLvlCtrl.basisParams.setValue([a,b,-el,180*pi/180,thrLength-.1],'[rad rad rad rad m]') % Lemniscate of Booth
%%  Ground Station Properties
%% Set up pool raft parameters
theta = 30*pi/180;
T_tether = 100; %N
phi_max = 30*pi/180;
omega_kite = 2*pi/5; %rad/s
m_raft = 50; %kg
J_raft = 30;
tow_length = 16;
tow_speed = towArray(j);    
end_time = tow_length/tow_speed;
x_init = 4;
y_init = 0;
y_dot_init = 0;
psi_init = 0;
psi_dot_init = 0;
initGndStnPos = [x_init;y_init;3];

thrAttachInit = initGndStnPos;
%%  Vehicle Properties
% vhcl.setICsOnPath(.85,PATHGEOMETRY,hiLvlCtrl.basisParams.Value,initGndStnPos,6.5*abs(flwSpd)*norm([1;0;0]))
    vhcl.setICsOnPath(0,PATHGEOMETRY,hiLvlCtrl.basisParams.Value,initGndStnPos,0);
%     vhcl.setInitPosVecGnd(vhcl.initPosVecGnd.Value+[0;.1;0],'m')
    vhcl.setInitEulAng([180 0 180]*pi/180,'rad');
    vhcl.setInitVelVecBdy([0 0 0],'m/s');
%%  Tethers Properties
load([fileparts(which('OCTProject.prj')),'\vehicleDesign\Tether\tetherDataNew.mat']);
thr.tether1.initGndNodePos.setValue(thrAttachInit,'m');
thr.tether1.initAirNodePos.setValue(vhcl.initPosVecGnd.Value(:)...
    +rotation_sequence(vhcl.initEulAng.Value)*vhcl.thrAttchPts_B.posVec.Value,'m');
thr.tether1.initGndNodeVel.setValue([-tow_speed 0 0]','m/s');
thr.tether1.initAirNodeVel.setValue(vhcl.initVelVecBdy.Value(:),'m/s');
thr.tether1.vehicleMass.setValue(vhcl.mass.Value,'kg');
thr.tether1.youngsMod.setValue(eval(sprintf('AR8b8.length600.tensionValues%d.youngsMod',Tmax))/5,'Pa');
thr.tether1.density.setValue(eval(sprintf('AR8b8.length600.tensionValues%d.density',Tmax)),'kg/m^3');
thr.tether1.setDiameter(.0076,'m');
thr.setNumNodes(20,'');
thr.tether1.setDragCoeff(1.25,'');
%%  Winches Properties
wnch.setTetherInitLength(vhcl,thrAttachInit,env,thr,env.water.flowVec.Value);
wnch.winch1.LaRspeed.setValue(1,'m/s');
%%  Controller User Def. Parameters and dependant properties
fltCtrl.setFcnName(PATHGEOMETRY,'');
fltCtrl.setInitPathVar(vhcl.initPosVecGnd.Value,hiLvlCtrl.basisParams.Value,thrAttachInit);
fltCtrl.setPerpErrorVal(.25,'rad')
fltCtrl.rudderGain.setValue(0,'')
fltCtrl.rollMoment.kp.setValue(50,'(N*m)/(rad)')
fltCtrl.rollMoment.ki.setValue(0,'(N*m)/(rad*s)');
fltCtrl.rollMoment.kd.setValue(25,'(N*m)/(rad/s)')
fltCtrl.tanRoll.kp.setValue(.45,'(rad)/(rad)')
thr.tether1.dragEnable.setValue(1,'')
vhcl.hStab.setIncidence(inc(i),'deg');


% vhcl.stbdWing.setCL(zeros(length(vhcl.stbdWing.CL.Value),1),'');
% vhcl.stbdWing.setCD(zeros(length(vhcl.stbdWing.CD.Value),1),'');
% vhcl.portWing.setCL(zeros(length(vhcl.portWing.CL.Value),1),'');
% vhcl.portWing.setCD(zeros(length(vhcl.portWing.CD.Value),1),'');
% vhcl.vStab.setCL(zeros(length(vhcl.vStab.CL.Value),1),'');
% vhcl.vStab.setCD(zeros(length(vhcl.vStab.CD.Value),1),'');
% vhcl.hStab.setCL(zeros(length(vhcl.hStab.CL.Value),1),'');
% vhcl.hStab.setCD(zeros(length(vhcl.hStab.CD.Value),1),'');
% vhcl.portWing.setGainCL(0,'1/deg');
% vhcl.portWing.setGainCD(0,'1/deg');
% vhcl.stbdWing.setGainCL(0,'1/deg');
% vhcl.stbdWing.setGainCD(0,'1/deg');
% vhcl.vStab.setGainCL(0,'1/deg');
% vhcl.vStab.setGainCD(0,'1/deg');
% vhcl.hStab.setGainCL(0,'1/deg');
% vhcl.hStab.setGainCD(0,'1/deg');
% vhcl.fuse.setEndDragCoeff(0,'');
% vhcl.fuse.setSideDragCoeff(0,'');
% vhcl.setBuoyFactor(1,'');
% vhcl.setVolume(.01,'m^3');
% vhcl.setRBridle_LE([0,0,0],'m');
% vhcl.setRCM_LE([0,0,0],'m');
% vhcl.setRCentOfBuoy_LE([0,0,0],'m');
% vhcl.setMa6x6_LE(zeros(6),'')

%%  Set up critical system parameters and run simulation
    simParams = SIM.simParams;  simParams.setDuration(end_time,'s');  dynamicCalc = '';
%     open_system('OCTModel')
%     set_param('OCTModel','SimulationMode','accelerator');
    simWithMonitor('OCTModel')
    tsc1{i,j} = signalcontainer(logsout);
    %%
    totalDrag = sum(squeeze(sum(tsc1{i,j}.thrDragVecs.Data,2)).^2,1).^.5;

    end 
end


%% Process Test Data
selPath = uigetdir;
listing = dir(selPath);

% selPath2 = uigetdir;
% listing2 = dir(selPath2);

for i = 3:numel(listing)
load(strcat(selPath,'\',listing(i).name));
tscData{i-2} = tsc;
a = find(tsc.El_deg.Data == min(tsc.El_deg.Data),1)
tscData{i-2}.a = a;
% rmsCalc = getsamples(tscData{i-2}.El_deg,[a:length(tscData{i-2}.El_deg.Time)])
% rmsA = find(tscData.El_deg.Data == max(tscData.El_deg.Data))
% rmsB = find
tscData{i-2}.linSpeed = tsc.speedCMD1.Data(a);
end

% for i = 3:numel(listing2)
% load(strcat(selPath,'\',listing(i).name));
% tscData312{i-2} = tsc;
% a = find(tsc.El_deg.Data==min(tsc.El_deg.Data),1);
% tscData312{i-2}.a = a;
% tscData312{i-2}.linSpeed = tsc.speedCMD1.Data(a);
% end

%% March 19 Data
% dataSeg = {[3:5,7:12],[21:29],[30:38]};
dataSeg = {[11:20],[21:29],[30:38]};
% dataSeg2 = {NaN,[;
for j = 1:numel(dataSeg)
figure;
q = 1; qq = 1; qqq = 1;
for i = dataSeg{j}
    if tscData{i}.linSpeed > 1.66 && tscData{i}.linSpeed < 1.68
        subplot(1,3,1); hold on; grid on;
        plot(tscData{i}.calc_elev.Time(tscData{i}.a:end)...
            -tscData{i}.calc_elev.Time(tscData{i}.a),...
            tscData{i}.calc_elev.Data(tscData{i}.a:end),...
            '-','DisplayName',sprintf('Run %d',q));
        q = q+1;
        ylim([0,90])
        xlabel 'Time [s]'
        ylabel 'Elevation Angle [deg]'
        title  '0.65 m/s'
        legend('Location','southeast')
    elseif tscData{i}.linSpeed > 2.16 && tscData{i}.linSpeed < 2.17
        subplot(1,3,2); hold on; grid on;
        plot(tscData{i}.calc_elev.Time(tscData{i}.a:end)...
            -tscData{i}.calc_elev.Time(tscData{i}.a),...
            tscData{i}.calc_elev.Data(tscData{i}.a:end),...
            '-','DisplayName',sprintf('Run %d',qq));
        qq = qq+1;
        ylim([0,90])
        xlabel 'Time [s]'
        ylabel 'Elevation Angle [deg]'
        title  '0.77 m/s'
        legend('Location','southeast')
    elseif tscData{i}.linSpeed > 2.6 && tscData{i}.linSpeed < 2.7
        subplot(1,3,3); hold on; grid on;
        plot(tscData{i}.calc_elev.Time(tscData{i}.a:end)...
            -tscData{i}.calc_elev.Time(tscData{i}.a),...
            tscData{i}.calc_elev.Data(tscData{i}.a:end),...
            '-','DisplayName',sprintf('Run %d',qqq));
        qqq = qqq+1;
        ylim([0,90])
        xlabel 'Time [s]'
        ylabel 'Elevation Angle [deg]'
        title  '0.80 m/s'
        legend('Location','southeast')
    else
    end
end

for i = 1:3
    subplot(1,3,i)
    imEl = squeeze(atan2(tsc1{j,i}.thrNodePosVecs.Data(3,1,:)-...
        tsc1{j,i}.thrNodePosVecs.Data(3,5,:),...
        tsc1{j,i}.thrNodePosVecs.Data(1,1,:)-...
        tsc1{j,i}.thrNodePosVecs.Data(1,5,:)))*180/pi;
    plot(tsc1{j,i}.elevationAngle.Time,imEl...
        ,'b--','DisplayName','Simulation')
%     plot(tsc1{j,i}.elevationAngle.Time,-squeeze(tsc1{j,i}.elevationAngle.Data)...
%         ,'g--','DisplayName','Sim')
end
sgtitle(sprintf('Elevation Response - %d Degree Incidence',8-j*2))
end

figure; hold on; grid on
plot(tscData{11}.calc_azi.Time(tscData{11}.a:end)...
            -tscData{11}.calc_azi.Time(tscData{11}.a),...
            tscData{11}.calc_azi.Data(tscData{11}.a:end),...
            '-','DisplayName','Exp');
plot(tsc1{3,3}.azimuthAngle.Time,  squeeze(mod(tsc1{3,3}.azimuthAngle.Data,360)-180)*-1,'DisplayName','Simulation')
xlabel('Time [x]')
ylabel('Azimuth [deg]')

%%

    vhcl.animateSim(tsc1{1,1},2,'TracerDuration',20,...
        'GifTimeStep',0,'PlotTracer',true,'FontSize',12,'Pause',1==0,...
        'GifFile','meander.gif','timestep',0.1,'View',[90,90]);
    
function [linSpeed] = rpm2speed(rpm)

p1 =    0.008441;  %(-0.01554, 0.03243)
p2 =      0.2241;  %(-1.362, 1.811)

linSpeed = p1*rpm + p2; 
end 

