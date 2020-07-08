%% Test script to characterize power production of the manta ray system
clear;clc;close all
tetherLengths       = 400;
flowSpeeds          = .25;
lengthScaleFactors  = 0.8;

%% Set up critical system parameters
simParams = SIM.simParams;
simParams.setDuration(2000,'s');
dynamicCalc = '';
w = 30*pi/180;
h = 15*pi/180;
[a,b] = boothParamConversion(w,h);

%% Loop over tether lengths and flow speeds
for ii = 1:numel(tetherLengths)
    %% Load components
    % Flight Controller
    loadComponent('pathFollowingCtrlForILC');
    fltCtrl.rudderGain.setValue(0,'')
    SPOOLINGCONTROLLER = 'netZeroSpoolingController';
    % Ground station controller
    loadComponent('oneDoFGSCtrlBasic');
    % High level controller
    loadComponent('constBoothLem');
    % Ground station
    loadComponent('pathFollowingGndStn');
    % Winches
    loadComponent('oneDOFWnch');
    % Tether
    loadComponent('fiveNodeSingleTether');
    % Sensors
    loadComponent('idealSensors')
    % Sensor processing
    loadComponent('idealSensorProcessing')
    % Vehicle
    loadComponent('fullScale1thr');
    % Environment
    loadComponent('ConstXYZT');
    
    %% Scale everything to Manta Ray, except environment and sim params
    fltCtrl.scale(lengthScaleFactors(ii),1);
    gndStn.scale(lengthScaleFactors(ii),1);
    hiLvlCtrl.scale(lengthScaleFactors(ii),1);
    vhcl.scale(lengthScaleFactors(ii),1);
    wnch.scale(lengthScaleFactors(ii),1);
    thr.scale(lengthScaleFactors(ii),1);
    env.scale(lengthScaleFactors(ii),1);
    
    %% Environment IC's and dependant properties
    env.water.setflowVec([flowSpeeds(ii) 0 0],'m/s')
    
    %% Set basis parameters for high level controller
    hiLvlCtrl.basisParams.setValue(...
        [a,b,10*pi/180,0*pi/180,tetherLengths(ii)],...
        '[rad rad rad rad m]') % Lemniscate of Booth
    
    %% Ground Station IC's and dependant properties
    gndStn.setPosVec([0 0 0],'m')
    gndStn.setVelVec([0 0 0],'m/s')
    gndStn.initAngPos.setValue(0,'rad');
    gndStn.initAngVel.setValue(0,'rad/s');
    
    %% Set vehicle initial conditions
    vhcl.setICsOnPath(...
        .05,... % Initial path position
        PATHGEOMETRY,... % Name of path function
        hiLvlCtrl.basisParams.Value,... % Geometry parameters
        gndStn.posVec.Value,... % Center point of path sphere
        (11/2)*norm(env.water.flowVec.Value)) % Initial speed
    
    %% Tethers IC's and dependant properties
    thr.tether1.initGndNodePos.setValue(gndStn.thrAttch1.posVec.Value(:)...
        +gndStn.posVec.Value(:),'m');
    thr.tether1.initAirNodePos.setValue(vhcl.initPosVecGnd.Value(:)...
        +rotation_sequence(vhcl.initEulAng.Value)*vhcl.thrAttchPts_B.posVec.Value,'m');
    
    thr.tether1.initGndNodeVel.setValue([0 0 0]','m/s');
    thr.tether1.initAirNodeVel.setValue(vhcl.initVelVecBdy.Value(:),'m/s');
    
    thr.tether1.vehicleMass.setValue(vhcl.mass.Value,'kg');
    %% Winches IC's and dependant properties
    wnch.setTetherInitLength(vhcl,gndStn.posVec.Value,env,thr,env.water.flowVec.Value);
    
    %% Controller User Def. Parameters and dependant properties
    fltCtrl.setFcnName(PATHGEOMETRY,''); % PATHGEOMETRY is defined in fig8ILC_bs.m
    % vhcl.addedMass.setValue(zeros(3,3),'kg')
    fltCtrl.setInitPathVar(vhcl.initPosVecGnd.Value,...
        hiLvlCtrl.basisParams.Value,...
        gndStn.posVec.Value);
    
    %% Hack things to make it run at lower flow speeds
    fltCtrl.setElevatorReelInDef(0,'deg')
    fltCtrl.tanRoll.setKp(fltCtrl.tanRoll.kp.Value*10,fltCtrl.tanRoll.kp.Unit);
    thr.tether1.setDensity(env.water.density.Value,thr.tether1.density.Unit);
    thr.tether1.setDiameter(0.007,thr.tether1.diameter.Unit);
    thr.tether1.setYoungsMod(thr.tether1.youngsMod.Value*1.2,thr.tether1.youngsMod.Unit);
    
    %% Run Simulation
    simWithMonitor('OCTModel')
    tsc = signalcontainer(logsout);
    
%     tsc.winchPower.plot

    %%
    vhcl.animateSim(tsc,2,'PathFunc',fltCtrl.fcnName.Value,...
        'GifTimeStep',0.2,...
        'PlotTracer',true,...
        'FontSize',18,...
        'Pause',false,...
        'ZoomIn',false,...
        'SaveGif',true,...
        'GifFile',sprintf('SF%d_TL%d_FS%d.gif',lengthScaleFactors(ii),tetherLengths(ii),flowSpeeds(ii)));
end
