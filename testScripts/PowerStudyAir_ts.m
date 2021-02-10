%% Test script for John to control the kite model
Simulink.sdi.clear
clear;clc;%close all
%%  Select sim scenario
simScenario = [2 1 1 1 false];
%%  Set Test Parameters
saveSim = 1;                                                %   Flag to save results
thrLength = 400:100:1500;                                   %   m - Initial tether length
flwSpd = 6:18;                                              %   m/s - Flow speed
altitude = 100:100:1000;                                    %   m - Altitude range
w = 28*pi/180;  h = w/5;                                    %   rad - Path width and height 
[a,b] = boothParamConversion(w,h);                          %   Path basis parameters
thrDrag = true;
tic
for kk = 1:numel(flwSpd)
    for ii = 1:numel(thrLength)
        for jj = 1:numel(altitude)
            if altitude(jj) >= 0.7071*thrLength(ii) || altitude(jj) <= 0.0871*thrLength(ii)
                el = NaN;
            else
                el = asin(altitude(jj)/thrLength(ii));
            end
            Simulink.sdi.clear
            %%  Load components
            SPOOLINGCONTROLLER = 'netZeroSpoolingController';   % Spooling controller
            loadComponent('oneDoFGSCtrlBasic');                 % Ground station controller
            loadComponent('pathFollowingGndStn');               % Ground station
            loadComponent('ayazFullScaleOneThrWinch');          % Winches
            loadComponent('ayazAirborneThr');                   % Tether
            loadComponent('idealSensors');                      % Sensors
            loadComponent('idealSensorProcessing');             % Sensor processing
            switch simScenario(1)                               % select vehicle based on sim scenario
                case 1 % unrealistically light weight
                    loadComponent('ayazAirborneVhcl');
                case 2 % realistic
                    loadComponent('realisticAirborneVhcl');
            end
            switch simScenario(2)                               % select High level controller based on sim scenario
                case 1 % constant path shape
                    loadComponent('constBoothLem');
                    hiLvlCtrl.basisParams.setValue([a,b,el,...
                        0*pi/180,thrLength(ii)],'[rad rad rad rad m]');
                    hiLvlCtrl.maxNumberOfSimulatedLaps.setValue(5,'');
                case 2 % only the high level control of mean elevation angle
                    loadComponent('gpkfPathOptAirborne');
                    % hiLvlCtrl.maxStepChange        = (800/thrLength)*180/pi;
                    hiLvlCtrl.maxStepChange        = 6;
                    hiLvlCtrl.minVal               = 5;
                    hiLvlCtrl.maxVal               = 50;
                    hiLvlCtrl.basisParams.Value = [a,b,el,0*pi/180,thrLength(ii)]';
                    hiLvlCtrl.initVals          = hiLvlCtrl.basisParams.Value(3)*180/pi;
                    hiLvlCtrl.rateLimit         = 1*0.15;
                    hiLvlCtrl.kfgpTimeStep      = 10/60;
                    hiLvlCtrl.mpckfgpTimeStep   = 3;
                    predictionHorz  = 6;
                    exploitationConstant = 1;
                    explorationConstant  = 2^6;
                case 3 % both mean elevation angle and path shape optimization
                    loadComponent('gpkfPathOptWithRGPAirborne');
                    % hiLvlCtrl.maxStepChange        = (800/thrLength)*180/pi;
                    hiLvlCtrl.maxStepChange        = 6;
                    hiLvlCtrl.minVal               = 5;
                    hiLvlCtrl.maxVal               = 50;
                    hiLvlCtrl.basisParams.Value = [a,b,el,0*pi/180,thrLength(ii)]';
                    hiLvlCtrl.initVals          = hiLvlCtrl.basisParams.Value(3)*180/pi;
                    hiLvlCtrl.rateLimit         = 1*0.15;
                    hiLvlCtrl.kfgpTimeStep      = 10/60;
                    hiLvlCtrl.mpckfgpTimeStep   = 3;
                    predictionHorz  = 6;
                    exploitationConstant = 1;
                    explorationConstant  = 2^6;
            end
            switch simScenario(3)       % select Environment based on sim scenario
                case 1 % constant flow field
                    loadComponent('ayazAirborneFlow.mat');
                    env.water.flowVec.setValue([flwSpd(kk);0;0],'m/s');
                case 2 % synthetically generated flow field
                    loadComponent('ayazAirborneSynFlow');
            end
            %%  Ground Station Properties
            gndStn.setPosVec([0 0 0],'m')
            gndStn.initAngPos.setValue(0,'rad');
            gndStn.initAngVel.setValue(0,'rad/s');
            %%  Vehicle Properties
            vhcl.setICsOnPath(.05,PATHGEOMETRY,hiLvlCtrl.basisParams.Value,gndStn.posVec.Value,(11/2)*norm(flwSpd(kk)));
            %%  Tethers Properties
            thr.tether1.initGndNodePos.setValue(gndStn.thrAttch1.posVec.Value(:)...
                +gndStn.posVec.Value(:),'m');
            thr.tether1.initAirNodePos.setValue(vhcl.initPosVecGnd.Value(:)...
                +rotation_sequence(vhcl.initEulAng.Value)*vhcl.thrAttchPts_B.posVec.Value,'m');
            thr.tether1.initGndNodeVel.setValue([0 0 0]','m/s');
            thr.tether1.initAirNodeVel.setValue(vhcl.initVelVecBdy.Value(:),'m/s');
            thr.tether1.vehicleMass.setValue(vhcl.mass.Value,'kg');
            thr.tether1.dragEnable.setValue(thrDrag,'');
            %%  Winches Properties
            wnch.setTetherInitLength(vhcl,gndStn.posVec.Value,env,thr,[flwSpd(kk);0;0]);
            %%  Controller User Def. Parameters and dependant properties
            switch simScenario(4)
                case 1 % usual path following controller
                    loadComponent('ayazPathFollowingAirborne');
                case 2 % guidance law based path following controller
                    loadComponent('guidanceLawPathFollowingAir');
            end
            fltCtrl.setInitPathVar(vhcl.initPosVecGnd.Value,...
                hiLvlCtrl.basisParams.Value,...
                gndStn.posVec.Value);
            fltCtrl.elevatorReelInDef.setValue(0,'deg');
            if ~isnan(el)
                simParams = SIM.simParams;  simParams.setDuration(10000,'s');  dynamicCalc = '';
                simWithMonitor('OCTModel')
                %%  Log Results
                tsc = signalcontainer(logsout);
                if tsc.lapNumS.Data(end) > 1
                    [Idx1,Idx2] = tsc.getLapIdxs(max(tsc.lapNumS.Data)-1);  ran = Idx1:Idx2;
                    [CLtot,CDtot] = tsc.getCLCD(vhcl);
                    [Lift,Drag,Fuse,Thr] = tsc.getLiftDrag;
                    Turb = squeeze(sqrt(sum(tsc.FTurbBdy.Data.^2,1)));
                    Pow = tsc.rotPowerSummaryAir(vhcl,env);
                    Pavg(kk,ii,jj) = Pow.avg;    Pnet(kk,ii,jj) = Pow.avg;
                    V = squeeze(sqrt(sum(tsc.velCMvec.Data.^2,1)));
                    Vavg(kk,ii,jj) = mean(V(ran));
                    AoA(kk,ii,jj) = mean(squeeze(tsc.vhclAngleOfAttack.Data(:,:,ran)));
                    airNode = squeeze(sqrt(sum(tsc.airTenVecs.Data.^2,1)))*1e-3;
                    gndNode = squeeze(sqrt(sum(tsc.gndNodeTenVecs.Data.^2,1)))*1e-3;
                    ten(kk,ii,jj) = max([max(airNode(ran)) max(gndNode(ran))]);
                    fprintf('Average AoA = %.3f;\t Max Tension = %.1f kN;\t Elevation = %.1f\n',AoA(kk,ii,jj),ten(kk,ii,jj),el*180/pi);
                    CL(kk,ii,jj) = mean(CLtot(ran));   CD(kk,ii,jj) = mean(CDtot(ran));
                    Fdrag(kk,ii,jj) = mean(Drag(ran)); Flift(kk,ii,jj) = mean(Lift(ran));
                    Ffuse(kk,ii,jj) = mean(Fuse(ran)); Fthr(kk,ii,jj) = mean(Thr(ran));   Fturb(kk,ii,jj) = mean(Turb(ran));
                    elevation(kk,ii,jj) = el*180/pi;
                    filename = sprintf(strcat('Air_V-%d_Alt-%.d_ThrL-%d.mat'),flwSpd(kk),altitude(jj),thrLength(ii));
                    fpath = 'D:\Power Study\';
                    save(strcat(fpath,filename),'tsc','vhcl','thr','fltCtrl','env','simParams','gndStn')
                else
                    Pavg(kk,ii,jj) = NaN;  AoA(kk,ii,jj) = NaN;   ten(kk,ii,jj) = NaN;
                    CL(kk,ii,jj) = NaN;    CD(kk,ii,jj) = NaN;    Fdrag(kk,ii,jj) = NaN;
                    Flift(kk,ii,jj) = NaN; Ffuse(kk,ii,jj) = NaN; Fthr(kk,ii,jj) = NaN;
                    Fturb(kk,ii,jj) = NaN; elevation(kk,ii,jj) = el*180/pi;
                    Pnet(kk,ii,jj) = NaN;  Vavg(kk,ii,jj) = NaN;
                    filename = sprintf(strcat('Air_V-%d_Alt-%.d_ThrL-%d.mat'),flwSpd(kk),altitude(jj),thrLength(ii));
                    fpath = 'D:\Power Study\';
                    save(strcat(fpath,filename),'tsc','vhcl','thr','fltCtrl','env','simParams','gndStn')
                end
            else
                Pavg(kk,ii,jj) = NaN;  AoA(kk,ii,jj) = NaN;   ten(kk,ii,jj) = NaN;
                CL(kk,ii,jj) = NaN;    CD(kk,ii,jj) = NaN;    Fdrag(kk,ii,jj) = NaN;
                Flift(kk,ii,jj) = NaN; Ffuse(kk,ii,jj) = NaN; Fthr(kk,ii,jj) = NaN;
                Fturb(kk,ii,jj) = NaN; elevation(kk,ii,jj) = el*180/pi;
                Pnet(kk,ii,jj) = NaN;  Vavg(kk,ii,jj) = NaN;
            end
        end
    end
end
tRun = toc/60;  fprintf('Runtime = %.1f min\n',tRun);
%%
filename1 = sprintf('Altitude_Power_Study_Air.mat');
fpath1 = fullfile(fileparts(which('OCTProject.prj')),'output\');
save([fpath1,filename1],'Pavg','AoA','CL','CD','Fdrag','Flift','Ffuse','Fthr',...
    'Fturb','thrLength','elevation','flwSpd','ten','Tmax','altitude')
