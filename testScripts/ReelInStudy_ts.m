%% Test script for John to control the kite model
Simulink.sdi.clear
clear;clc;%close all
%%  Select sim scenario
simScenario = 1.3;
%%  Set Test Parameters
fpath2 = fullfile(fileparts(which('OCTProject.prj')),'vehicleDesign','Tether\');  load([fpath2 'tetherDataNew.mat']);
saveSim = 1;                                                %   Flag to save results
Tmax = 38;
thrLength = 400;  altitude = 200;                           %   m - Initial tether length/operating altitude
flwSpd = 0.15:0.05:0.5;                                     %   m/s - Flow speed
Vs = 0.01:0.02:0.25;
A = 14:-2:2;
h = 10*pi/180;  w = 40*pi/180;                              %   rad - Path width/height
[a,b] = boothParamConversion(w,h);                          %   Path basis parameters
%%
tic
for ii = 1:numel(flwSpd)
    for jj = 1:numel(Vs)
        for kk = 1:numel(A)
            eff = eval(sprintf('AR8b8.length600.tensionValues%d.efficencyPercent',Tmax))/100;
            TDiam = eval(sprintf('AR8b8.length600.tensionValues%d.outerDiam',Tmax));
            young = eval(sprintf('AR8b8.length600.tensionValues%d.youngsMod',Tmax));
            fpath = fullfile(fileparts(which('OCTProject.prj')),'vehicleDesign\Tether\Tension\');
            maxT = load([fpath,sprintf('TmaxStudy_%dkN.mat',Tmax)]);
            thrLength = interp2(maxT.altitude,maxT.flwSpd,maxT.R.thrL,altitude,flwSpd(ii));
            el = interp2(maxT.altitude,maxT.flwSpd,maxT.R.EL,altitude,flwSpd(ii))*pi/180;
            Simulink.sdi.clear
            %%  Load components
            loadComponent('pathFollowWithAoACtrl');                 %   Path-following controller with AoA control
            loadComponent('oneDoFGSCtrlBasic');                         %   Ground station controller
            loadComponent('MantaGndStn');                               %   Ground station
            loadComponent('winchManta');                                %   Winches
            loadComponent('MantaTether');                          %   Single link tether
            loadComponent('idealSensors')                               %   Sensors
            loadComponent('idealSensorProcessing')                      %   Sensor processing
            if simScenario == 0
                loadComponent('Manta2RotXFoil_AR8_b8');                             %   AR = 8; 8m span
            elseif simScenario == 2
                loadComponent('fullScale1thr');                                     %   DOE kite
            elseif simScenario == 1 || simScenario == 3 || simScenario == 4
                loadComponent('Manta2RotXFoil_AR8_b8');                             %   AR = 8; 8m span
            elseif simScenario == 1.1 || simScenario == 3.1 || simScenario == 4.1
                loadComponent('Manta2RotXFoil_AR9_b9');                             %   AR = 9; 9m span
            elseif simScenario == 1.2 || simScenario == 3.2 || simScenario == 4.2
                loadComponent('Manta2RotXFoil_AR9_b10');                            %   AR = 9; 10m span
            elseif simScenario == 1.3 || simScenario == 3.3 || simScenario == 4.3
                loadComponent('Manta2RotXFoil_AR8_b8');                             %   AR = 8; 8m span
            elseif simScenario == 1.4 || simScenario == 3.4 || simScenario == 4.4
                error('Kite doesn''t exist for simScenario %.1f\n',simScenario)
            elseif simScenario == 1.5 || simScenario == 3.5 || simScenario == 4.5
                error('Kite doesn''t exist for simScenario %.1f\n',simScenario)
            elseif simScenario == 1.6 || simScenario == 3.6 || simScenario == 4.6
                error('Kite doesn''t exist for simScenario %.1f\n',simScenario)
            elseif simScenario == 1.7 || simScenario == 3.7 || simScenario == 4.7
                error('Kite doesn''t exist for simScenario %.1f\n',simScenario)
            elseif simScenario == 1.8 || simScenario == 3.8 || simScenario == 4.8
                error('Kite doesn''t exist for simScenario %.1f\n',simScenario)
            elseif simScenario == 1.9 || simScenario == 3.9 || simScenario == 4.9
                error('Kite doesn''t exist for simScenario %.1f\n',simScenario)
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
            loadComponent('varAltitudeBooth');                             %   High level controller
            hiLvlCtrl.elevationLookup.setValue(maxT.R.EL,'deg');
            hiLvlCtrl.ELctrl.setValue(1,'');
            hiLvlCtrl.ELslew.setValue(0.25,'deg/s');
            hiLvlCtrl.ThrCtrl.setValue(1,'');
            hiLvlCtrl.basisParams.setValue([a,b,el,0*pi/180,thrLength],'[rad rad rad rad m]') % Lemniscate of Booth
            %%  Ground Station Properties
            %%  Vehicle Properties
            vhcl.setICsOnPath(.05,PATHGEOMETRY,hiLvlCtrl.basisParams.Value,gndStn.posVec.Value,6.5*flwSpd(ii)*norm([1;0;0]))
            %%  Tethers Properties
            thr.tether1.initGndNodePos.setValue(gndStn.thrAttch1.posVec.Value(:)+gndStn.posVec.Value(:),'m');
            thr.tether1.initAirNodePos.setValue(vhcl.initPosVecGnd.Value(:)...
                +rotation_sequence(vhcl.initEulAng.Value)*vhcl.thrAttchPts_B.posVec.Value,'m');
            thr.tether1.initGndNodeVel.setValue([0 0 0]','m/s');
            thr.tether1.initAirNodeVel.setValue(vhcl.initVelVecBdy.Value(:),'m/s');
            thr.tether1.vehicleMass.setValue(vhcl.mass.Value,'kg');
            thr.tether1.density.setValue(eval(sprintf('AR8b8.length600.tensionValues%d.density',Tmax)),'kg/m^3');
            thr.tether1.setDiameter(TDiam,thr.tether1.diameter.Unit);
            thr.tether1.setYoungsMod(young,thr.tether1.youngsMod.Unit);
            thr.tether1.dragCoeff.setValue(1,'');
            %%  Winches Properties
            wnch.setTetherInitLength(vhcl,gndStn.posVec.Value,env,thr,env.water.flowVec.Value);
            %%  Controller User Def. Parameters and dependant properties
            fltCtrl.setFcnName(PATHGEOMETRY,'');
            fltCtrl.setInitPathVar(vhcl.initPosVecGnd.Value,hiLvlCtrl.basisParams.Value,gndStn.posVec.Value);
            fltCtrl.rudderGain.setValue(0,'')
            thr.tether1.dragEnable.setValue(1,'');
            fltCtrl.AoACtrl.setValue(1,'');                     fltCtrl.AoASP.setValue(1,'');
            fltCtrl.AoAConst.setValue(A(kk)*pi/180,'deg');
            fltCtrl.alphaCtrl.kp.setValue(.3,'(kN)/(rad)');     fltCtrl.Tmax.setValue(Tmax,'kN');
            fltCtrl.elevCtrl.kp.setValue(200,'(deg)/(rad)');    fltCtrl.elevCtrl.ki.setValue(1,'(deg)/(rad*s)');            %%  Set up critical system parameters and run simulation
            fprintf('\nFlow Speed = %.3f m/s;\tReel-in Speed = %.3f m/s;\t AoA = %d deg\n',flwSpd(ii),-Vs(jj),A(kk));
            vhcl.setBuoyFactor(getBuoyancyFactor(vhcl,env,thr),'');
            fltCtrl.firstSpoolLap.setValue(2,'');   fltCtrl.winchSpeedIn.setValue(-Vs(jj),'m/s');
            %%  Simulate 
            simParams = SIM.simParams;  simParams.setDuration(6000,'s');  dynamicCalc = '';
            simWithMonitor('OCTModel')
            %%  Log Results
            tsc = signalcontainer(logsout);
            dt = datestr(now,'mm-dd_HH-MM');
            [Idx1,Idx2] = tsc.getLapIdxs(max(tsc.lapNumS.Data)-1);  ran = Idx1:Idx2;
            [CLtot,CDtot] = tsc.getCLCD(vhcl);
            [Lift,Drag,Fuse,Thr] = tsc.getLiftDrag;
            Turb = squeeze(sqrt(sum(tsc.FTurbBdy.Data.^2,1)));
            Pow = tsc.rotPowerSummary(vhcl,env);
            Pavg(ii,jj,kk) = Pow.avg;    Pwnch(ii,jj,kk) = Pow.wnch;
            Pnet(ii,jj,kk) = Pow.avg*eff+Pwnch;
            AoA(ii,jj,kk) = mean(squeeze(tsc.vhclAngleOfAttack.Data(:,:,ran)));
            airNode = squeeze(sqrt(sum(tsc.airTenVecs.Data.^2,1)))*1e-3;
            gndNode = squeeze(sqrt(sum(tsc.gndNodeTenVecs.Data.^2,1)))*1e-3;
            ten(ii,jj,kk) = max([max(airNode(ran)) max(gndNode(ran))]);
            fprintf('Average AoA = %.3f;\t Max Tension = %.1f kN;\t Elevation = %.1f\n',AoA(ii,jj,kk),ten(ii,jj,kk),el*180/pi);
            CL(ii,jj,kk) = mean(CLtot(ran));   CD(ii,jj,kk) = mean(CDtot(ran));
            Fdrag(ii,jj,kk) = mean(Drag(ran)); Flift(ii,jj,kk) = mean(Lift(ran));
            Ffuse(ii,jj,kk) = mean(Fuse(ran)); Fthr(ii,jj,kk) = mean(Thr(ran));   Fturb(ii,jj,kk) = mean(Turb(ran));
            elevation(ii,jj,kk) = el*180/pi;
            filename = sprintf(strcat('Turb%.1f_V-%.3f_EL-%.1f_Vs-%.2f_AoA-%d.mat'),simScenario,flwSpd(ii),mean(tsc.basisParams.Data(3,:,:))*180/pi,Vs(jj),A(ll));
            fpath = 'D:\Results2\';
        end
    end
end
filename1 = sprintf('ReelIn_Study.mat');
fpath1 = fullfile(fileparts(which('OCTProject.prj')),'output\');
save([fpath1,filename1],'Pavg','Pwnch','Pnet','AoA','CL','CD','Fdrag','Flift','Ffuse','Fthr',...
    'Fturb','thrLength','elevation','flwSpd','ten','Tmax','altitude','ii','jj','kk')
toc
%%
% filename1 = sprintf('Tmax_Study_AR8b8.mat');
% fpath1 = fullfile(fileparts(which('OCTProject.prj')),'output','Tmax Study\');
% save([fpath1,filename1],'Pavg','AoA','CL','CD','Fdrag','Flift','Ffuse','Fthr',...
%     'Fturb','thrLength','elevation','flwSpd','ten','Tmax','altitude','ii','jj','ll','kk')
