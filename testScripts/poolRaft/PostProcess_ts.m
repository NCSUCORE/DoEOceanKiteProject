%% Test script for pool test simulation of the kite model
% clear;clc;close all;

clc
% close all
Simulink.sdi.clear
clear tsc1
distFreq = 0;distAmp = 0;pertVec = [0 1 0];
%%  Set Test Parameters
saveSim = 0;               %   Flag to save results
runLin = 0;                %   Flag to run linearization
inc =-5.5;
elevArray = 20*pi/180%[40 15]*pi/180;
towArray = [0.78];
rCM = 1
thrLength = 2.63;
flwSpd = -1e-9;
for q = 2
    for i = 1:length(inc)
        i
        for j = 1:length(towArray)
            j
            for k = 1:numel(rCM)
                tic
                Simulink.sdi.clear
                h = 30*pi/180;  w = 90*pi/180;                             %   rad - Path width/height
                [a,b] = boothParamConversion(w,h);                          %   Path basis parameters
                %%  Load components
                el = elevArray;
                if q ~= 3
                    %             loadComponent('exp_slCtrl');
                    loadComponent('periodicCtrlExp');
                    %             fltCtrl.ctrlOff.setValue(0,'')
                    FLIGHTCONTROLLER = 'periodicCtrlExp';
                else%
                    loadComponent('pathFollowCtrlExp');                         %   Path-following controller with AoA control
                    FLIGHTCONTROLLER = 'pathFollowingControllerExp';
                end
                loadComponent('oneDoFGSCtrlBasic');                         %   Ground station controller                           %   Ground station
                loadComponent('raftGroundStation');
                loadComponent('winchManta');                                %   Winches
                loadComponent('MantaTether');                               %   Manta Ray tether
                loadComponent('realisticSensors');                             %   Sensors
                loadComponent('lineAngleSensor');
                loadComponent('idealSensorProcessing');                      %   Sensor processing
                loadComponent('poolScaleKiteAbney');                %   AR = 8; 8m span
                SIXDOFDYNAMICS        = "sixDoFDynamicsCoupledFossen12int";
                %%  Environment Properties
                loadComponent('ConstXYZT');                                 %   Environment
                %                 loadComponent('CNAPsTurbJames');
                env.water.setflowVec([flwSpd 0 0],'m/s');                   %   m/s - Flow speed vector
                ENVIRONMENT = 'environmentManta2RotBandLin';            %   Two turbines
                %%  Set basis parameters for high level controller
               
                loadComponent('constBoothLem');        %   High level controller
                % PATHGEOMETRY = 'lemOfBoothInv'
                hiLvlCtrl.basisParams.setValue([a,b,-el,180*pi/180,thrLength-.1],'[rad rad rad rad m]') % Lemniscate of Booth
                las.setThrInitAng([-el 0],'rad');
                las.setInitAngVel([-0 0],'rad/s');
                %             las.tetherLoadDisable;
                %             las.dragDisable;
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
                initGndStnPos = [x_init;y_init;0];
                thrAttachInit = initGndStnPos;
                %%  Vehicle Properties
                vhcl.stbdWing.setGainCL(vhcl.stbdWing.gainCL.Value/8,'1/deg');
                vhcl.portWing.setGainCL(vhcl.portWing.gainCL.Value/8,'1/deg');
                vhcl.stbdWing.setGainCD(vhcl.stbdWing.gainCD.Value/8,'1/deg');
                vhcl.portWing.setGainCD(vhcl.portWing.gainCD.Value/8,'1/deg');
                vhcl.vStab.setGainCL(vhcl.vStab.gainCL.Value/2,'1/deg');
                vhcl.vStab.setGainCD(vhcl.vStab.gainCD.Value/2,'1/deg');
                if q == 3
                    vhcl.setICsOnPath(.05,PATHGEOMETRY,hiLvlCtrl.basisParams.Value,initGndStnPos,6.5*abs(flwSpd)*norm([1;0;0]))
                else
                    vhcl.setICsOnPath(0.0,PATHGEOMETRY,hiLvlCtrl.basisParams.Value,initGndStnPos,0);
                    vhcl.setInitEulAng([180 0 180]*pi/180,'rad');
                    %             vhcl.setInitEulAng([180 0 0]*pi/180,'rad');
                    vhcl.setInitVelVecBdy([0 0 0],'m/s');
                end
               
                %%  Tethers Properties
                load([fileparts(which('OCTProject.prj')),'\vehicleDesign\Tether\tetherDataNew.mat']);
                thr.tether1.initGndNodePos.setValue(thrAttachInit,'m');
                thr.tether1.initAirNodePos.setValue(vhcl.initPosVecGnd.Value(:)...
                    +rotation_sequence(vhcl.initEulAng.Value)*vhcl.thrAttchPts_B.posVec.Value,'m');
                x = thr.tether1.initGndNodePos.Value(1)-thr.tether1.initAirNodePos.Value(1);
                y = thr.tether1.initGndNodePos.Value(2)-thr.tether1.initAirNodePos.Value(2);
                z = thr.tether1.initGndNodePos.Value(3)-thr.tether1.initAirNodePos.Value(3);
                initThrAng = atan2(z,sqrt(x^2+y^2));
               
                las.setThrInitAng([-initThrAng 0],'rad');
                thr.tether1.initGndNodeVel.setValue([0 0 0]','m/s');
                thr.tether1.initAirNodeVel.setValue(vhcl.initVelVecBdy.Value(:),'m/s');
                thr.tether1.vehicleMass.setValue(vhcl.mass.Value,'kg');
                thr.tether1.youngsMod.setValue(50e9,'Pa');
                thr.tether1.density.setValue(1000,'kg/m^3');
                thr.tether1.setDiameter(.0076,'m');
                thr.setNumNodes(4,'');
                thr.tether1.setDragCoeff(1.8,'');
                %%  Winches Properties
                wnch.setTetherInitLength(vhcl,thrAttachInit,env,thr,env.water.flowVec.Value);
                wnch.winch1.LaRspeed.setValue(1,'m/s');
                %%  Controller User Def. Parameters and dependant properties
                fltCtrl.setFcnName(PATHGEOMETRY,'');
                fltCtrl.setInitPathVar(vhcl.initPosVecGnd.Value,hiLvlCtrl.basisParams.Value,thrAttachInit);
                fltCtrl.setPerpErrorVal(.4,'rad')
                fltCtrl.rudderGain.setValue(0,'')
                fltCtrl.rollMoment.kp.setValue(45/3,'(N*m)/(rad)')
                fltCtrl.rollMoment.ki.setValue(0,'(N*m)/(rad*s)');
                fltCtrl.rollMoment.kd.setValue(25/3,'(N*m)/(rad/s)')
                fltCtrl.tanRoll.kp.setValue(.25,'(rad)/(rad)')
                thr.tether1.dragEnable.setValue(1,'')
                vhcl.hStab.setIncidence(0,'deg');
                if q == 3
                    vhcl.hStab.setIncidence(-3,'deg');
                end
                if q ~= 3
                    %                     693
                    fltCtrl.rollAmp.setValue(60,'deg');
                    fltCtrl.yawAmp.setValue(70,'deg');
                    fltCtrl.period.setValue(7.5,'s');
                    fltCtrl.rollPhase.setValue(pi-pi,'rad');
                    fltCtrl.yawPhase.setValue(.693-pi,'rad');
                    if q == 1
                        fltCtrl.startCtrl.setValue(42,'s')
                    else
                        fltCtrl.startCtrl.setValue(1,'s')
                        %                         launchTime = 3.5;
                    end
                   
                   
                    fltCtrl.rollCtrl.kp.setValue(.3/.7,'(deg)/(deg)');
                    fltCtrl.rollCtrl.ki.setValue(0,'(deg)/(deg*s)');
                    fltCtrl.rollCtrl.kd.setValue(.1/.9,'(deg)/(deg/s)');
                    fltCtrl.rollCtrl.tau.setValue(0.02,'s');
                   
                   
                   
                   
                    fltCtrl.yawCtrl.kp.setValue(.1/.7,'(deg)/(deg)');
                    fltCtrl.yawCtrl.ki.setValue(0,'(deg)/(deg*s)');
                    fltCtrl.yawCtrl.kd.setValue(.07/.7 ,'(deg)/(deg/s)');
                    fltCtrl.yawCtrl.tau.setValue(0.02,'s');
                   
                    fltCtrl.ccElevator.setValue(-3.5,'deg');
                    fltCtrl.trimElevator.setValue(inc(i),'deg');
                   
                end
                %                  FLIGHTCONTROLLER = 'periodicCtrlExpTran1';
               
               fluidDensity  = 1000;
                endTime = 25;
                towPer = .1*.33;
                towAmp = 0*.0098;%%  Set up critical system parameters and run simulation
                simParams = SIM.simParams;  simParams.setDuration(end_time,'s');  dynamicCalc = '';
                %                     open_system('OCTModel')
               
                set_param('OCTModel','SimulationMode','accelerator');
                simWithMonitor('OCTModel')
                tsc = signalcontainer(logsout);
               
               
            end
            toc
        end
    end
end
vhcl.animateSim(tsc,0.2)

plotVelMags
