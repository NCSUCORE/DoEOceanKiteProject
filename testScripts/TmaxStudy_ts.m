%% Test script for John to control the kite model
Simulink.sdi.clear
clear;clc;%close all
%%  Select sim scenario
simScenario = 1.3;
%%  Set Test Parameters
fpath2 = fullfile(fileparts(which('OCTProject.prj')),'vehicleDesign','Tether\');  
saveSim = 1;                                                %   Flag to save results
Tmax = 38;
thrLength = 200:50:600;                                     %   m - Initial tether length
flwSpd = 0.1:0.05:0.5;                                      %   m/s - Flow speed
altitude = [50 100 150 200 250 300];
h = 10*pi/180;  w = 40*pi/180;                              %   rad - Path width/height
[a,b] = boothParamConversion(w,h);                          %   Path basis parameters
tic
for ll = 1:2
    for kk = 1:numel(flwSpd)
        for ii = 1:numel(thrLength)
            for jj = 1:numel(altitude)
                if ll == 1
                    load([fpath2 'tetherDataNew.mat']);
                    Tref = 38;
                else
                    load([fpath2 'tetherDataFS5.mat']);
                    Tref = 190;
                end
                fpathT = fullfile(fileparts(which('OCTProject.prj')),...
                    'vehicleDesign\Tether\Tension\');
                maxT = load([fpathT,sprintf('TmaxStudy_%dkN.mat',Tmax)]);
                eff = eval(sprintf('AR8b8.length600.tensionValues%d.efficencyPercent',Tref))/100;
                TDiam = eval(sprintf('AR8b8.length600.tensionValues%d.outerDiam',Tref));
                young = eval(sprintf('AR8b8.length600.tensionValues%d.youngsMod',Tref));
                if altitude(jj) >= 0.7071*thrLength(ii) || altitude(jj) <= 0.1736*thrLength(ii)
                    el = NaN;
                else
                    el = asind(altitude(jj)/thrLength(ii))*pi/180;
                end
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
                    loadComponent('Manta2RotXFoil_AR8_b8');                       %   AR = 8; 8m span; 4pct buoyant
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
                hiLvlCtrl.basisParams.setValue([a,b,el,0*pi/180,thrLength(ii)],'[rad rad rad rad m]') % Lemniscate of Booth
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
                thr.tether1.setDiameter(TDiam,thr.tether1.diameter.Unit);
                thr.tether1.setYoungsMod(young,thr.tether1.youngsMod.Unit);
                thr.tether1.dragCoeff.setValue(1,'');
                %%  Winches Properties
                wnch.setTetherInitLength(vhcl,gndStn.posVec.Value,env,thr,env.water.flowVec.Value);
                %%  Controller User Def. Parameters and dependant properties
                fltCtrl.setFcnName(PATHGEOMETRY,'');
                fltCtrl.setInitPathVar(vhcl.initPosVecGnd.Value,hiLvlCtrl.basisParams.Value,gndStn.posVec.Value);
                fltCtrl.elevatorReelInDef.setValue(3,'deg');
                fltCtrl.AoACtrl.setValue(1,'');                     fltCtrl.RCtrl.setValue(0,'');
                fltCtrl.AoASP.setValue(1,'');                       fltCtrl.AoAConst.setValue(vhcl.optAlpha.Value*pi/180,'deg');
                fltCtrl.alphaCtrl.kp.setValue(.3,'(kN)/(rad)');     fltCtrl.Tmax.setValue(Tmax,'kN');
                fltCtrl.elevCtrl.kp.setValue(125,'(deg)/(rad)');    fltCtrl.elevCtrl.ki.setValue(1,'(deg)/(rad*s)');
                fltCtrl.rollCtrl.kp.setValue(200,'(deg)/(rad)');    fltCtrl.rollCtrl.ki.setValue(1,'(deg)/(rad*s)');
                fltCtrl.firstSpoolLap.setValue(10,'');              fltCtrl.winchSpeedIn.setValue(.1,'m/s');
                fltCtrl.elevCtrlMax.upperLimit.setValue(8,'');      fltCtrl.elevCtrlMax.lowerLimit.setValue(0,'');
                fprintf('\nFlow Speed = %.3f m/s;\tTether Length = %.1f m;\t Altitude = %d m;\t ThrD = %.1f mm\n',flwSpd(kk),thrLength(ii),altitude(jj),TDiam*1e3);
                simParams = SIM.simParams;  simParams.setDuration(20000,'s');  dynamicCalc = '';
                vhcl.setBuoyFactor(getBuoyancyFactor(vhcl,env,thr),'');
                if ~isnan(el)
                    simWithMonitor('OCTModel')
                    %%  Log Results
                    tsc = signalcontainer(logsout);
                    dt = datestr(now,'mm-dd_HH-MM');
                    [Idx1,Idx2] = tsc.getLapIdxs(max(tsc.lapNumS.Data)-1);  ran = Idx1:Idx2;
                    [CLtot,CDtot] = tsc.getCLCD(vhcl);
                    [Lift,Drag,Fuse,Thr] = tsc.getLiftDrag;
                    Turb = squeeze(sqrt(sum(tsc.FTurbBdy.Data.^2,1)));
                    Pow = tsc.rotPowerSummary(vhcl,env);
                    Pavg(ll,kk,ii,jj) = Pow.avg;    Pnet(ll,kk,ii,jj) = Pow.avg*eff;
                    AoA(ll,kk,ii,jj) = mean(squeeze(tsc.vhclAngleOfAttack.Data(:,:,ran)));
                    airNode = squeeze(sqrt(sum(tsc.airTenVecs.Data.^2,1)))*1e-3;
                    gndNode = squeeze(sqrt(sum(tsc.gndNodeTenVecs.Data.^2,1)))*1e-3;
                    ten(ll,kk,ii,jj) = max([max(airNode(ran)) max(gndNode(ran))]);
                    fprintf('Average AoA = %.3f;\t Max Tension = %.1f kN;\t Elevation = %.1f\n',AoA(ll,kk,ii,jj),ten(ll,kk,ii,jj),el*180/pi);
                    CL(ll,kk,ii,jj) = mean(CLtot(ran));   CD(ll,kk,ii,jj) = mean(CDtot(ran));
                    Fdrag(ll,kk,ii,jj) = mean(Drag(ran)); Flift(ll,kk,ii,jj) = mean(Lift(ran));
                    Ffuse(ll,kk,ii,jj) = mean(Fuse(ran)); Fthr(ll,kk,ii,jj) = mean(Thr(ran));   Fturb(ll,kk,ii,jj) = mean(Turb(ran));
                    elevation(ll,kk,ii,jj) = el*180/pi;
                    filename = sprintf(strcat('Turb%.1f_V-%.3f_Alt-%.d_ThrL-%d_ThrD-%.1f.mat'),simScenario,flwSpd(kk),altitude(jj),thrLength(ii),TDiam*1e3);
                    fpath = 'D:\Altitude Thr-L Study\';
                    save(strcat(fpath,filename),'tsc','vhcl','thr','fltCtrl','env','simParams','LIBRARY','gndStn')
                else
                    Pavg(ll,kk,ii,jj) = NaN;  AoA(ll,kk,ii,jj) = NaN;   ten(ll,kk,ii,jj) = NaN;
                    CL(ll,kk,ii,jj) = NaN;    CD(ll,kk,ii,jj) = NaN;    Fdrag(ll,kk,ii,jj) = NaN; 
                    Flift(ll,kk,ii,jj) = NaN; Ffuse(ll,kk,ii,jj) = NaN; Fthr(ll,kk,ii,jj) = NaN;   
                    Fturb(ll,kk,ii,jj) = NaN; elevation(ll,kk,ii,jj) = el*180/pi;
                    Pnet(ll,kk,ii,jj) = NaN;
                end
            end
        end
    end
    filename1 = sprintf('Tmax_Study_AR8b8_Tmax-%d_ThrD-%.1f.mat',Tmax,TDiam*1e3);
    fpath1 = fullfile(fileparts(which('OCTProject.prj')),'output\Tmax Study\');
    save([fpath1,filename1],'Pavg','Pnet','AoA','CL','CD','Fdrag','Flift','Ffuse','Fthr',...
        'Fturb','thrLength','elevation','flwSpd','ten','Tmax','altitude')
end
toc
%%
% filename1 = sprintf('Tmax_Study_AR8b8.mat');
% fpath1 = fullfile(fileparts(which('OCTProject.prj')),'output','Tmax Study\');
% save([fpath1,filename1],'Pavg','AoA','CL','CD','Fdrag','Flift','Ffuse','Fthr',...
%     'Fturb','thrLength','elevation','flwSpd','ten','Tmax','altitude','ii','jj','ll','kk')
