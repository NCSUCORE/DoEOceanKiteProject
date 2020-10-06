%% Test script for John to control the kite model
Simulink.sdi.clear
clear;clc;%close all
%%  Select sim scenario
simScenario = 1.5;
%%  Set Test Parameters
saveSim = 1;                                                %   Flag to save results
thrLength = 400:25:600;                                            %   m - Initial tether length
flwSpd = 0.25:0.025:0.5;                              %   m/s - Flow speed
el = (20:2.5:50)*pi/180;                                             %   rad - Mean elevation angle
h = 10*pi/180;  w = 40*pi/180;                              %   rad - Path width/height
[a,b] = boothParamConversion(w,h);                          %   Path basis parameters
for kk = 1:numel(flwSpd)
    for ii = 1:numel(thrLength)
        for jj = 1:numel(el)
            Simulink.sdi.clear
            %%  Load components
            loadComponent('pathFollowingCtrlForManta');             %   Path-following controller
            loadComponent('oneDoFGSCtrlBasic');                         %   Ground station controller
            loadComponent('MantaGndStn');                               %   Ground station
            loadComponent('winchManta');                                %   Winches
            loadComponent('MantaTether');                           %   Single link tether
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
                loadComponent('Manta2RotXFlr_CFD');                              %   Manta kite with XFlr5
            elseif simScenario == 1.5 || simScenario == 3.5 || simScenario == 4.5
                loadComponent('Manta2RotXFoil_AR8_b8');                                 %   Manta kite with XFlr5
            elseif simScenario == 1.6 || simScenario == 3.6 || simScenario == 4.6
                loadComponent('Manta2RotXFoil_AR9_b8');                                 %   Manta kite with XFlr5
            elseif simScenario == 1.7 || simScenario == 3.7 || simScenario == 4.7
                loadComponent('Manta2RotXFoil_AR9_b9');                                 %   Manta kite with XFlr5
            elseif simScenario == 1.8 || simScenario == 3.8 || simScenario == 4.8
                loadComponent('Manta2RotXFoil_AR9_b10');                                %   Manta kite with XFlr5
            elseif simScenario == 1.8 || simScenario == 3.8 || simScenario == 4.8
                loadComponent('Manta2RotXFoil_AR7_b8');                                 %   Manta kite with XFlr5
            end
            %%  Environment Properties
            loadComponent('ConstXYZT');                                 %   Environment
            env.water.setflowVec([flwSpd(kk) 0 0],'m/s');               %   m/s - Flow speed vector
            if simScenario == 0
                ENVIRONMENT = 'environmentManta';                       %   Single turbine
            elseif simScenario == 2
                ENVIRONMENT = 'environmentDOE';                         %   No turbines
            else
                ENVIRONMENT = 'environmentManta2Rot';                   %   Two turbines
            end
            %%  Set basis parameters for high level controller
            loadComponent('constBoothLem');                             %   High level controller
            hiLvlCtrl.basisParams.setValue([a,b,el(jj),0*pi/180,thrLength(ii)],'[rad rad rad rad m]') % Lemniscate of Booth
            %%  Ground Station Properties
            %%  Vehicle Properties
            vhcl.setICsOnPath(.05,PATHGEOMETRY,hiLvlCtrl.basisParams.Value,gndStn.posVec.Value,6.5*flwSpd(kk)*norm([1;0;0]))
            %%  Tethers Properties
            thr.tether1.initGndNodePos.setValue(gndStn.thrAttch1.posVec.Value(:)+gndStn.posVec.Value(:),'m');
            thr.tether1.initAirNodePos.setValue(vhcl.initPosVecGnd.Value(:)...
                +rotation_sequence(vhcl.initEulAng.Value)*vhcl.thrAttchPts_B.posVec.Value,'m');
            thr.tether1.initGndNodeVel.setValue([0 0 0]','m/s');
            thr.tether1.initAirNodeVel.setValue(vhcl.initVelVecBdy.Value(:),'m/s');
            thr.tether1.vehicleMass.setValue(vhcl.mass.Value,'kg');
            thr.tether1.setDensity(env.water.density.Value,thr.tether1.density.Unit);
            thr.tether1.setDiameter(0.0109,thr.tether1.diameter.Unit);
            thr.tether1.setYoungsMod(thr.tether1.youngsMod.Value*1.2,thr.tether1.youngsMod.Unit);
            thr.tether1.dragCoeff.setValue(1,'');
            %%  Winches Properties
            wnch.setTetherInitLength(vhcl,gndStn.posVec.Value,env,thr,env.water.flowVec.Value);
            wnch.winch1.LaRspeed.setValue(1,'m/s');
            %%  Controller User Def. Parameters and dependant properties
            fltCtrl.setFcnName(PATHGEOMETRY,'');
            fltCtrl.setInitPathVar(vhcl.initPosVecGnd.Value,hiLvlCtrl.basisParams.Value,gndStn.posVec.Value);
            fltCtrl.rudderGain.setValue(0,'')
            thr.tether1.dragEnable.setValue(1,'');
            fltCtrl.setElevatorReelInDef(-.25,'deg')
            %%  Set up critical system parameters and run simulation
            fprintf('Flow Speed = %.3f m/s;\tTether Length = %.1f m;\t Elevation = %.1f deg\n',flwSpd(kk),thrLength(ii),el(jj)*180/pi);
            simParams = SIM.simParams;  simParams.setDuration(2000,'s');  dynamicCalc = '';
            simWithMonitor('OCTModel')
            %%  Log Results
            tsc = signalcontainer(logsout);
            dt = datestr(now,'mm-dd_HH-MM');
            filename = sprintf(strcat('Turb%.1f_V-%.3f_thrL-%d_el-%d.mat'),simScenario,flwSpd(kk),thrLength(ii),el(jj)*180/pi);
            fpath = 'D:\Results\';
            if saveSim == 1
                save(strcat(fpath,filename),'tsc','vhcl','thr','fltCtrl','env','simParams','LIBRARY','gndStn')
            end
            [Idx1,Idx2] = tsc.getLapIdxs(max(tsc.lapNumS.Data)-1);  ran = Idx1:Idx2;
            [CLtot,CDtot] = tsc.getCLCD(vhcl);
            [Lift,Drag,Fuse,Thr] = tsc.getLiftDrag;
            Turb = squeeze(sqrt(sum(tsc.FTurbBdy.Data.^2,1)));
            Pow = tsc.rotPowerSummary(vhcl,env);
            Pavg(ii,jj,kk) = Pow.avg;
            AoA(ii,jj,kk) = mean(squeeze(tsc.vhclAngleOfAttack.Data(:,:,ran)));
            fprintf('Average AoA = %.2f \n',AoA(ii,jj,kk));
            CL(ii,jj,kk) = mean(CLtot(ran));   CD(ii,jj,kk) = mean(CDtot(ran));
            Fdrag(ii,jj,kk) = mean(Drag(ran)); Flift(ii,jj,kk) = mean(Lift(ran));
            Ffuse(ii,jj,kk) = mean(Fuse(ran)); Fthr(ii,jj,kk) = mean(Thr(ran));   Fturb(ii,jj,kk) = mean(Turb(ran));
            Depth(ii,jj,kk) = 500-mean(tsc.positionVec.Data(3,1,ran));
        end
    end
end
%% 
filename1 = 'Elevation_TetherLength_Study_1-5.mat';
fpath1 = fullfile(fileparts(which('OCTProject.prj')),'output','Depth Study\');
elevation = el*180/pi;
save([fpath1,filename1],'Pavg','AoA','CL','CD','Fdrag','Flift','Ffuse','Fthr','Fturb','thrLength','elevation','Depth','flwSpd')
