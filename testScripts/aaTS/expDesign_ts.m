%% Test script for John to control the kite model
Simulink.sdi.clear
clear;clc;%close all
%%  Select sim scenario
%   0 = fig8;
%   1 = fig8-2rot DOE-M;  1.1 = fig8-2rot AVL;  1.2 = fig8-2rot XFoil;  1.3 = fig8-2rot XFlr5;
%   2 = fig8-winch DOE;
%   3 = steady Old;       3.1 = steady AVL;     3.2 = steady XFoil      3.3 = Steady XFlr5      3.4 = Steady XFlr5 Passive ;
%   4 = LaR Old;          4.1 = LaR AVL;        4.2 = LaR XFoil;        4.3 = LaR XFlr5
h = 10*pi/180;  w = 40*pi/180;                     % rad - Path width/height
[a,b] = boothParamConversion(w,h);                 % Build Path
simScenario = 3.2;
% Simulation Time
simTime = 1000;
%%  Configure Test
thrLength = 10                  % m - Initial tether length
flwSpd = sqrt(0.5)                   % m/s - Flow speed)
craftSpeed = 0.0% Moving Ground Station Velocity Magnitude m/s
elevation =  30%[0:10:80]
rDes =[-0.3:.01:0.0];
for mm = 1:length(rDes)
    el = elevation*pi/180;                                 % rad - Mean elevation angle
    % rDes(mm)
    
    %Ground Station Trajectory
    time = [0 150 165 180 195 210 215 63300  633000];
    vel = craftSpeed*[1 1 1 1 1 1 1 1 1;...
        0 0 0 0 0 0 0 0 0;...
        0 0 0 0 0 0 0 0 0]';
    angVel = [0 0 0 0 0 0 0 0 0;...
        0 0 0 0 0 0 0 0 0;...
        %     0 0 0 0 0 0 0 0 0]';
        0 0 0 0 0 0 0 0 0]';
    spiral = 1; %1 for prescribed control 2 for spiral transit
    
    
    
    %%  Load components
    if simScenario > 3
        loadComponent('LaRController');                         %   Launch and recovery controller
    else
        loadComponent('pathFollowWithAoACtrl');             %   Path-following controller
    end
    loadComponent('oneDoFGSCtrlBasic');                         %   Ground station controller
    if simScenario > 2 && simScenario < 3
        loadComponent('prescribedGndStn001')
        gndStn.pathVar.setValue(spiral,'')
    else
        loadComponent('pathFollowingGndStn');                       %   Ground station
    end
    loadComponent('winchManta');                                %   Winches
    loadComponent('MantaTether');                           %   Single link tether
    loadComponent('idealSensors')                               %   Sensors
    loadComponent('idealSensorProcessing')                      %   Sensor processing
    
    loadComponent('Manta2RotXFoil_AR8_b8_expt');                             %   Manta kite with XFoil
    vhcl.turb1.setDiameter(0,'m');
    vhcl.turb2.setDiameter(0,'m');
    vhcl.setBuoyFactor(1,'');
    %%  Environment Properties
    loadComponent('constXYZT');                                 %   Environment
    env.water.setflowVec([flwSpd 0 0],'m/s');               %   m/s - Flow speed vector
    ENVIRONMENT = 'environmentManta2Rot';                   %   Two turbines
    %%  Set basis parameters for high level controller
    loadComponent('constBoothLem');                             %   High level controller
    hiLvlCtrl.basisParams.setValue([a,b,el,0*pi/180,thrLength],'[rad rad rad rad m]') % Lemniscate of Booth
    
    %%  Ground Station Properties
    if simScenario == 2.3 || simScenario == 2.2
        gndStn.setVelVecTrajectory(vel,time,'m/s');
        gndStn.setAngVelTrajectory(angVel,time,'rad/s');
        gndStn.setInitPosVecGnd([0 0 0],'m');
        gndStn.setInitEulAng([0 0 0]*pi/180,'rad')
    else
        gndStn.setPosVec([0 0 0],'m');
        gndStn.setVelVec([0 0 0],'m/s');
        gndStn.initAngPos.setValue(0,'rad');
        gndStn.initAngVel.setValue(0,'rad/s');
    end
    %%  Vehicle Properties
    if simScenario < 3 && simScenario > 2
        vhcl.setICsOnPath(0,PATHGEOMETRY,hiLvlCtrl.basisParams.Value,gndStn.initPosVecGnd.Value,0);
        vhcl.setInitEulAng([0 0 0]*pi/180,'rad');
        vhcl.setInitVelVecBdy([craftSpeed 0 0],'m/s')
    elseif simScenario > 3
        vhcl.setICsOnPath(0,PATHGEOMETRY,hiLvlCtrl.basisParams.Value,gndStn.posVec.Value,0);
        vhcl.setInitEulAng([0,0,0]*pi/180,'rad');
    else
        vhcl.setICsOnPath(.05,PATHGEOMETRY,hiLvlCtrl.basisParams.Value,gndStn.posVec.Value,6.5*flwSpd*norm([1;0;0]))
    end
    %%  Tethers Properties
    if simScenario < 3 && simScenario > 2
        thr.tether1.initGndNodePos.setValue(gndStn.thrAttach.posVec.Value(:)+gndStn.initPosVecGnd.Value(:),'m');
    else
        thr.tether1.initGndNodePos.setValue(gndStn.thrAttch1.posVec.Value(:)+gndStn.posVec.Value(:),'m');
    end
    thr.tether1.initAirNodePos.setValue(vhcl.initPosVecGnd.Value(:)...
        +rotation_sequence(vhcl.initEulAng.Value)*vhcl.thrAttchPts_B.posVec.Value,'m');
    thr.tether1.initGndNodeVel.setValue([craftSpeed 0 0]','m/s');
    thr.tether1.initAirNodeVel.setValue(vhcl.initVelVecBdy.Value(:),'m/s');
    thr.tether1.vehicleMass.setValue(vhcl.mass.Value,'kg');
    if simScenario == 1.2 || simScenario == 2.2 || simScenario == 3.2 || simScenario == 4.2
        thr.tether1.setDensity(env.water.density.Value,thr.tether1.density.Unit);
        thr.tether1.setDiameter(0.0076,thr.tether1.diameter.Unit);
    end
    %                             vhcl.setRBridle_LE([vhcl.rCM_LE.Value(1)-.2;0;-vhcl.fuse.diameter.Value/2],'m');
    %%  Winches Properties
    if simScenario >2 && simScenario < 3
        wnch.setTetherInitLength(vhcl,gndStn.initPosVecGnd.Value,env,thr,env.water.flowVec.Value);
    else
        wnch.setTetherInitLength(vhcl,gndStn.posVec.Value,env,thr,env.water.flowVec.Value);
    end
    wnch.winch1.LaRspeed.setValue(1,'m/s');
    %%  Controller User Def. Parameters and dependant properties
    fltCtrl.setFcnName(PATHGEOMETRY,''); % PATHGEOMETRY is defined in fig8ILC_bs.m
    if simScenario > 2 && simScenario <3
        fltCtrl.setInitPathVar(vhcl.initPosVecGnd.Value,...
            hiLvlCtrl.basisParams.Value,gndStn.initPosVecGnd.Value);
    else
        fltCtrl.setInitPathVar(vhcl.initPosVecGnd.Value,...
            hiLvlCtrl.basisParams.Value,gndStn.posVec.Value);
    end
    fltCtrl.tanRoll.setKp(fltCtrl.tanRoll.kp.Value*1,fltCtrl.tanRoll.kp.Unit);
    if simScenario >= 2 && simScenario < 4
        fltCtrl.LaRelevationSP.setValue(elevation,'deg');          fltCtrl.LaRelevationSPErr.setValue(1,'deg');        %   Elevation setpoints
        fltCtrl.pitchSP.kp.setValue(10,'(deg)/(deg)');      fltCtrl.pitchSP.ki.setValue(.01,'(deg)/(deg*s)');    %   Elevation angle outer-loop controller
        fltCtrl.pitchAngleMax.upperLimit.setValue(45,'');   fltCtrl.pitchAngleMax.lowerLimit.setValue(-45,'');
        fltCtrl.setNomSpoolSpeed(0,'m/s');                fltCtrl.setSpoolCtrlTimeConstant(5,'s');
        wnch.winch1.elevError.setValue(2,'deg');
        vhcl.turb1.setPowerCoeff(0,'');
        fltCtrl.initCtrlVec;
    end
    thr.tether1.dragEnable.setValue(1,'');
    vhcl.rBridle_LE.setValue([vhcl.rCM_B.Value(1)+rDes(mm) 0 -vhcl.fuse.diameter.Value/2]','m')
    fltCtrl.scale(0.1,1);
%     thr.scale(0.1,1);
    vhcl.turb1.scale(0.1,1);
    vhcl.turb2.scale(0.1,1);
    gndStn.scale(0.1,1);
%     env.scale(0.1,1);
    hiLvlCtrl.scale(0.1,1);
    wnch.scale(0.1,1);
    %%  Set up critical system parameters and run simulation
    simParams = SIM.simParams;  simParams.setDuration(simTime,'s');  dynamicCalc = '';
    simWithMonitor('OCTModel')
    tsc = signalcontainer(logsout);
    dir = fullfile(fileparts(which('OCTProject.prj')),'output\ExpDesign\');
    file = sprintf('deltaL_%.2f.mat',rDes(mm));
    filename = strcat(dir,file);
    save(filename,'tsc','vhcl')
end
