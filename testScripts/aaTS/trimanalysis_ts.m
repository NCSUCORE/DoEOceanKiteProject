%% Test script for John to control the kite model
Simulink.sdi.clear
clear;clc;%close all
%%  Select sim scenario
%   0 = fig8;
%   1 = fig8-2rot DOE-M;  1.1 = fig8-2rot AVL;  1.2 = fig8-2rot XFoil;  1.3 = fig8-2rot XFlr5;
%   2 = fig8-winch DOE;
%   3 = steady Old;       3.1 = steady AVL;     3.2 = steady XFoil      3.3 = Steady XFlr5      3.4 = Steady XFlr5 Passive ;
%   4 = LaR Old;          4.1 = LaR AVL;        4.2 = LaR XFoil;        4.3 = LaR XFlr5 
simScenario = 3.3;
simScenariosub = (simScenario - floor(simScenario))*10
%%  Set Physical Test Parameters
thrLength = [20:5:50];                         % m - Initial tether length
flwSpd = [0.25:.25:2];                             % m/s - Flow speed
el = 66.59*pi/180;                                 % rad - Mean elevation angle
h = 10*pi/180;  w = 40*pi/180;                     % rad - Path width/height
[a,b] = boothParamConversion(w,h);                 % Build Path
desPitch = [0:1:10];%[0:2:16];                            % Desired Pitch in degrees
%%Flow Disturbance
flowDir = 0*pi/180 % rotation direction of flow about body z degrees
stepTime = 600;

%Controller Freeze
ctrlFreeze = 0; %Freeze Control Surface Deflections 0 = off 1 = on
ctrlFreezeTime = 500 %Sim time to freeze control surface deflections

linCtrl = 0; %0 - Normal Control; 1 - Controller Manipulation
linearize = 1;%0 - No linearization; 1 - Linearization turned on 
if simScenario == 3.3
ctrlPitch = 0; % Controller State 0 - Single Pitch 1 - Lookup Table 2 - Elevator Controller
end


%   Path basis parameters
for kk = 1:numel(desPitch)
for jj = 1:numel(thrLength)
for ii =1:numel(flwSpd)
    linState = 0; %0 - Normal Control; 1 - Controller Manipulation
    %%  Load components
    if simScenario >= 3
        loadComponent('slCtrl');                         %   Launch and recovery controller
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
        loadComponent('MantaKiteAVL_DOE');                                  %   Manta kite old
    elseif simScenario == 2
        loadComponent('fullScale1thr');                                     %   DOE kite 
    elseif simScenario == 1 || simScenario == 3 || simScenario == 4
        loadComponent('Manta2RotAVL_DOE');                                  %   Manta DOE kite with AVL 
    elseif simScenario == 1.1 || simScenario == 3.1 || simScenario == 4.1
        loadComponent('Manta2RotAVL_Thr075');                               %   Manta kite with AVL
    elseif simScenario == 1.2 || simScenario == 3.2 || simScenario == 4.2
        loadComponent('Manta2RotXFlr_CFD_AR__ExpScale');                             %   Manta kite with XFoil
    elseif simScenario == 1.3 || simScenario == 3.3 || simScenario == 3.4 || simScenario == 4.3
        loadComponent('Manta2RotXFoil_AR8_b8');                              %   Manta kite with XFlr5 
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
        hiLvlCtrl.basisParams.setValue([w,h,el,0*pi/180,thrLength(jj)],'[rad rad rad rad m]') % Ellipse
    else
        hiLvlCtrl.basisParams.setValue([a,b,el,0*pi/180,thrLength(jj)],'[rad rad rad rad m]') % Lemniscate of Booth
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
        vhcl.setInitEulAng([0,desPitch(kk),0]*pi/180,'rad')
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
    thr.tether1.setDiameter(0.009,thr.tether1.diameter.Unit);
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
    if simScenario >= 3 && simScenario < 4
        fltCtrl.LaRelevationSP.setValue(35,'deg');          fltCtrl.LaRelevationSPErr.setValue(1,'deg');        %   Elevation setpoints
        fltCtrl.pitchSP.kp.setValue(10,'(deg)/(deg)');      fltCtrl.pitchSP.ki.setValue(.01,'(deg)/(deg*s)');    %   Elevation angle outer-loop controller
        fltCtrl.pitchAngleMax.upperLimit.setValue(45,'');   fltCtrl.pitchAngleMax.lowerLimit.setValue(-45,'');
        fltCtrl.setNomSpoolSpeed(.25,'m/s');                fltCtrl.setSpoolCtrlTimeConstant(5,'s');
        wnch.winch1.elevError.setValue(2,'deg');
        vhcl.turb1.setPowerCoeff(0,'');
