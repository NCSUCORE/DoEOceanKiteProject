%% Test script for John to control the kite model
clear; clc; close all;
Simulink.sdi.clear
%% Simulation Setup
% 1 - Vehicle Model:         1 = AR8b8, 2 = AR9b9, 3 = AR9b10
% 2 - High-level Controller: 1 = const basis, 2 = const basis/state flow
% 3 - Flight controller:     1 = pathFlow, 2 = full cycle
% 4 - Tether Model:          1 = Single link, 2 = Reel-in, 3 = Multi-node, 4 = Multi-node faired
% 5 - Environment:           1 = const flow, 2 = variable flow
% 6 - Save Results
% 7 - Animate
% 8 - Plotting
%%             1 2 3 4 5 6     7     8
simScenario = [1 1 1 4 1 false true 1==0];
%%  Set Test Parameters
tFinal = 5000;      tSwitch = 10000;                        %   s - maximum sim duration 
flwSpd = 0.25;                                              %   m/s - Flow speed
altitude = 150;     initAltitude = 100;                     %   m/m - cross-current and initial altitude 
thrLength = 600;    initThrLength = 200;                    %   m/m - cross-current and initial tether length 
thrDiam = 18;       fairing = 100;                          %   mm/m - tether diameter and fairing length
h = 2.5*pi/180;      w = 10*pi/180;                          %   rad - Path width/height
sC = 0;             subCtrl = 3;                            %   State mac on/off and selected flight controller 
el = asin(altitude/thrLength);                              %   rad - Initial elevation angle
[a,b] = boothParamConversion(w,h);                          %   Path basis parameters
if el*180/pi < 10 || el*180/pi > 45
    error('Elevation angle is out of range\n');
