%% Test script for John to control the kite model
clear;clc;%close all
%%  Select sim scenario
%   0 = fig8;
%   1 = fig8-2rot DOE-M;  1.1 = fig8-2rot AVL;  1.2 = fig8-2rot XFoil;  1.3 = fig8-2rot XFlr5;
%   2 = fig8-winch DOE;
%   3 = steady Old;       3.1 = steady AVL;     3.2 = steady XFoil      3.3 = Steady XFlr5;
%   4 = LaR Old;          4.1 = LaR AVL;        4.2 = LaR XFoil;        4.3 = LaR XFlr5
simScenario = 1.3;
%%  Set Test Parameters
saveSim = 1;                                                %   Flag to save results
thrLength = 400;                                            %   m - Initial tether length
flwSpd = .315;%[0.25 0.315 0.5 1 2];                              %   m/s - Flow speed
el = 30*pi/180;                                             %   rad - Mean elevation angle
h = 10*pi/180;  w = 40*pi/180;                              %   rad - Path width/height
[a,b] = boothParamConversion(w,h);                          %   Path basis parameters
for ii = 1:numel(flwSpd)
    Simulink.sdi.clear
    %%  Load components
    if simScenario >= 4
        loadComponent('LaRController');                         %   Launch and recovery controller
    elseif simScenario >= 3 && simScenario < 4
        loadComponent('SteadyController');                      %   Steady-flight controller
    elseif simScenario == 2
        loadComponent('pathFollowingCtrlForILC');               %   Path-following controller with spooling
    else
        loadComponent('pathFollowingCtrlForManta');             %   Path-following controller
    end
    loadComponent('oneDoFGSCtrlBasic');                         %   Ground station controller
    loadComponent('MantaGndStn');                               %   Ground station
    loadComponent('winchManta');                                %   Winches
    if simScenario >= 4
        loadComponent('shortTether');                           %   Tether for reeling
        thr.tether1.setInitTetherLength(thrLength,'m');
    else
        loadComponent('MantaTether');                           %   Single link tether
    end
    loadComponent('idealSensors')                               %   Sensors
    loadComponent('idealSensorProcessing')                      %   Sensor processing
    if simScenario == 0
        loadComponent('MantaKiteAVL_DOE');                                  %   Manta kite old
    elseif simScenario == 2
        loadComponent('fullScale1thr');                                     %   DOE kite
    elseif simScenario == 1 || simScenario == 3 || simScenario == 4
        loadComponent('Manta2RotAVL_DOE');                                  %   Manta DOE kite with AVL
    elseif simScenario == 1.1 || simScenario == 3.1 || simScenario == 4.1
        loadComponent('Manta2RotAVL_Thr075');                               %   Manta kite with AVL
    elseif simScenario == 1.2 || simScenario == 3.2 || simScenario == 4.2
        loadComponent('Manta2RotXFoil_Thr075');                             %   Manta kite with XFoil
    elseif simScenario == 1.3 || simScenario == 3.3 || simScenario == 4.3
        loadComponent('Manta2RotXFlr_Thr075');                              %   Manta kite with XFlr5
        %         loadComponent('Manta2RotXFlr_Thr075_125Inc');                               %   Manta kite with AVL
    end
    %%  Environment Properties
    loadComponent('ConstXYZT');                                 %   Environment
    env.water.setflowVec([flwSpd(ii) 0 0],'m/s');               %   m/s - Flow speed vector
    if simScenario == 0
        ENVIRONMENT = 'environmentManta';                       %   Single turbine
    elseif simScenario == 2
        ENVIRONMENT = 'environmentDOE';                         %   No turbines
    else
        ENVIRONMENT = 'environmentManta2Rot';                   %   Two turbines
    end
    %%  Set basis parameters for high level controller
    loadComponent('constBoothLem');                             %   High level controller
    hiLvlCtrl.basisParams.setValue([a,b,el,0*pi/180,thrLength],'[rad rad rad rad m]') % Lemniscate of Booth
    %%  Ground Station Properties
    %%  Vehicle Properties
    vhcl.setICsOnPath(.05,PATHGEOMETRY,hiLvlCtrl.basisParams.Value,gndStn.posVec.Value,6.5*flwSpd*norm([1;0;0]))
    if simScenario >= 3
        vhcl.setICsOnPath(0,PATHGEOMETRY,hiLvlCtrl.basisParams.Value,gndStn.posVec.Value,0)
        vhcl.setInitEulAng([0,0,0]*pi/180,'rad')
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
    wnch.winch1.LaRspeed.setValue(1,'m/s');
    %%  Controller User Def. Parameters and dependant properties
    fltCtrl.setFcnName(PATHGEOMETRY,'');
    fltCtrl.setInitPathVar(vhcl.initPosVecGnd.Value,hiLvlCtrl.basisParams.Value,gndStn.posVec.Value);
    fltCtrl.rudderGain.setValue(0,'')
    if simScenario == 1.1
        fltCtrl.setElevatorReelInDef(-2,'deg')
    end
    if simScenario >= 4
        fltCtrl.LaRelevationSP.setValue(35,'deg');          fltCtrl.setNomSpoolSpeed(.25,'m/s');
    end
    if simScenario >= 3 && simScenario < 4
        %         fltCtrl.elevCmd.kp.setValue(0,'(deg)/(rad)');       fltCtrl.elevCmd.ki.setValue(0,'(deg)/(rad*s)');
        fltCtrl.pitchCtrl.setValue(0,'');                   fltCtrl.pitchConst.setValue(15,'deg');
        fltCtrl.pitchTime.setValue(0:250:3000,'s');         fltCtrl.pitchLookup.setValue(0:12,'deg');
    end
    thr.tether1.dragEnable.setValue(1,'');
    %%  Set up critical system parameters and run simulation
    fprintf('Diameter = %.2f m;\t Elevator = %.3f deg\n',D(ii),E(jj));
    simParams = SIM.simParams;  simParams.setDuration(2000,'s');  dynamicCalc = '';
    simWithMonitor('OCTModel')
    %%  Log Results
    tsc = signalcontainer(logsout);
    if simScenario ~= 2 && simScenario < 3
        %             Pow = tsc.rotPowerSummary(vhcl,env);
    end
    dt = datestr(now,'mm-dd_HH-MM');
    if simScenario == 0
        filename = sprintf(strcat('Manta_EL-%.1f_w-%.1f_h-%.1f_',dt,'.mat'),el*180/pi,w*180/pi,h*180/pi);
        fpath = fullfile(fileparts(which('OCTProject.prj')),'Results','Manta\');
    elseif simScenario > 0 && simScenario < 2
        if numel(flwSpd) == 1
            %                 filename = sprintf(strcat('Turb%.1f_V-%.3f_EL-%.1f_D-%.2f_w-%.1f_h-%.1f_',dt,'.mat'),simScenario,flwSpd(ii),el*180/pi,vhcl.turb1.diameter.Value,w*180/pi,h*180/pi);
            filename = sprintf(strcat('Turb%.1f_V-%.3f_EL-%.1f_D-%.2f_I-%.2f_',dt,'.mat'),simScenario,flwSpd(ii),el*180/pi,vhcl.turb1.diameter.Value,vhcl.hStab.incidence.Value);
            fpath = fullfile(fileparts(which('OCTProject.prj')),'Results','Manta 2.0','Rotor\');
        else
            filename = sprintf(strcat('Turb%.1f_V-%.3f.mat'),simScenario,flwSpd(ii));
            fpath = fullfile(fileparts(which('OCTProject.prj')),'Results','Manta 2.0','Rotor','D\');
        end
    elseif simScenario == 2
        filename = sprintf(strcat('Winch_EL-%.1f_Thr-%d_w-%.1f_h-%.1f_',dt,'.mat'),el*180/pi,thrLength,w*180/pi,h*180/pi);
        fpath = fullfile(fileparts(which('OCTProject.prj')),'Results','Manta 2.0','Winch\');
    elseif simScenario >= 3 && simScenario < 4
        if vhcl.Ma6x6_LE.Value(1,1) ~= 0; AM = 1; else; AM = 0; end
        filename = sprintf(strcat('Steady%.1f_EL-%.1f_kp-%.2f_ki-%.2f_',dt,'.mat'),simScenario,el*180/pi,fltCtrl.elevCmd.kp.Value,fltCtrl.elevCmd.ki.Value);
        fpath = fullfile(fileparts(which('OCTProject.prj')),'Results','Manta 2.0','Steady\');
    elseif simScenario >= 4
        filename = sprintf(strcat('LaR%.1f_EL-%.1f_SP-%.1f_t-%.1f_Wnch-%.1f_',dt,'.mat'),simScenario,el*180/pi,fltCtrl.LaRelevationSP.Value,simParams.duration.Value,fltCtrl.nomSpoolSpeed.Value);
        fpath = fullfile(fileparts(which('OCTProject.prj')),'Results','Manta 2.0','LaR\');
    end
    if saveSim == 1
        save(strcat(fpath,filename),'tsc','vhcl','thr','fltCtrl','env','simParams','LIBRARY','gndStn')
    end
end
%%  Plot Results
if simScenario < 3
    lap = max(tsc.lapNumS.Data)-1;
    tsc.plotFlightResults(vhcl,env,'plot1Lap',1==1,'plotS',1==1,'lapNum',lap,'dragChar',1==1)
else
    tsc.plotLaR(fltCtrl,'Steady',simScenario >= 3 && simScenario < 4);
end
%%  Animate Simulation
% if simScenario <= 2
%     vhcl.animateSim(tsc,2,'PathFunc',fltCtrl.fcnName.Value,...
%         'GifTimeStep',.01,'PlotTracer',true,'FontSize',12,'Pause',1==0,...
%         'ZoomIn',1==0,'SaveGif',1==0,'GifFile',strrep(filename,'.mat','.gif'));
% else
%     vhcl.animateSim(tsc,2,'View',[0,0],'Pause',1==1,...
%         'GifTimeStep',.05,'PlotTracer',true,'FontSize',12,'ZoomIn',1==1,...
%         'SaveGif',1==0,'GifFile',strrep(filename,'.mat','zoom.gif'));
% end
%%  Compare to old results
% tsc.turbEnrg.Data(1,1,end)
% load('C:\Users\John Jr\Desktop\Manta Ray\Model\Results\Manta\Rotor\Turb2_V-0.25_EL-30.0_D-0.56_w-40.0_h-15.0_08-04_10-56.mat')
% tsc.turbEnrg.Data(1,1,end)

% powCurveAnalysis
