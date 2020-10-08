%% Test script for John to control the kite model
clear;%clc;%close all
%%  Select sim scenario
%   0 = fig8;
%   1 = fig8-2rot DOE-M;  1.1 = fig8-2rot AVL;  1.2 = fig8-2rot XFoil;  1.3 = fig8-2rot XFlr5;
%   2 = fig8-winch DOE;
%   3 = steady Old;       3.1 = steady AVL;     3.2 = steady XFoil      3.3 = Steady XFlr5;
%   4 = LaR Old;          4.1 = LaR AVL;        4.2 = LaR XFoil;        4.3 = LaR XFlr5
simScenario = 1.5;
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
        loadComponent('pathFollowWithAoACtrl');                 %   Path-following controller with AoA control
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
    elseif simScenario == 1.4 || simScenario == 3.4 || simScenario == 4.4
        loadComponent('Manta2RotXFlr_CFD');                                 %   Manta kite with XFlr5
    elseif simScenario == 1.5 || simScenario == 3.5 || simScenario == 4.5
        loadComponent('Manta2RotXFoil_AR8_b8');                                 %   Manta kite with XFlr5
    elseif simScenario == 1.6 || simScenario == 3.6 || simScenario == 4.6
        loadComponent('Manta2RotXFoil_AR9_b8');                                 %   Manta kite with XFlr5
    elseif simScenario == 1.7 || simScenario == 3.7 || simScenario == 4.7
        loadComponent('Manta2RotXFoil_AR9_b9');                                 %   Manta kite with XFlr5
    elseif simScenario == 1.8 || simScenario == 3.8 || simScenario == 4.8
        loadComponent('Manta2RotXFoil_AR9_b10');                                %   Manta kite with XFlr5
    elseif simScenario == 1.9 || simScenario == 3.9 || simScenario == 4.9
        loadComponent('Manta2RotXFoil_AR7_b8');                                 %   Manta kite with XFlr5
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
    thr.tether1.setDiameter(0.00874,thr.tether1.diameter.Unit);
    thr.tether1.setYoungsMod(thr.tether1.youngsMod.Value*1,thr.tether1.youngsMod.Unit);
    thr.tether1.dragCoeff.setValue(1,'');
    %%  Winches Properties
    wnch.setTetherInitLength(vhcl,gndStn.posVec.Value,env,thr,env.water.flowVec.Value);
    wnch.winch1.LaRspeed.setValue(1,'m/s');
    %%  Controller User Def. Parameters and dependant properties
    fltCtrl.setFcnName(PATHGEOMETRY,'');
    fltCtrl.setInitPathVar(vhcl.initPosVecGnd.Value,hiLvlCtrl.basisParams.Value,gndStn.posVec.Value);
    fltCtrl.rudderGain.setValue(0,'')
    if simScenario == 1.5
%         fltCtrl.setElevatorReelInDef(-.25,'deg')
    end
    if simScenario >= 4
        fltCtrl.LaRelevationSP.setValue(35,'deg');          fltCtrl.setNomSpoolSpeed(.25,'m/s');
    end
    if simScenario >= 3 && simScenario < 4
%         fltCtrl.elevCmd.kp.setValue(0,'(deg)/(rad)');       fltCtrl.elevCmd.ki.setValue(0,'(deg)/(rad*s)');
        fltCtrl.pitchCtrl.setValue(0,'');                   fltCtrl.pitchConst.setValue(-10,'deg');
        fltCtrl.pitchTime.setValue(0:500:2000,'s');         fltCtrl.pitchLookup.setValue(-10:5:10,'deg');
    elseif simScenario >= 1 && simScenario < 2
        fltCtrl.AoACtrl.setValue(1,'');                     fltCtrl.AoASP.setValue(0,'');
        fltCtrl.AoAConst.setValue(14*pi/180,'deg');
        fltCtrl.AoATime.setValue([0 1000 2000],'s');        fltCtrl.AoALookup.setValue([14 2 14]*pi/180,'deg');
        fltCtrl.elevCtrl.kp.setValue(200,'(deg)/(rad)');    fltCtrl.elevCtrl.ki.setValue(1,'(deg)/(rad*s)');
    end
    thr.tether1.dragEnable.setValue(1,'');
