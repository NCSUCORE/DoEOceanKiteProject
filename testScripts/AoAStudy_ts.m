%% Test script for John to control the kite   model
Simulink.sdi.clear
clear;clc;%close all
%%  Select sim scenario
simScenario = 1.5;
%%  Set Test Parameters
saveSim = 1;                                                %   Flag to save results
A = 5:0.25:14;
thrLength = 400;                                            %   m - Initial tether length
flwSpd = 0.25:0.025:0.5;                                    %   m/s - Flow speed
el = 30*pi/180;                                             %   rad - Mean elevation angle
h = 10*pi/180;  w = 40*pi/180;                              %   rad - Path width/height
[a,b] = boothParamConversion(w,h);                          %   Path basis parameters
for kk = 1:numel(flwSpd)
    for ii = 1:numel(A)
        Simulink.sdi.clear
        %%  Load components
        loadComponent('pathFollowWithAoACtrl');                 %   Path-following controller with AoA control
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
        elseif simScenario == 1.9 || simScenario == 3.9 || simScenario == 4.9
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
        hiLvlCtrl.basisParams.setValue([a,b,el,0*pi/180,thrLength],'[rad rad rad rad m]') % Lemniscate of Booth
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
        thr.tether1.setDiameter(0.009,thr.tether1.diameter.Unit);
        thr.tether1.setYoungsMod(55e9,thr.tether1.youngsMod.Unit);
        thr.tether1.dragCoeff.setValue(1,'');
        %%  Winches Properties
        wnch.setTetherInitLength(vhcl,gndStn.posVec.Value,env,thr,env.water.flowVec.Value);
        %%  Controller User Def. Parameters and dependant properties
        fltCtrl.setFcnName(PATHGEOMETRY,'');
        fltCtrl.setInitPathVar(vhcl.initPosVecGnd.Value,hiLvlCtrl.basisParams.Value,gndStn.posVec.Value);
        fltCtrl.rudderGain.setValue(0,'')
        thr.tether1.dragEnable.setValue(1,'');
        fltCtrl.AoACtrl.setValue(1,'');                     fltCtrl.AoASP.setValue(0,'');
        fltCtrl.AoAConst.setValue(A(ii)*pi/180,'deg');
        fltCtrl.AoATime.setValue([0 1000 2000],'s');        fltCtrl.AoALookup.setValue([14 2 14]*pi/180,'deg');
        fltCtrl.elevCtrl.kp.setValue(200,'(deg)/(rad)');    fltCtrl.elevCtrl.ki.setValue(1,'(deg)/(rad*s)');            %%  Set up critical system parameters and run simulation
        fprintf('Flow Speed = %.3f m/s;\tAoA SP = %.1f deg\n',flwSpd(kk),A(ii));
        simParams = SIM.simParams;  simParams.setDuration(2000,'s');  dynamicCalc = '';
        simWithMonitor('OCTModel')
        %%  Log Results
        tsc = signalcontainer(logsout);
        dt = datestr(now,'mm-dd_HH-MM');
        filename = sprintf(strcat('Turb%.1f_V-%.3f_AoA-%d.mat'),simScenario,flwSpd(kk),A(ii));
        fpath = 'D:\Results\';
        if saveSim == 1
            save(strcat(fpath,filename),'tsc','vhcl','fltCtrl','LIBRARY','env')
        end
        [Idx1,Idx2] = tsc.getLapIdxs(max(tsc.lapNumS.Data)-1);  ran = Idx1:Idx2;
        [CLtot,CDtot] = tsc.getCLCD(vhcl);
        [Lift,Drag,Fuse,Thr] = tsc.getLiftDrag;
        Turb = squeeze(sqrt(sum(tsc.FTurbBdy.Data.^2,1)));
        Pow = tsc.rotPowerSummary(vhcl,env);
        Pavg(ii,kk) = Pow.avg;
        AoA(ii,kk) = mean(squeeze(tsc.vhclAngleOfAttack.Data(:,:,ran)));
        airNode = squeeze(sqrt(sum(tsc.airTenVecs.Data.^2,1)))*1e-3;
        gndNode = squeeze(sqrt(sum(tsc.gndNodeTenVecs.Data.^2,1)))*1e-3;
        ten(ii,kk) = max([max(airNode(ran)) max(gndNode(ran))]);
        fprintf('Average AoA = %.3f;\t Max Tension = %.1f kN\n',AoA(ii,kk),ten(ii,kk));
        CL(ii,kk) = mean(CLtot(ran));   CD(ii,kk) = mean(CDtot(ran));
        Fdrag(ii,kk) = mean(Drag(ran)); Flift(ii,kk) = mean(Lift(ran));
        Ffuse(ii,kk) = mean(Fuse(ran)); Fthr(ii,kk) = mean(Thr(ran));   Fturb(ii,kk) = mean(Turb(ran));
        Depth(ii,kk) = 500-mean(tsc.positionVec.Data(3,1,ran));
    end
end
%%
filename1 = 'AoA_Study_1-5.mat';
fpath1 = fullfile(fileparts(which('OCTProject.prj')),'output\');
save([fpath1,filename1],'Pavg','AoA','CL','CD','Fdrag','Flift','Ffuse','Fthr','Fturb','flwSpd','ten','A')
%%  Isolate 
maxT = 18;  eff = 0.82;
for i = 1:numel(flwSpd)
    for j = 1:numel(A)
        if ten(j,i) > maxT
            Ptemp(j,i) = NaN;
            Ttemp(j,i) = NaN;
            alpha(j,i) = NaN;
        else
            Ptemp(j,i) = Pavg(j,i);
            Ttemp(j,i) = ten(j,i);
            alpha(j,i) = AoA(j,i);
        end
    end
    Pmax(i) = max(Ptemp(:,i))*eff;
    PrawG(i) = max(Pavg(:,i))*eff;
    PrawK(i) = max(Pavg(:,i));
    Tmax(i) = max(Ttemp(:,i));
    Traw(i) = max(ten(:,i));
    Amax(i) = max(alpha(:,i));
end
%%
figure; subplot(3,1,1); hold on; grid on;
plot(flwSpd,PrawK,'b--'); plot(flwSpd,PrawG,'b-'); plot(flwSpd,Pmax,'r-');
xlabel('$V_\mathrm{flow}$ [m/s]'); ylabel('Power [kW]'); 
subplot(3,1,2); hold on; grid on;
plot(flwSpd,Traw,'b--'); plot(flwSpd,Traw,'b-'); plot(flwSpd,Tmax,'r-'); plot(flwSpd,maxT*ones(numel(flwSpd),1),'k--');
xlabel('$V_\mathrm{flow}$ [m/s]'); ylabel('Tension [kN]'); 
legend('Raw at Kite','Raw at Glider','Saturated','Max Tension','location','northwest');
subplot(3,1,3); hold on; grid on;
plot(flwSpd,Amax,'b-'); xlabel('$V_\mathrm{flow}$ [m/s]'); ylabel('AoA [deg]'); 

