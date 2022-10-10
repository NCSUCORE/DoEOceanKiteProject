%% Test script for James to control the kite model
clear;clc;close all;
Simulink.sdi.clear

%%  Set Test Parameters

thrArray = 7.5;

flwSpdArray = 1.5; %[1,1.25,1.5,1.75,2];
spoolInPerc = 0.35; %[.1,.15,.2,.25,.3,.375];
spoolOutPerc =.1; %[.1,.125,.15,.175,.2,.225,.25,.275,.3,.33];


for q = 1 :length(spoolOutPerc)
    for j = 1:length(spoolInPerc)
        for k = 1:length(flwSpdArray)
            thrLength = 7.1;            %   Initial tether length/operating altitude/elevation angle
            flwSpd = flwSpdArray(k) ;                                              %   m/s - Flow speed
            
            %%  Load components
            
            
            loadComponent('joshMultiCycleExp');                 %   Path-following controller with AoA control
            
            fltCtrl.ilcTrig.setValue(0,'');
            fltCtrl.ccElevator.setValue(-4,'deg')
            
            FLIGHTCONTROLLER = 'takeOffToLanding';
            loadComponent('oneDoFGSCtrlBasic');                         %   Ground station controller
            loadComponent('pathFollowingGndStn');
            loadComponent('oneDOFWnch');                                %   Winches
            loadComponent('poolTether');                               %   Manta Ray tether
            loadComponent('idealSensors')
%                     loadComponent('lasPosEst')
%                     loadComponent('lineAngleSensor');%   Sensors
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
            
            a = 6.5;
            b = 2.5;
            
            hiLvlCtrl.basisParams.setValue([a,b,deg2rad(25),0,thrLength],'[rad rad rad rad m]') % Lemniscate of Booth
            
            %%  Ground Station Properties
            gndStn.posVec.setValue([0 0 0],'m')
            %%  Vehicle Properties
            % vhcl.setICsOnPath(.85,PATHGEOMETRY,hiLvlCtrl.basisParams.Value,gndStn.posVec.Value,6.5*flwSpd*norm([1;0;0]))
            %         vhcl.initPosVecGnd.setValue([0;0;thrLength],'m')
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
            %% LAS
%                     pos = vhcl.initPosVecGnd.Value;
%                     x = pos(1);
%                     y = pos(2);
%                     z = pos(3);
%                     az1 = atan2(y,x);
%                     el1 = atan2(z,sqrt(x.^2 + y.^2));
%                     las.setThrInitAng([el1 az1],'rad');
%                     las.setInitAngVel([-0 0],'rad/s');
            %%  Winches Properties
            wnch.setTetherInitLength(vhcl,gndStn.posVec.Value,env,thr,env.water.flowVec.Value);
            wnch.winch1.LaRspeed.setValue(1,'m/s');
            %%  Controller User Def. Parameters and dependant properties
            fltCtrl.setFcnName(PATHGEOMETRY,'');
            fltCtrl.setInitPathVar(vhcl.initPosVecGnd.Value,hiLvlCtrl.basisParams.Value,gndStn.posVec.Value);
            %         fltCtrl.setPerpErrorVal(.25,'rad')
            thr.tether1.dragEnable.setValue(1,'')
            
            
            fltCtrl.initPathVar.setValue(0,'')
            
            %% Start Control
            flowSpeedOpenLoop = .03;
            
            %% degredations
            vhcl.stbdWing.setGainCL(vhcl.stbdWing.gainCL.Value/8,'1/deg');
            vhcl.portWing.setGainCL(vhcl.portWing.gainCL.Value/8,'1/deg');
            vhcl.stbdWing.setGainCD(vhcl.stbdWing.gainCD.Value/8,'1/deg');
            vhcl.portWing.setGainCD(vhcl.portWing.gainCD.Value/8,'1/deg');
            vhcl.vStab.setCL(vhcl.vStab.CL.Value/1,'');
            vhcl.vStab.setCD(vhcl.vStab.CD.Value/1,'');
            
            
            thr.tether1.youngsMod.setValue(10e9,'Pa');
            %%
            
%             ilcKp1 = .5;
%             ilcKp2 = .5;
%             ilcKp3 = .5;
%             ilcKp4 = .5;
%             
%             ilcKi1 = .1;
%             ilcKi2 = .1;
%             ilcKi3 = .1;
%             ilcKi4 = .1;
            
%             forgettingFactor = .95;
%             initBasisParams = [50,70,.4,0,0];
%             learningGain =3;
%             enableVec = [1 1 1,0,0];
%             trustRegion = [ 5,5,.1,inf,inf];
%             time23 = 10;
%             time41 = 10;
%             ilcTrig = 0;
%             tWait = 10;
            
            fltCtrl.vSat.setValue(spoolOutPerc(q),''); %spool out speed (.15)
            fltCtrl.sIM.setValue(spoolInPerc(j),''); %spool in speed (.3)
            
            fltCtrl.rollAmp.setValue(50,'deg')
            fltCtrl.yawAmp.setValue(70,'deg')
            fltCtrl.yawPhase.setValue(0,'rad')
            fltCtrl.period.setValue(7,'s')
            
            
            %%  Set up critical system parameters and run simulation
            simParams = SIM.simParams;  simParams.setDuration(300,'s');  dynamicCalc = '';
            simWithMonitor('OCTModel')
            tsc = signalcontainer(logsout);
            
         
        end
    end
end



vhcl.animateSim(tsc,.7,...
    'PlotTracer',true,'FontSize',18,'starttime',200,'endtime',800,'SaveGif',1==1,'GifTimeStep',.01)