%         fltCtrl.rollMoment.kp.setValue(0,'(N*m)/(rad)'); fltCtrl.rollMoment.kd.setValue(0,'(N*m)/(rad/s)');
        fltCtrl.pitchConst.setValue(desPitch(kk),'deg');
        fltCtrl.pitchCtrl.setValue(ctrlPitch,'');
        fltCtrl.initCtrlVec;
        fltCtrl.rudderCmd.kp.setValue(0,'(deg)/(rad)');
        fltCtrl.rudderCmd.ki.setValue(0,'(deg)/(rad*s)');
        fltCtrl.rudderCmd.kd.setValue(0,'(deg)/(rad/s)');
        fltCtrl.rudderCmd.tau.setValue(.1,'s');
%         fltCtrl.rudderCmd.kp.setValue(1000,'(deg)/(rad)');
%         fltCtrl.rudderCmd.ki.setValue(100,'(deg)/(rad*s)');
%         fltCtrl.rudderCmd.kd.setValue(1000,'(deg)/(rad/s)');
%         fltCtrl.rudderCmd.tau.setValue(.1,'s');
%         fltCtrl.elevCmd.kp.setValue(0,'(deg)/(rad)');
%         fltCtrl.elevCmd.ki.setValue(0,'(deg)/(rad*s)');
        fltCtrl.setNomSpoolSpeed(0,'m/s');
    end
           
%     fltCtrl.rollMoment.kp.setValue(0,'(N*m)/(rad)'); fltCtrl.rollMoment.kd.setValue(0,'(N*m)/(rad/s)'); 
    thr.tether1.dragEnable.setValue(1,'');
    % vhcl.rBridle_LE.setValue([0,0,0]','m');

%%  Set up critical system parameters and run simulation
    simParams = SIM.simParams;  simParams.setDuration(3000,'s');  dynamicCalc = '';
    %Turn on elevator control
    fprintf('Simulating')

    trimCtrl=[ -0.0000    0.0000    1.7877         0];
    %set_param(bdroot,'SimulationCommand','Update')
%     sim('OCTModel_for_lin')
%     sim('OCTModel')
%     %Plot Model Response
%     close all
%     tsc = signalcontainer(logsout);
%     tsc.plotLaR(fltCtrl);
%     plotLateral
%     plotLong
    sim('OCTModel_for_lin')
    tsc = signalcontainer(logsout);
%     tsc.plotLaR(fltCtrl);
%     plotLateral
%     plotLong
    %Turn off controller
    if linearize == 1
        linCtrl = 1;
        %Get control inputs at steady state
        len = tsc.azimuthAngle.Length
        trimCtrl = tsc.ctrlSurfDeflCmd.getsamples(len).Data
        set_param(bdroot,'SimulationCommand','Update')

        fprintf('Linearizing')
        [A,B,C,D] = linmod('OCTModel_for_lin',xFinal,[0 0 0 0 0]);
        sys = ss(A,B,C,D);
        linsys.ss = sys;
        linsys.title = sprintf('Flow Speed %.2f m/s Tether Length %d m Pitch SP %d',...
            flwSpd(ii), thrLength(jj), desPitch(kk));
        linsys.timeseries = tsc;
        linsys.xFinal = xFinal
        varNam = sprintf('%d_%d_%d.mat',100*flwSpd(ii),thrLength(jj),desPitch(kk));
        save(varNam,'linsys')
        clear linsys
        clear trimCtrl
    end
    close all
end
end
end

%  Plot Results
% close all
% if simScenario < 3 && simScenario ~= 2
%     tsc.plotFlightResults(vhcl,env,'plot1Lap',1==1,'plotS',1==1,'plotBeta',1==0,'lapNum',max(tsc.lapNumS.Data)-1)
% else
%     tsc.plotLaR(fltCtrl);
% end
% figure
% tsc.azimuthAngle.plot
% figure
% tsc.eul.plot

% figure
% plotLateral
% figure
% plotLong
% vhcl.animateSim(tsc,2,'PathFunc',fltCtrl.fcnName.Value,...
%     'GifTimeStep',.01,'PlotTracer',true,'FontSize',12,'Pause',1==0,...
%     'ZoomIn',1==0);


