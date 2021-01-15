%% Test script for John to control the kite model
Simulink.sdi.clear
clear;clc;%close all
%%  Select sim scenario
simScenario = 1.5;
%%  Set Test Parameters
fpath2 = fullfile(fileparts(which('OCTProject.prj')),'vehicleDesign','Tether\');  load([fpath2 'tetherDataNew.mat']);
saveSim = 0;                                                %   Flag to save results
thrLength = 400;                                            %   m - Initial tether length
flwSpd = .315;                                              %   m/s - Flow speed
Tmax = 29;
D = 0.6:.025:0.8;
ThrD = .01;
el = 30*pi/180;                                             %   rad - Mean elevation angle
h = 10*pi/180;  w = 40*pi/180;                              %   rad - Path width/height
[a,b] = boothParamConversion(w,h);                          %   Path basis parameters
for kk = 1:numel(flwSpd)
    for ii = 1:numel(D)
        Simulink.sdi.clear
        eff = eval(sprintf('AR8b8.length600.tensionValues%d.efficencyPercent',Tmax))/100;
        TDiam = .01;
        young = eval(sprintf('AR8b8.length600.tensionValues%d.youngsMod',Tmax));
        fpath = fullfile(fileparts(which('OCTProject.prj')),'vehicleDesign\Tether\Tension\');
        maxT = load([fpath,sprintf('TmaxStudy_%dkN.mat',Tmax)]);
        %%  Load components
        loadComponent('pathFollowWithAoACtrl');                 %   Path-following controller with AoA control
        loadComponent('oneDoFGSCtrlBasic');                         %   Ground station controller
        loadComponent('MantaGndStn');                               %   Ground station
        loadComponent('winchManta');                                %   Winches
        if simScenario >= 4
            loadComponent('shortTether');                           %   Tether for reeling
            thr.tether1.setInitTetherLength(thrLength,'m');
        else
            loadComponent('MantaTether');                           %   Single link tether
        end
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
            loadComponent('Manta2RotXFoil_AR8_b8');                             %   AR = 8; 8m span
        elseif simScenario == 1.5 || simScenario == 3.5 || simScenario == 4.5
            loadComponent('Manta2RotXFoil_PDR');                                %   AR = 8; 8m span
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
        env.water.setflowVec([flwSpd(kk) 0 0],'m/s');               %   m/s - Flow speed vector
        if simScenario == 0
            ENVIRONMENT = 'environmentManta';                       %   Single turbine
        elseif simScenario == 2
            ENVIRONMENT = 'environmentDOE';                         %   No turbines
        else
            ENVIRONMENT = 'environmentManta2Rot';                   %   Two turbines
        end
        %%  Set basis parameters for high level controller
        if simScenario >= 1 && simScenario < 2
            loadComponent('varAltitudeBooth');                          %   High level controller
            hiLvlCtrl.elevationLookup.setValue(maxT.R.EL,'deg');
            if simScenario == 1.3
                hiLvlCtrl.ELctrl.setValue(1,'');
            else
                hiLvlCtrl.ELctrl.setValue(1,'');
            end
            hiLvlCtrl.ELslew.setValue(0.25,'deg/s');
            hiLvlCtrl.ThrCtrl.setValue(1,'');
        else
            loadComponent('constBoothLem');                             %   High level controller
        end
        hiLvlCtrl.basisParams.setValue([a,b,el,0*pi/180,thrLength],'[rad rad rad rad m]') % Lemniscate of Booth
        %%  Ground Station Properties
        %%  Vehicle Properties
        vhcl.setICsOnPath(.05,PATHGEOMETRY,hiLvlCtrl.basisParams.Value,gndStn.posVec.Value,6.5*flwSpd(kk)*norm([1;0;0]))
        if simScenario >= 3
            vhcl.setICsOnPath(0,PATHGEOMETRY,hiLvlCtrl.basisParams.Value,gndStn.posVec.Value,0)
            vhcl.setInitEulAng([0,0,0]*pi/180,'rad')
        end
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
        fltCtrl.elevatorReelInDef.setValue(3,'deg');        fltCtrl.rudderGain.setValue(0,'');
        fltCtrl.AoACtrl.setValue(2,'');                     fltCtrl.AoASP.setValue(1,'');
        fltCtrl.AoAConst.setValue(vhcl.optAlpha.Value*pi/180,'deg');
        fltCtrl.alphaCtrl.kp.setValue(.3,'(kN)/(rad)');     fltCtrl.Tmax.setValue(Tmax,'kN');
        fltCtrl.elevCtrl.kp.setValue(100,'(deg)/(rad)');    fltCtrl.elevCtrl.ki.setValue(1,'(deg)/(rad*s)');            %%  Set up critical system parameters and run simulation
        fltCtrl.firstSpoolLap.setValue(25,'');              fltCtrl.winchSpeedIn.setValue(0,'m/s');
        fltCtrl.elevCtrlMax.upperLimit.setValue(30,'');     fltCtrl.elevCtrlMax.lowerLimit.setValue(-30,'');
        vhcl.setBuoyFactor(getBuoyancyFactor(vhcl,env,thr),'');
        vhcl.turb1.setDiameter(D(ii),'m');     vhcl.turb2.setDiameter(D(ii),'m')
        %%  Set up critical system parameters and run simulation
        fprintf('Diameter = %.2f m\n',D(ii));
        simParams = SIM.simParams;  simParams.setDuration(10000,'s');  dynamicCalc = '';
        simWithMonitor('OCTModel')
        %%  Log Results
        tsc = signalcontainer(logsout);
        dt = datestr(now,'mm-dd_HH-MM');
        filename = sprintf(strcat('Turb%.1f_V-%.3f_D-%.3f.mat'),simScenario,flwSpd(kk),D(ii));
        %             fpath = fullfile(fileparts(which('OCTProject.prj')),'Results','Manta 2.0','Rotor','ThrD\');
        fpath = 'D:\Results\';
        if saveSim == 1
%             save(strcat(fpath,filename),'tsc','vhcl','thr','fltCtrl','env','simParams','LIBRARY','gndStn')
        end
        [Idx1,Idx2] = tsc.getLapIdxs(max(tsc.lapNumS.Data)-1);  ran = Idx1:Idx2;
        [CLtot,CDtot] = tsc.getCLCD(vhcl);
        [Lift,Drag,Fuse,Thr] = tsc.getLiftDrag;
        Turb = squeeze(sqrt(sum(tsc.FTurbBdy.Data.^2,1)));
        Pow = tsc.rotPowerSummary(vhcl,env);
        Pavg(ii,kk) = Pow.avg;
        AoA(ii,kk) = mean(squeeze(tsc.vhclAngleOfAttack.Data(:,:,ran)));
        fprintf('Average AoA = %.2f \n',AoA(ii,kk));
        CL(ii,kk) = mean(CLtot(ran));   CD(ii,kk) = mean(CDtot(ran));
        Fdrag(ii,kk) = mean(Drag(ran)); Flift(ii,kk) = mean(Lift(ran));
        Ffuse(ii,kk) = mean(Fuse(ran)); Fthr(ii,kk) = mean(Thr(ran));   Fturb(ii,kk) = mean(Turb(ran));
    end
end
%%
filename1 = 'TurbDiamStudy_PDR.mat';
fpath1 = fullfile(fileparts(which('OCTProject.prj')),'output\');
save([fpath1,filename1],'Pavg','AoA','CL','CD','Fdrag','Flift','Ffuse','Fthr','Fturb','D','ThrD')