%     vhcl.turb1.setDiameter(.675,'m');     vhcl.turb2.setDiameter(.675,'m')
    %%  Set up critical system parameters and run simulation
    simParams = SIM.simParams;  simParams.setDuration(2000,'s');  dynamicCalc = '';
    simWithMonitor('OCTModel')
    %%  Log Results
    tsc = signalcontainer(logsout);
    if simScenario ~= 2 && simScenario < 3
        Pow = tsc.rotPowerSummary(vhcl,env);
        [Idx1,Idx2] = tsc.getLapIdxs(max(tsc.lapNumS.Data)-1);  ran = Idx1:Idx2;
        AoA = mean(squeeze(tsc.vhclAngleOfAttack.Data(:,:,ran)));
        fprintf('Average AoA = %.3f \n',AoA);
    end
    dt = datestr(now,'mm-dd_HH-MM');
    if simScenario == 0
        filename = sprintf(strcat('Manta_EL-%.1f_w-%.1f_h-%.1f_',dt,'.mat'),el*180/pi,w*180/pi,h*180/pi);
        fpath = fullfile(fileparts(which('OCTProject.prj')),'Results','Manta\');
    elseif simScenario > 0 && simScenario < 2
        if numel(flwSpd) == 1
            if fltCtrl.AoACtrl.Value == 1
                filename = sprintf(strcat('Turb%.1fa_V-%.3f_EL-%.1f_D-%.2f_E-%.2f_',dt,'.mat'),simScenario,flwSpd(ii),el*180/pi,vhcl.turb1.diameter.Value,fltCtrl.elevatorReelInDef.Value);
            else
                filename = sprintf(strcat('Turb%.1f_V-%.3f_EL-%.1f_D-%.2f_E-%.2f_',dt,'.mat'),simScenario,flwSpd(ii),el*180/pi,vhcl.turb1.diameter.Value,fltCtrl.elevatorReelInDef.Value);
            end
            fpath = fullfile(fileparts(which('OCTProject.prj')),'Results','Manta 2.0','Rotor\');
        else
            filename = sprintf(strcat('Turb%.1f_V-%.3f.mat'),simScenario,flwSpd(ii));
            fpath = fullfile(fileparts(which('OCTProject.prj')),'Results','Manta 2.0','Rotor','D\');
        end
    elseif simScenario == 2
        filename = sprintf(strcat('Winch_EL-%.1f_Thr-%d_w-%.1f_h-%.1f_',dt,'.mat'),el*180/pi,thrLength,w*180/pi,h*180/pi);
        fpath = fullfile(fileparts(which('OCTProject.prj')),'Results','Manta 2.0','Winch\');
    elseif simScenario >= 3 && simScenario < 4
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
    if max(tsc.lapNumS.Data) < 2
        tsc.plotFlightResults(vhcl,env,'plot1Lap',1==0,'plotS',1==1,'lapNum',lap,'dragChar',1==0)
    else
        tsc.plotFlightResults(vhcl,env,'plot1Lap',1==1,'plotS',1==1,'lapNum',lap,'dragChar',1==0)
    end
else
    tsc.plotLaR(fltCtrl,'Steady',simScenario >= 3 && simScenario < 4);
end
%%  Animate Simulation
% if simScenario <= 2
%     vhcl.animateSim(tsc,2,'PathFunc',fltCtrl.fcnName.Value,...
%         'GifTimeStep',.01,'PlotTracer',true,'FontSize',12,'Pause',1==0,...
%         'ZoomIn',1==0,'SaveGif',1==0,'GifFile',strrep(filename,'.mat','.gif'));
% else
%     vhcl.animateSim(tsc,2,'View',[0,0],'Pause',1==0,...
%         'GifTimeStep',.05,'PlotTracer',true,'FontSize',12,'ZoomIn',1==1,...
%         'SaveGif',1==0,'GifFile',strrep(filename,'.mat','zoom.gif'));
% end
%%  Compare to old results
% load('C:\Users\John Jr\Desktop\Manta Ray\Model 9_28\Results\Manta 2.0\Rotor\Turb1.8_V-0.315_EL-30.0_D-0.65_E--0.30_10-03_16-07.mat')
% tsc.rotPowerSummary(vhcl,env);
% [Idx1,Idx2] = tsc.getLapIdxs(max(tsc.lapNumS.Data)-1);  ran = Idx1:Idx2;
% AoA = mean(squeeze(tsc.vhclAngleOfAttack.Data(:,:,ran)));
% fprintf('Average AoA = %.3f \n',AoA);