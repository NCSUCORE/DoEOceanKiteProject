function [tsc] = testScriptRunner
clear;clc;close all;
Simulink.sdi.clear
warning('off')
%%  Set Test Parameters
thrArray = 7.5;
flwSpdArray = [2]; %[1,1.25,1.5,1.75,2];
spoolInPerc =[.4]; %[.1,.15,.2,.25,.3,.375];
spoolOutPerc =.1; %[.1,.125,.15,.175,.2,.225,.25,.275,.3,.33];
rollAmpMat = [56];
for gg = 1:length(rollAmpMat)
for q = 1 :length(spoolOutPerc)
    for j = 1:length(spoolInPerc)
        for k = 1:length(flwSpdArray)
            thrLength = 7.1;            %   Initial tether length/operating altitude/elevation angle
            flwSpd = flwSpdArray(k) ;                                              %   m/s - Flow speed
            %%  Load components
            loadComponent('jamesMultiCycleExp');                 %   Path-following controller with AoA control
            FLIGHTCONTROLLER = 'takeOffToLanding';
            loadComponent('oneDoFGSCtrlBasic');                         %   Ground station controller
            loadComponent('pathFollowingGndStn');
            loadComponent('oneDOFWnch');                                %   Winches
            loadComponent('poolTether');                               %   Manta Ray tether
            loadComponent('idealSensors')

            loadComponent('idealSensorProcessing')                      %   Sensor processing
            loadComponent('poolScaleKiteAbneyRefined');                %   AR = 8; 8m span
            SIXDOFDYNAMICS        = "sixDoFDynamicsCoupledFossen12Int";
            %%  Environment Properties
            loadComponent('ConstXYZT');                                 %   Environment
            env.water.setflowVec([flwSpd 0 0],'m/s');               %   m/s - Flow speed vector
            ENVIRONMENT = 'env2turb';                   %   Two turbines
            FLOWCALCULATION = 'rampSaturatedXYZT';
            rampSlope = .05; %flow speed ramp rate
            %%  Set basis parameters for high level controller
            loadComponent('constBoothLem');        %   High level controller
            PATHGEOMETRY = 'lemBoothNew';
            %%  Ground Station Properties
            gndStn.posVec.setValue([0 0 0],'m')
            %%  Vehicle Properties
            vhcl.initPosVecGnd.setValue([cos(70*(pi/180)) 0 sin(70*(pi/180))]*thrLength,'m')
            vhcl.initAngVelVec.setValue([0;0;0],'rad/s')
            vhcl.initVelVecBdy.setValue([0;0;0],'m/s')
            vhcl.initEulAng.setValue([0;0;0],'rad')
            %%  Tethers Properties
            load([fileparts(which('OCTProject.prj')),'\vehicleDesign\Tether\tetherDataNew.mat']);
            thr.tether1.initGndNodePos.setValue(gndStn.thrAttch1.posVec.Value(:)+gndStn.posVec.Value(:),'m');
            thr.tether1.initAirNodePos.setValue(vhcl.initPosVecGnd.Value(:)...
                +rotation_sequence(vhcl.initEulAng.Value)*vhcl.thrAttchPts_B.posVec.Value,'m');
            thr.tether1.initGndNodeVel.setValue([0 0 0]','m/s');
            thr.tether1.initAirNodeVel.setValue(vhcl.initVelVecBdy.Value(:),'m/s');
            thr.tether1.vehicleMass.setValue(vhcl.mass.Value,'kg');
            thr.tether1.setDiameter(.0076,'m');
            thr.setNumNodes(4,'');
            thrDrag =   1.8;
            thr.tether1.setDragCoeff(thrDrag,'');
            thr.tether1.netBuoyEnable.setValue(0,'');
            thr.tether1.dragEnable.setValue(1,'')
            %%  Winches Properties
            wnch.setTetherInitLength(vhcl,gndStn.posVec.Value,env,thr,env.water.flowVec.Value);
            wnch.winch1.LaRspeed.setValue(1,'m/s');
            %%  Controller User Def. Parameters and dependant properties
            fltCtrl.setFcnName(PATHGEOMETRY,'');
            fltCtrl.setInitPathVar(vhcl.initPosVecGnd.Value,hiLvlCtrl.basisParams.Value,gndStn.posVec.Value);
            thr.tether1.dragEnable.setValue(1,'')
            fltCtrl.initPathVar.setValue(0,'')
            
            %% Start Control
            flowSpeedOpenLoop = .03;
            
            %% degredations
            vhcl.stbdWing.setGainCL(vhcl.stbdWing.gainCL.Value/16,'1/deg');
            vhcl.portWing.setGainCL(vhcl.portWing.gainCL.Value/16,'1/deg');
            vhcl.stbdWing.setGainCD(vhcl.stbdWing.gainCD.Value/16,'1/deg');
            vhcl.portWing.setGainCD(vhcl.portWing.gainCD.Value/16,'1/deg');
            vhcl.vStab.setCL(vhcl.vStab.CL.Value/5,'')   
            vhcl.vStab.setCD(vhcl.vStab.CD.Value,'') 
            thr.tether1.youngsMod.setValue(10e9,'Pa');
  
            %% Control Parameters
            fltCtrl.vSat.setValue(spoolOutPerc(q),''); %spool out speed (.15)
            fltCtrl.sIM.setValue(spoolInPerc(j),''); %spool in speed (.3)
            fltCtrl.rollAmp.setValue(rollAmpMat(gg),'deg')
            fltCtrl.yawAmp.setValue(90,'deg')
            fltCtrl.yawPhase.setValue(0,'rad')
            fltCtrl.period.setValue(5.75,'s')
            rollBias = 0;
            yawBias = 0;
            fltCtrl.ccElevator.setValue(-4,'deg')
            
            %%  Set up critical system parameters and run simulation
            simParams = SIM.simParams;  simParams.setDuration(800,'s');  dynamicCalc = '';
            simWithMonitor('OCTModel')
            tsc = signalcontainer(logsout);
         
        end
    end
end
end
end