end
%%  Load components
% load(['D:\Power Study\' sprintf('CDR_V-%.3f_alt-%d_thrL-%d_thrD-%.1f_Fair-%d.mat',flwSpd,altitude,thrLength,thrDiam,fairing)])
% load('C:\Users\JohnJr\Desktop\Manta Ray\DoEOceanKiteProject\output\Turb_V-0.45_Alt-150_thr-300_Tmax-1.740814e+01.mat')
% load('C:\Users\jbore\Documents\DoEOceanKiteProject\output\Turb_V-0.45_Alt-150_thr-300_Tmax-17.4.mat')
% [Idx1,Idx2] = tsc.getLapIdxs(3);  ran = Idx1:Idx2;
% pathVec = squeeze(tsc.currentPathVar.Data(ran));
% timeVec = tsc.eulerAngles.Time(ran)-tsc.eulerAngles.Time(Idx1);
% for i = 2:length(pathVec)
%     if pathVec(i) <= pathVec(i-1)
%         pathVec(i) = pathVec(i-1)+1e-7;
%     end
% end
% rollVec = squeeze(tsc.eulerAngles.Data(1,1,ran));
% yawVec = squeeze(tsc.eulerAngles.Data(3,1,ran));
switch simScenario(1)                                   %   Vehicle
    case 1
        loadComponent('Manta2RotXFoil_AR8_b8');             %   AR = 8; 8m span
    case 2
        loadComponent('Manta2RotXFoil_AR9_b9');             %   AR = 9; 9m span
    case 3
        loadComponent('Manta2RotXFoil_AR9_b10');            %   AR = 9; 10m span
end
switch simScenario(2)                                   %   Flight Controller
    case 1
        loadComponent('constBoothLem');                     %   Constant basis parameters
        hiLvlCtrl.basisParams.setValue([a,b,el,0*pi/180,... %   Initialize basis parameters
            thrLength],'[rad rad rad rad m]');
    case 2
        loadComponent('varAltitudeBooth');                  %   Variable altitude controller
        hiLvlCtrl.basisParams.setValue([a,b,el,0*pi/180,... %   Initialize basis parameters
            thrLength],'[rad rad rad rad m]');
        hiLvlCtrl.ELctrl.setValue(1,'');
        hiLvlCtrl.ELslew.setValue(0.25,'deg/s');
        hiLvlCtrl.ThrCtrl.setValue(1,'');
    case 3
        loadComponent('mantaFSHiLvl');                     %   Constant basis parameters
        hiLvlCtrl.stateCtrl.setValue(sC,'');
        hiLvlCtrl.stateConst.setValue(subCtrl,'');
        hiLvlCtrl.preXelevation.setValue(max(el-h,5*pi/180),'rad')
        hiLvlCtrl.initXelevation.setValue(max(el-h/2,5*pi/180),'rad')
        initEL = asin(initAltitude/initThrLength);                      %   rad - Initial elevation angle
        if sC == 0 && subCtrl == 3
            hiLvlCtrl.basisParams.setValue([a,b,el,0*pi/180,... %   Initialize basis parameters
                thrLength],'[rad rad rad rad m]');
        else
            hiLvlCtrl.basisParams.setValue([a,b,initEL,0*pi/180,... %   Initialize basis parameters
                initThrLength],'[rad rad rad rad m]');
        end
        hiLvlCtrl.harvestingAltitude.setValue(altitude,'m');
        hiLvlCtrl.harvestingThrLength.setValue(thrLength,'m');
end
switch simScenario(3)                                   %   Flight Controller
    case 1
        loadComponent('pathFollowWithAoACtrl');             %   Path-following controller with AoA control
    case 2
        loadComponent('pathFollowWithAoACtrl');             %   Path-following controller with AoA control
        pthCtrl1 = fltCtrl;
        loadComponent('LaRController');                     %   Launch and recovery controller
        slfCtrl = fltCtrl;
        loadComponent('MantaFSController');                 %   Path-following controller with AoA control
    case 3
%         load('C:\Users\andre\Documents\OCT\DoEOceanKiteProject\compositions\flightController\launchRecoveryController\library\SteadyController\SteadyController.mat')
        load('SteadyController.mat')
        fltCtrl.rollMoment.kp.setValue(1000,'(N*m)/(rad)')
        fltCtrl.rollMoment.ki.setValue(0,'(N*m)/(rad*s)');
        fltCtrl.rollMoment.kd.setValue(1000,'(N*m)/(rad/s)');
        fltCtrl.rollMoment.tau.setValue(0.001,'s');
        fltCtrl.yawMoment.kp.setValue(0,'(N*m)/(rad)');
        fltCtrl.rudderGain.setValue(-1,'')
        fltCtrl.LaRelevationSP.setValue(20,'deg');
        fltCtrl.pitchCtrl.setValue(2,'');
    case 4
        loadComponent('LaRController');                     %   Launch and recovery controller
end
switch simScenario(4)                                   %   Tether model
    case 1
        loadComponent('MantaTether');                       %   Manta Ray tether
    case 2
        loadComponent('shortTether');                       %   Tether for reeling
        thr.tether1.setInitTetherLength(initThrLength,'m');     %   Initialize tether length
    case 3
        loadComponent('MantaTetherReal');                       %   Manta Ray tether
    case 4
        loadComponent('fairedNNodeTether');                       %   Manta Ray tether
        thr.tether1.diameter.setValue(thrDiam*10^-3,'m')
        thr.numNodes.setValue(9,'');
        thr.tether1.numNodes.setValue(9,'');
        thr.tether1.fairedLinks.setValue(2,'');
end
switch simScenario(5)                                   %   Environment
    case 1
        loadComponent('ConstXYZT');                         %   Constant flow
        ENVIRONMENT = 'env2turb';                           %   Two turbines
        env.water.setflowVec([flwSpd 0 0],'m/s');           %   m/s - Flow speed vector
    case 2
        loadComponent('ConstYZTvarX');                      %   Variable X
        ENVIRONMENT = 'env2turb';                           %   Two turbines
        env.water.setflowVec([flwSpd 0 0],'m/s');           %   m/s - Flow speed vector
end
loadComponent('oneDoFGSCtrlBasic');                         %   Ground station controller
loadComponent('MantaGndStn');                               %   Ground station
loadComponent('winchManta');                                %   Winches
loadComponent('idealSensors')                               %   Sensors
loadComponent('idealSensorProcessing')                      %   Sensor processing
%%  Vehicle Initial Conditions
if simScenario(3) == 1
    vhcl.setICsOnPath(0.05,PATHGEOMETRY,hiLvlCtrl.basisParams.Value,gndStn.posVec.Value,4*flwSpd)
else
    vhcl.setICsOnPath(0,PATHGEOMETRY,hiLvlCtrl.basisParams.Value,gndStn.posVec.Value,0)
    vhcl.setInitEulAng([0,0,0]*pi/180,'rad')
end
vhcl.hStab.CL.setValue(vhcl.hStab.alpha.Value*0.02156+.04334,'')
%%  Tethers Properties
Tmax = getMaxTension(thrDiam);                              %   kN - candidate tether tension limits
thr.tether1.initGndNodePos.setValue(gndStn.thrAttch1.posVec.Value(:)+gndStn.posVec.Value(:),'m');
thr.tether1.initAirNodePos.setValue(vhcl.initPosVecGnd.Value(:)...
    +rotation_sequence(vhcl.initEulAng.Value)*vhcl.thrAttchPts_B.posVec.Value,'m');
thr.tether1.initGndNodeVel.setValue([0 0 0]','m/s');
thr.tether1.initAirNodeVel.setValue(rotation_sequence(vhcl.initEulAng.Value)*vhcl.initVelVecBdy.Value(:),'m/s');
thr.tether1.vehicleMass.setValue(vhcl.mass.Value,'kg');
if simScenario(4) == 4
    thr.tether1.fairedLength.setValue(fairing,'m');
end
thr.tether1.diameter.setValue(thrDiam*10^-3,'m')
%%  Winches Properties
wnch.setTetherInitLength(vhcl,gndStn.posVec.Value,env,thr,env.water.flowVec.Value);
wnch.winch1.LaRspeed.setValue(1,'m/s');
%%  Controller User Def. Parameters and dependant properties
% FLIGHTCONTROLLER = 'pathFollowingCtrlAoATurbFault'
switch simScenario(3)
    case 1
        fltCtrl.setFcnName(PATHGEOMETRY,'');
        fltCtrl.setInitPathVar(vhcl.initPosVecGnd.Value,hiLvlCtrl.basisParams.Value,gndStn.posVec.Value);
        fltCtrl.AoASP.setValue(1,'');                           
        fltCtrl.AoACtrl.setValue(1,'');
        fltCtrl.Tmax.setValue(Tmax,'kN');
        
        fltCtrl.elevatorConst.setValue(-4,'deg');
        
        fltCtrl.rollCtrl.kp.setValue(100,'(deg)/(rad)');
        fltCtrl.rollCtrl.ki.setValue(0,'(deg)/(rad*s)');
        fltCtrl.rollCtrl.kd.setValue(1,'(deg)/(rad/s)');
        fltCtrl.rollCtrl.tau.setValue(0.01,'s');
        
        fltCtrl.yawCtrl.kp.setValue(50,'(deg)/(rad)');
        fltCtrl.yawCtrl.ki.setValue(0,'(deg)/(rad*s)');
        fltCtrl.yawCtrl.kd.setValue(0,'(deg)/(rad/s)');
        fltCtrl.yawCtrl.tau.setValue(0.001,'s');
        lapN = 40;
    case 2
        fltCtrl.maxTL.setValue(hiLvlCtrl.maxThrLength.Value,'m');
        pthCtrl1.setFcnName(PATHGEOMETRY,'');
        pthCtrl1.setInitPathVar(vhcl.initPosVecGnd.Value,hiLvlCtrl.basisParams.Value,gndStn.posVec.Value);
        pthCtrl1.AoASP.setValue(0,'');                           pthCtrl1.AoAConst.setValue(vhcl.optAlpha.Value*pi/180,'deg');
        pthCtrl1.AoACtrl.setValue(1,'');                         pthCtrl1.Tmax.setValue(Tmax-.5,'kN');
        pthCtrl1.alphaCtrl.kp.setValue(.2,'(rad)/(kN)');         pthCtrl1.alphaCtrl.ki.setValue(.08,'(rad)/(kN*s)');
        pthCtrl1.elevCtrl.kp.setValue(125,'(deg)/(rad)');        pthCtrl1.elevCtrl.ki.setValue(1,'(deg)/(rad*s)');
        pthCtrl1.rollCtrl.kp.setValue(200,'(deg)/(rad)');        pthCtrl1.rollCtrl.ki.setValue(0,'(deg)/(rad*s)');
        pthCtrl1.rollCtrl.kd.setValue(150,'(deg)/(rad/s)');      pthCtrl1.rollCtrl.tau.setValue(0.001,'s');
        pthCtrl2.setFcnName(PATHGEOMETRY,'');
        pthCtrl2.setInitPathVar(vhcl.initPosVecGnd.Value,hiLvlCtrl.basisParams.Value,gndStn.posVec.Value);
        pthCtrl2.AoASP.setValue(1,'');                           pthCtrl2.AoAConst.setValue(vhcl.optAlpha.Value*pi/180,'deg');
        pthCtrl2.AoACtrl.setValue(1,'');                         pthCtrl2.Tmax.setValue(Tmax-.5,'kN');
        pthCtrl2.alphaCtrl.kp.setValue(.2,'(rad)/(kN)');         pthCtrl2.alphaCtrl.ki.setValue(.08,'(rad)/(kN*s)');
        pthCtrl2.elevCtrl.kp.setValue(125,'(deg)/(rad)');        pthCtrl2.elevCtrl.ki.setValue(1,'(deg)/(rad*s)');
        pthCtrl2.rollCtrl.kp.setValue(200,'(deg)/(rad)');        pthCtrl2.rollCtrl.ki.setValue(0,'(deg)/(rad*s)');
        pthCtrl2.rollCtrl.kd.setValue(150,'(deg)/(rad/s)');      pthCtrl2.rollCtrl.tau.setValue(0.001,'s');
        slfCtrl.LaRelevationSP.setValue(el*180/pi,'deg');        slfCtrl.pitchCtrl.setValue(2,''); slfCtrl.pitchConst.setValue(0,'deg');
        slfCtrl.pitchAngleMax.upperLimit.setValue(20,'');        slfCtrl.pitchAngleMax.lowerLimit.setValue(-20,'')
        slfCtrl.winchActive.setValue(0,'');                      slfCtrl.minThrTension.setValue(50,'N');
end
vhcl.setBuoyFactor(getBuoyancyFactor(vhcl,env,thr),'');
%%  Set up critical system parameters and run simulation
simParams = SIM.simParams;  simParams.setDuration(tFinal,'s');  dynamicCalc = '';
simWithMonitor('OCTModel')
%%  Log Results
tsc = signalcontainer(logsout);
if simScenario(3) == 1
    Pow = tsc.rotPowerSummary(vhcl,env,thr);
    [Idx1,Idx2] = tsc.getLapIdxs(max(tsc.lapNumS.Data)-1);  ran = Idx1:Idx2;
    AoA = mean(squeeze(tsc.vhclAngleOfAttack.Data(:,:,ran)));
    airNode = squeeze(sqrt(sum(tsc.airTenVecs.Data.^2,1)))*1e-3;
    gndNode = squeeze(sqrt(sum(tsc.gndNodeTenVecs.Data.^2,1)))*1e-3;
    ten = max([max(airNode(ran)) max(gndNode(ran))]);
    fprintf('Average AoA = %.3f;\t Max Tension = %.1f kN\n\n',AoA,ten);
end
switch simScenario(3)
    case 1
        filename = sprintf(strcat('Turb_V-%.2f_Alt-%d_thr-%d_Tmax-%.1f.mat'),flwSpd,altitude,thrLength,Tmax);
    case 2
        filename = sprintf(strcat('FS_V-%.3f_Alt-%d_thr-%d_Tmax-%d_FL-%d.mat'),flwSpd,altitude,thrLength,Tmax,thr.fairingLength.Value);
end
if simScenario(6)
    fpath = fullfile(fileparts(which('OCTProject.prj')),'output\');
    save(strcat(fpath,filename),'tsc','vhcl','thr','fltCtrl','env','simParams','LIBRARY','gndStn')
end
%%  Plot Results
if simScenario(8)
    switch simScenario(3)
        case 1
            lap = max(tsc.lapNumS.Data)-1;
            if max(tsc.lapNumS.Data) < 2
                tsc.plotFlightResults(vhcl,env,thr,'plot1Lap',1==0,'plotS',1==0,'lapNum',lap,'dragChar',1==0,'cross',1==0)
            else
                tsc.plotFlightResults(vhcl,env,thr,'plot1Lap',1==1,'plotS',1==1,'lapNum',lap,'dragChar',1==0,'cross',1==0)
            end
        case 2
            tsc.plotFSslf(fltCtrl,'Steady',true);
        case 3
            tsc.plotLaR(fltCtrl,'Steady',true);
        case 4
            tsc.plotLaR(fltCtrl,'Steady',true);
    end
end
lap = max(tsc.lapNumS.Data)-1;
tsc.plotFlightResults(vhcl,env,thr,'plot1Lap',1==0,'plotS',1==0,'lapNum',lap,'dragChar',1==0,'cross',1==0)
%%
for i = 1:numel(tsc.FNetBdy.Time)
momAdd = cross(vhcl.rBridle_LE.Value,squeeze(tsc.FNetBdy.Data(:,:,i)));
momNet(:,i) = squeeze(tsc.MNetBdy.Data(:,:,i))+momAdd;
end

figure
plot(tsc.FNetBdy.Time,momNet(3,:))
xlim([100 inf])
xlabel 'Time [s]'
ylabel 'Net Moment at Tether Attachment [N-m]'
% figure; ax1=subplot(3,1,1); hold on; grid on;
% plot(tsc.rollSP.Time,tsc.rollSP.Data*180/pi,'r-')
% plot(tsc.eulerAngles.Time,squeeze(tsc.eulerAngles.Data(1,1,:))*180/pi,'b-')
% xlabel('Time [s]'); ylabel('Angle [deg]'); legend('Roll SP','Roll');
% ax2=subplot(3,1,3); hold on; grid on;
% plot(tsc.yawSP.Time,tsc.yawSP.Data*180/pi,'r-')
% plot(tsc.eulerAngles.Time,squeeze(tsc.eulerAngles.Data(3,1,:))*180/pi,'b-')
% xlabel('Time [s]'); ylabel('Angle [deg]'); legend('Yaw SP','Yaw');
% ax3=subplot(3,1,2); hold on; grid on;
% plot(tsc.ctrlSurfDefl.Time,squeeze(tsc.ctrlSurfDefl.Data(:,1)),'b-');  xlabel('Time [s]');  ylabel('Deflection [deg]');  
% plot(tsc.ctrlSurfDefl.Time,squeeze(tsc.ctrlSurfDefl.Data(:,3)),'r-');  xlabel('Time [s]');  ylabel('Deflection [deg]');
% plot(tsc.ctrlSurfDefl.Time,squeeze(tsc.ctrlSurfDefl.Data(:,4)),'g-');  xlabel('Time [s]');  ylabel('Deflection [deg]'); 
% legend('P-Aileron','Elevator','Rudder')
% linkaxes([ax1 ax2 ax3],'x'); %xlim([1100 1300])
%%  Animate Simulation
if simScenario(7)
    if simScenario(3) == 1
        vhcl.animateSim(tsc,5,'PathFunc',fltCtrl.fcnName.Value,'TracerDuration',20,...
            'GifTimeStep',.001,'PlotTracer',true,'FontSize',12,'Pause',1==0,'endTime',1000,...
            'ZoomIn',1==0,'SaveGif',1==1);
    elseif simScenario(3) == 2
        vhcl.animateSim(tsc,2,'PathFunc',pthCtrl2.fcnName.Value,'TracerDuration',20,...
            'GifTimeStep',.01,'PlotTracer',true,'FontSize',12,'Pause',1==0,...
            'ZoomIn',1==0,'SaveGif',1==0,'GifFile',strrep(filename,'.mat','.gif'));
    else
        vhcl.animateSim(tsc,2,'View',[0,0],'Pause',1==0,...
            'GifTimeStep',.05,'PlotTracer',true,'FontSize',12,'ZoomIn',1==0,...
            'SaveGif',1==0,'GifFile',strrep(filename,'.mat','zoom.gif'));
    end
end
%%
figure
subplot(3,1,1)
hold on
plotsq(tsc.eulerAngles.Time,tsc.eulerAngles.Data(1,:,:)*180/pi,'b','DisplayName','Roll')
plotsq(tsc.eulerAngles.Time,tsc.rollSP.Data*180/pi,'r','DisplayName','Roll SP')
plot([1000 1000],[-100 100],'k--','DisplayName','Failure Point','Linewidth',1.5)
ylabel 'Angle [deg]'; grid on; set(gca,'FontSize',12)
legend('Location','west')

subplot(3,1,2)
hold on
plotsq(tsc.ctrlSurfDefl.Time, tsc.ctrlSurfDefl.Data(:,1),'b','DisplayName','Aileron')
plotsq(tsc.ctrlSurfDefl.Time, tsc.ctrlSurfDefl.Data(:,3),'r','DisplayName','Elevator')
plotsq(tsc.ctrlSurfDefl.Time, tsc.ctrlSurfDefl.Data(:,4),'g','DisplayName','Rudder')
plot([1000 1000],[-20 20],'k--','DisplayName','Failure Point','Linewidth',1.5)
ylabel 'Angle [deg]'; set(gca,'FontSize',12); legend('Location','west')
subplot(3,1,3)
hold on
plotsq(tsc.eulerAngles.Time,tsc.eulerAngles.Data(3,:,:)*180/pi,'b','DisplayName','Yaw')
plotsq(tsc.eulerAngles.Time,tsc.yawSP.Data*180/pi,'r','DisplayName','Yaw SP')
plot([1000 1000],[-100 100],'k--','DisplayName','Failure Point','Linewidth',1.5)
ylabel 'Angle [deg]'; grid on; xlabel 'Time [s]'; set(gca,'FontSize',15)
set(gca,'FontSize',12); legend('Location','west')