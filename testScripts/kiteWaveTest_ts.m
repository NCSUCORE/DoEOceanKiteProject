
% Hs = .27   % meters
% tp = 3; % seconds
% w =   2*pi/tp % rad/s
% k = (2*pi)/(8.5)%(w^2)/9.81 %rad/m

% Hs = 1.5;   % meters
% tp = 5.7; % seconds
% w =   2*pi/tp % rad/s
% k = (2*pi)/(33.8)%(w^2)/9.81 %rad/m
% Hs = 4.1;   % meters
% tp = 8.6; % seconds
% w =   2*pi/tp % rad/s
% k = (2*pi)/(78.5)%(w^2)/9.81 %rad/m


waveNumber  =  linspace(.7392,0.0800,10);
Frequencies =  linspace(2.0944,0.7306,10);
Amplitudes  =  linspace(.27, 4.1,10);




for i = 1:1
    
    % %% Script to run ILC path optimization
    clearvars -except 'Amplitudes' 'Frequencies' 'waveNumber' 'i' 'j'
    clc;close all
    simParams = SIM.simParams;
    simParams.setDuration(1000,'s');
    dynamicCalc = '';
    
    %% Load components
    % Flight Controller
    loadComponent('pathFollowingCtrlForILC');
    % Ground station controller
    loadComponent('oneDoFGSCtrlBasic');
    % High level controller
    loadComponent('constBoothLem')
    % Ground station
    loadComponent('pathFollowingGndStn');
    % Winches
    loadComponent('oneDOFWnchPTO');
    % Tether
    loadComponent('pathFollowingTether');
    % Vehicle
    loadComponent('pathFollowingVhcl');
    % Environment
    % loadComponent('constXYZT');
    loadComponent('hurricaneSandyWave');
    % Sensors
    loadComponent('idealSensors')
    % Sensor processing
    loadComponent('idealSensorProcessing')
    
    %% Environment IC's and dependant properties
    env.water.setflowVec([1 0 0],'m/s')
    
    
    env.waterWave.waveParamMat.setValue([waveNumber(i),Frequencies(i),Amplitudes(i) ,0;0,0,0,0],'')
    %% Set basis parameters for high level controller
    % hiLvlCtrl.initBasisParams.setValue([0.8,1.4,-20*pi/180,0*pi/180,125],'[]') % Lemniscate of Booth
    hiLvlCtrl.basisParams.setValue([1,1.4,-20*pi/180,0*pi/180,125],'') % Lemniscate of Booth
    %% Ground Station IC's and dependant properties
    gndStn.setPosVec([0 0 200],'m')
    gndStn.initAngPos.setValue(0,'rad');
    gndStn.initAngVel.setValue(0,'rad/s');
    
    %% Set vehicle initial conditions
    vhcl.setICsOnPath(...
        0,... % Initial path position
        PATHGEOMETRY,... % Name of path function
        hiLvlCtrl.basisParams.Value,... % Geometry parameters
        gndStn.posVec.Value,... % Center point of path sphere
        (11/2)*norm([ 1 0 0 ])) % Initial speed
    vhcl.setAddedMISwitch(false,'');
    
    %% Tethers IC's and dependant properties
    thr.tether1.initGndNodePos.setValue(gndStn.thrAttch1.posVec.Value(:)...
        +gndStn.posVec.Value(:),'m');
    thr.tether1.initAirNodePos.setValue(vhcl.initPosVecGnd.Value(:)...
        +rotation_sequence(vhcl.initEulAng.Value)*vhcl.thrAttchPts.posVec.Value,'m');
    
    thr.tether1.initGndNodeVel.setValue([0 0 0]','m/s');
    thr.tether1.initAirNodeVel.setValue(vhcl.initVelVecBdy.Value(:),'m/s');
    
    thr.tether1.vehicleMass.setValue(vhcl.mass.Value,'kg');
    
    %% Winches IC's and dependant properties
    % wnch.setTetherInitLength(vhcl,gndStn.posVec.Value,env,thr,env.water.flowVec.Value);
    wnch.setTetherInitLength(vhcl,gndStn.posVec.Value,env,thr,[ 1 0 0]);
    
    %% Controller User Def. Parameters and dependant properties
    fltCtrl.setFcnName(PATHGEOMETRY,''); % PATHGEOMETRY is defined in fig8ILC_bs.m
    % Set initial conditions
    % fltCtrl.setInitPathVar(vhcl.initPosVecGnd.Value,...
    %     hiLvlCtrl.initBasisParams.Value,...
    %     gndStn.posVec.Value);
    vhcl.addedMass.setValue(zeros(3,3),'kg')
    fltCtrl.setInitPathVar(vhcl.initPosVecGnd.Value,...
        hiLvlCtrl.basisParams.Value,...
        gndStn.posVec.Value);
    simWithMonitor('OCTModel')
    tsc = signalcontainer(logsout);
    
    
    try
        %                 h1 = figure;
        %                 plotAnchThrTen;
        %                 h2 =figure;
        %                 tsc.gndStnPositionVec.plot;
        h3 = figure;
        plotPower
        
        % saveas(h1,sprintf('C:\\Users\\jcreed2\\GitStuff\\bubble3P0\\outputJames\\%d\\anchThrTen%d.png', 1,2))
%       saveas(h1,sprintf('C:\\Users\\jcreed2\\GitStuff\\bubble3P0\\outputJames\\anchThrTen%d%d%d.png', i,j,k))
        %                 saveas(h2,sprintf('C:\\Users\\jcreed2\\GitStuff\\bubble3P0\\outputJames\\gndStnPos%d%d%d.png', i,j,k))
        saveas(h3,sprintf('C:\\Users\\jcreed2\\GitStuff\\bubble3P0\\outputJames2\\power%d.png', i))
    catch
    end
    
    
end
%% Plot/Animate the Results
vhcl.animateSim(tsc,1,...
    'PathFunc',fltCtrl.fcnName.Value,...
    'PlotTracer',true,...
    'FontSize',24,...
    'PowerBar',false,...
    'PlotAxes',false,...
    'TracerDuration',10,...
    'SaveGif',false)