%% Test script for John to control the kite model
Simulink.sdi.clear
clear;clc;%close all
%%  Select sim scenario
%   0 = fig8;
%   1 = fig8-2rotor Old;  1.1 = fig8-2rotor New;  1.2 = fig8-2rotor New XFoil;  2 = fig8-winch DOE;
%   3 = steady Old;       3.1 = steady New;       3.2 = steady New XFoil 
%   4 = LaR Old;          4.1 = LaR New;          4.2 = LaR New XFoil;
simScenario = 1.1;
%%  Set Physical Test Parameters
thrLength = 400;                                            %   m - Initial tether length
flwSpd = 0.315;%[0.25 0.315 0.5 1 2];                                               %   m/s - Flow speed
lengthScaleFactors = 0.8;                                   %   Factor to scale DOE kite to Manta Ray
el = 30*pi/180;                                             %   rad - Mean elevation angle
h = 10*pi/180;  w = 40*pi/180;                              %   rad - Path width/height
[a,b] = boothParamConversion(w,h);                          %   Path basis parameters
for ii = 1:numel(flwSpd)
    %%  Load components
    if simScenario >= 3
        loadComponent('LaRController');                         %   Launch and recovery controller
    elseif simScenario == 2
        loadComponent('pathFollowingCtrlForILC');
    else
        loadComponent('pathFollowingCtrlForManta');             %   Path-following controller
    end
    loadComponent('oneDoFGSCtrlBasic');                         %   Ground station controller
    loadComponent('pathFollowingGndStn');                       %   Ground station
    loadComponent('winchManta');                                %   Winches
    if simScenario >= 4
        minLinkDeviation = .1;
        minSoftLength = 0;
        minLinkLength = 1;                                      %   Length at which tether rediscretizes
        loadComponent('shortTether');                           %   Tether for reeling
    else
        loadComponent('MantaTether');                           %   Single link tether
    end
    loadComponent('idealSensors')                               %   Sensors
    loadComponent('idealSensorProcessing')                      %   Sensor processing
    
    if simScenario == 0
        loadComponent('MantaKiteNACA2412');                                 %   Manta kite old
    elseif simScenario == 2
        loadComponent('fullScale1thr');                                     %   DOE kite 
    elseif simScenario == 1 || simScenario == 3 || simScenario == 4
        loadComponent('Manta2RotNACA2412');                                 %   Manta kite old with 2 rotors
    elseif simScenario == 1.1 || simScenario == 3.1 || simScenario == 4.1
        loadComponent('Manta2RotNew');                                      %   Manta kite new with 2 rotors
    elseif simScenario == 1.2 || simScenario == 3.2 || simScenario == 4.2
        loadComponent('Manta2RotNewXFoil');                                 %   Manta kite new with 2 rotors and XFoil
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
    if simScenario == 0
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
    wnch.winch1.LaRspeed.setValue(1,'m/s');
    %%  Controller User Def. Parameters and dependant properties
    fltCtrl.setFcnName(PATHGEOMETRY,''); % PATHGEOMETRY is defined in fig8ILC_bs.m
    fltCtrl.setInitPathVar(vhcl.initPosVecGnd.Value,...
        hiLvlCtrl.basisParams.Value,gndStn.posVec.Value);
    if simScenario ~= 2
        fltCtrl.setFirstSpoolLap(1000,'');
    end
    fltCtrl.rudderGain.setValue(0,'')
    if simScenario == 1.1
        fltCtrl.setElevatorReelInDef(-2,'deg')
    else
        fltCtrl.setElevatorReelInDef(0,'deg')
    end
    fltCtrl.tanRoll.setKp(fltCtrl.tanRoll.kp.Value*1,fltCtrl.tanRoll.kp.Unit);
    if simScenario >= 3
        fltCtrl.LaRelevationSP.setValue(35,'deg');          fltCtrl.LaRelevationSPErr.setValue(1,'deg');        %   Elevation setpoints
        fltCtrl.pitchSP.kp.setValue(10,'(deg)/(deg)');      fltCtrl.pitchSP.ki.setValue(.01,'(deg)/(deg*s)');    %   Elevation angle outer-loop controller
        fltCtrl.elevCmd.kp.setValue(200,'(deg)/(rad)');     fltCtrl.elevCmd.ki.setValue(5,'(deg)/(rad*s)');    %   Elevation angle inner-loop controller
        fltCtrl.pitchAngleMax.upperLimit.setValue(45,'');   fltCtrl.pitchAngleMax.lowerLimit.setValue(-45,'');
        fltCtrl.setNomSpoolSpeed(.25,'m/s');                fltCtrl.setSpoolCtrlTimeConstant(5,'s');
        wnch.winch1.elevError.setValue(2,'deg');
        vhcl.turb1.setPowerCoeff(0,'');
    end
    if simScenario >= 3 && simScenario < 4
        fltCtrl.elevCmd.kp.setValue(0,'(deg)/(rad)');       fltCtrl.elevCmd.ki.setValue(0,'(deg)/(rad*s)');
        fltCtrl.setNomSpoolSpeed(0,'m/s');
    end
    tRef = [0  250 500 750 1000 1250 1500 1750 2000 2250 2500 2750 3000];
    pSP =  [30 30  30  30  30   40   40   40   40   40   40   40   40];
    thr.tether1.dragEnable.setValue(1,'');
    % vhcl.rBridle_LE.setValue([0,0,0]','m');
    %%  Set up critical system parameters and run simulation
    simParams = SIM.simParams;  simParams.setDuration(2000,'s');  dynamicCalc = '';
    simWithMonitor('OCTModel')
    %%  Log Results
    tsc = signalcontainer(logsout);
    if simScenario ~= 2
        Pow = tsc.rotPowerSummary(vhcl,env);
    end
    dt = datestr(now,'mm-dd_HH-MM');
    if simScenario == 0
        filename = sprintf(strcat('Manta_EL-%.1f_w-%.1f_h-%.1f_',dt,'.mat'),el*180/pi,w*180/pi,h*180/pi);
        fpath = fullfile(fileparts(which('OCTProject.prj')),'Results','Manta\');
    elseif simScenario > 0 && simScenario < 2
        if numel(flwSpd) == 1
            filename = sprintf(strcat('Turb2_V-%.2f_EL-%.1f_D-%.2f_w-%.1f_h-%.1f_',dt,'.mat'),flwSpd(ii),el*180/pi,vhcl.turb1.diameter.Value,w*180/pi,h*180/pi);
            fpath = fullfile(fileparts(which('OCTProject.prj')),'Results','Manta','Rotor\');
        else
            filename = sprintf(strcat('NewTurb2_V-%.3f.mat'),flwSpd(ii));
            fpath = fullfile(fileparts(which('OCTProject.prj')),'Results','Manta 2.0','Rotor','400 m Tether 9-6\');
        end
    elseif simScenario == 2
        filename = sprintf(strcat('Winch_EL-%.1f_Thr-%d_w-%.1f_h-%.1f_',dt,'.mat'),el*180/pi,thrLength,w*180/pi,h*180/pi);
        fpath = fullfile(fileparts(which('OCTProject.prj')),'Results','Manta','Winch\');
    elseif simScenario >= 3 && simScenario < 4
        filename = sprintf(strcat('Steady_EL-%.1f_kp-%.2f_ki-%.2f_',dt,'.mat'),el*180/pi,fltCtrl.elevCmd.kp.Value,fltCtrl.elevCmd.ki.Value);
        fpath = fullfile(fileparts(which('OCTProject.prj')),'Results','Manta','Steady\');
    elseif simScenario >= 4
        filename = sprintf(strcat('LaR_EL-%.1f_SP-%.1f_t-%.1f_Wnch-%.1f_',dt,'.mat'),el*180/pi,fltCtrl.LaRelevationSP.Value,simParams.duration.Value,fltCtrl.nomSpoolSpeed.Value);
    %     filename = sprintf(strcat('Elevation_kp-%.1f_ki-%.2f_',dt,'.mat'),fltCtrl.pitchSP.kp.Value,fltCtrl.pitchSP.ki.Value);
        fpath = fullfile(fileparts(which('OCTProject.prj')),'Results','Manta 2.0','LaR\');
    end
%     save(strcat(fpath,filename),'tsc','vhcl','thr','fltCtrl','env','simParams','LIBRARY','gndStn')
end
%%  Plot Results
if simScenario < 3 && simScenario ~= 2
    tsc.plotFlightResults(vhcl,env,'plot1Lap',1==1,'plotS',1==1,'plotBeta',1==0,'lapNum',max(tsc.lapNumS.Data)-1)
else
    tsc.plotLaR(fltCtrl);
end
%%  Animate Simulation
% if simScenario <= 2
%     vhcl.animateSim(tsc,2,'PathFunc',fltCtrl.fcnName.Value,...
%         'GifTimeStep',.05,'PlotTracer',true,'FontSize',12,'Pause',false,...
%         'ZoomIn',1==0,'SaveGif',1==0,'GifFile',strrep(filename,'.mat','.gif'));
% else
%     vhcl.animateSim(tsc,2,'View',[0,0],...
%         'GifTimeStep',.05,'PlotTracer',true,'FontSize',12,'ZoomIn',1==1,...
%         'SaveGif',1==0,'GifFile',strrep(filename,'.mat','zoom.gif'));
% end
%%  Compare to old results
% tsc.turbEnrg.Data(1,1,end)
% load('C:\Users\John Jr\Desktop\Manta Ray\Model\Results\Manta\Rotor\Turb2_V-0.25_EL-30.0_D-0.56_w-40.0_h-15.0_08-04_10-56.mat')
% tsc.turbEnrg.Data(1,1,end)


