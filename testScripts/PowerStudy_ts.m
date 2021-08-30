%% Test script to generate a power surface with respect to flow speed and altitude
clear; clc; %close all;
Simulink.sdi.clear
%% Simulation Setup
% 1 - Vehicle Model:         1 = AR8b8, 2 = AR9b9, 3 = AR9b10
% 2 - High-level Controller: 1 = const basis, 2 = const basis/state flow
% 3 - Flight controller:     1 = pathFlow, 2 = full cycle
% 4 - Tether Model:          1 = Single link, 2 = Reel-in, 3 = Multi-node, 4 = Multi-node faired
% 5 - Environment:           1 = const flow, 2 = variable flow
% 6 - Save Results
% 7 - Animate
% 8 - Plotting
%%             1 2 3 4 5 6     7     8
simScenario = [1 1 1 4 1 false false 1==1];
%%  Set Test Parameters
flwArray = 0.1:0.05:0.5;                %   m/s - candidate flow speeds
altArray = 50:50:400;                   %   m - candidate operating altitudes
thrArray = 200:50:600;                 %   m - candidate tether lengths
thrDiam = 18.0;                         %   mm - candidate tether diameters
Tmax = getMaxTension(thrDiam);          %   kN - candidate tether tension limits
fairing = 100;                          %   m - length of fairing distribution

h = 10*pi/180;  w = 40*pi/180;          %   rad - Path width/height
[a,b] = boothParamConversion(w,h);      %   Path basis parameters

scale = 1;                              %   Simulation scale factor
AoAsp = 5;                             %   deg - angle of attack setpoint
tFinal = 10000;                         %   s - maximum simulation time
%%  Loop Through Simulation Scenarios
for i = 1:numel(flwArray)
    for j = 1:numel(thrArray)
        for k = 1:numel(altArray)
            Simulink.sdi.clear              %   Clear Simulink cashe
            flwSpd = flwArray(i);           %   m/s - current flow speed
            thrLength = thrArray(j);        %   m = current tether length
            altitude = altArray(k);         %   m - current altitude
            initTL = thrLength;             %   m - set initial tether length
            initAltitude = altitude;        %   m - set initial altitude
            %   Check elevation angle limts
            if altitude >= 0.7071*thrLength || altitude <= 0.1736*thrLength
                fprintf('Elevation angle is out of range\n')
                el = NaN;
            else
                el = asin(altitude/thrLength);
            end
            %%  Load components
            switch simScenario(1)                                   %   Vehicle
                case 1
                    loadComponent('Manta2RotXFoil_AR8_b8');         %   AR = 8; 8m span
                case 2
                    loadComponent('Manta2RotXFoil_AR9_b9');         %   AR = 9; 9m span
                case 3
                    loadComponent('Manta2RotXFoil_AR9_b10');        %   AR = 9; 10m span
            end
            switch simScenario(2)                                   %   Flight Controller
                case 1
                    loadComponent('constBoothLem');                     %   Constant basis parameters
                    hiLvlCtrl.basisParams.setValue([a,b,el,0*pi/180,... %   Initialize basis parameters
                        thrLength],'[rad rad rad rad m]');
                case 2
                    loadComponent('mantaFSHiLvl');                     %   Constant basis parameters
                    el = asin(altitude/thrLength);                      %   rad - Initial elevation angle
                    hiLvlCtrl.stateCtrl.setValue(0,'');
                    hiLvlCtrl.stateConst.setValue(1,'');
                    hiLvlCtrl.preXelevation.setValue(max(el-h,5*pi/180),'rad')
                    hiLvlCtrl.initXelevation.setValue(max(el-h/2,5*pi/180),'rad')
                    m = (hiLvlCtrl.preXelevation.Value-pi/2)/hiLvlCtrl.maxThrLength.Value;
                    initEL = asin(initAltitude/initTL);                      %   rad - Initial elevation angle
                    hiLvlCtrl.basisParams.setValue([a,b,initEL,0*pi/180,... %   Initialize basis parameters
                        initTL],'[rad rad rad rad m]');
                    hiLvlCtrl.harvestingAltitude.setValue(altitude,'m');
                    hiLvlCtrl.harvestingThrLength.setValue(thrLength,'m');
            end
            switch simScenario(3)                                   %   Flight Controller
                case 1
                    loadComponent('pathFollowWithAoACtrl');             %   Path-following controller with AoA control
                case 2
                    loadComponent('pathFollowWithAoACtrl');             %   Path-following controller with AoA control
                    pthCtrl1 = fltCtrl;
                    pthCtrl1.fcnName.setValue('lemOfBooth','');
                    pthCtrl2 = fltCtrl;
                    loadComponent('LaRController');                     %   Launch and recovery controller
                    slfCtrl = fltCtrl;
                    loadComponent('MantaFSController');                 %   Path-following controller with AoA control
            end
            switch simScenario(4)                                   %   Tether model
                case 1
                    loadComponent('MantaTether');                       %   Manta Ray tether
                case 2
                    loadComponent('shortTether');                       %   Tether for reeling
                    thr.tether1.setInitTetherLength(initTL,'m');     %   Initialize tether length
                case 3
                    loadComponent('MantaTetherReal');                       %   Manta Ray tether
                case 4
                    loadComponent('fairedNNodeTether');                       %   Manta Ray tether
            end
            switch simScenario(5)                                   %   Environment
                case 1
                    loadComponent('ConstXYZT');                         %   Constant flow
                case 2
                    loadComponent('ConstYZTvarX');                      %   Variable X
            end
            ENVIRONMENT = 'env2turb';               %   Two turbines
            env.water.setflowVec([flwSpd 0 0],'m/s');           %   m/s - Flow speed vector
            loadComponent('oneDoFGSCtrlBasic');                         %   Ground station controller
            loadComponent('MantaGndStn');                               %   Ground station
            loadComponent('winchManta');                                %   Winches
            loadComponent('idealSensors')                               %   Sensors
            loadComponent('idealSensorProcessing')                      %   Sensor processing
            %%  Vehicle Properties
            if simScenario(3) == 1
                vhcl.setICsOnPath(0.05,PATHGEOMETRY,hiLvlCtrl.basisParams.Value,gndStn.posVec.Value,4*flwSpd)
            else
                vhcl.setICsOnPath(0,PATHGEOMETRY,hiLvlCtrl.basisParams.Value,gndStn.posVec.Value,0)
                vhcl.setInitEulAng([0,0,0]*pi/180,'rad')
            end
            vhcl.hStab.CL.setValue(vhcl.hStab.alpha.Value*0.02156+.04334,'')
            %%  Tethers Properties
            thr.tether1.initGndNodePos.setValue(gndStn.thrAttch1.posVec.Value(:)+gndStn.posVec.Value(:),'m');
            thr.tether1.initAirNodePos.setValue(vhcl.initPosVecGnd.Value(:)...
                +rotation_sequence(vhcl.initEulAng.Value)*vhcl.thrAttchPts_B.posVec.Value,'m');
            thr.tether1.initGndNodeVel.setValue(gndStn.velVec.Value','m/s');
            thr.tether1.initAirNodeVel.setValue(rotation_sequence(vhcl.initEulAng.Value)*vhcl.initVelVecBdy.Value(:),'m/s');
            thr.tether1.vehicleMass.setValue(vhcl.mass.Value,'kg');
            thr.numNodes.setValue(9,'');
            thr.tether1.numNodes.setValue(9,'');
            thr.tether1.fairedLinks.setValue(2,'');
            
            if simScenario(4) == 4
                thr.tether1.fairedLength.setValue(fairing,'m');
            end
            
            thr.tether1.diameter.setValue(thrDiam*1e-3,'m')
            %%  Winches Properties
            wnch.setTetherInitLength(vhcl,gndStn.posVec.Value,env,thr,env.water.flowVec.Value);
            wnch.winch1.LaRspeed.setValue(1,'m/s');
            %%  Controller User Def. Parameters and dependant properties
            switch simScenario(3)
                case 1
                    fltCtrl.setFcnName(PATHGEOMETRY,'');
                    fltCtrl.setInitPathVar(vhcl.initPosVecGnd.Value,hiLvlCtrl.basisParams.Value,gndStn.posVec.Value);
                    fltCtrl.AoASP.setValue(1,'');                           fltCtrl.AoAConst.setValue(AoAsp*pi/180,'deg');
                    fltCtrl.AoACtrl.setValue(1,'');
                    if scale == 0.375
                        fltCtrl.controlSigMax.upperLimit.setValue(30,'')
                        fltCtrl.controlSigMax.lowerLimit.setValue(-30,'')
                        fltCtrl.alphaCtrl.kp.setValue(4.8*pi/180,'(rad)/(kN*s^2/m^2)');
                        fltCtrl.alphaCtrl.ki.setValue(0.001,'(rad)/(kN*s^2/m^2*s)');
                        fltCtrl.alphaCtrl.kd.setValue(16*pi/180,'(rad)/(kN*s^2/m^2/s)');
                        fltCtrl.alphaCtrl.tau.setValue(.1,'s');
                        
                        fltCtrl.perpErrorVal.setValue(.3,'rad')
                        
                        fltCtrl.rudderGain.setValue(-1,'');
                        
                        fltCtrl.yawMoment.kp.setValue(0,'(N*m)/(rad)');
                        
                        fltCtrl.tanRoll.kp.setValue(.8,'(rad)/(rad)');
                        
                        fltCtrl.rollMoment.kp.setValue(80000,'(N*m)/(rad)');
                        fltCtrl.rollMoment.kd.setValue(120000,'(N*m)/(rad/s)');
                        
                        fltCtrl.pitchMoment.kp.setValue(60000,'(N*m)/(rad)');
                        fltCtrl.pitchMoment.ki.setValue(500,'(N*m)/(rad*s)');
                        fltCtrl.pitchMoment.kd.setValue(48000,'(N*m)/(rad/s)');
                        fltCtrl.pitchMoment.tau.setValue(.1,'s');
                    end
                    
                    fltCtrl.Tmax.setValue(Tmax*.95,'kN');
                case 2
                    fltCtrl.maxTL.setValue(hiLvlCtrl.maxThrLength.Value,'m');
                    pthCtrl1.setFcnName(PATHGEOMETRY,'');
                    pthCtrl1.setInitPathVar(vhcl.initPosVecGnd.Value,hiLvlCtrl.basisParams.Value,gndStn.posVec.Value);
                    pthCtrl1.AoASP.setValue(0,'');                           pthCtrl1.AoAConst.setValue(vhcl.optAlpha.Value*pi/180,'deg');
                    pthCtrl1.AoACtrl.setValue(1,'');                         pthCtrl1.Tmax.setValue(Tmax-.5,'kN');
                    pthCtrl1.alphaCtrl.kp.setValue(.2,'(rad)/(kN)');         pthCtrl1.alphaCtrl.ki.setValue(.08,'(rad)/(kN*s)');
                    pthCtrl1.elevCtrl.kp.setValue(125,'(deg)/(rad)');        pthCtrl1.elevCtrl.ki.setValue(1,'(deg)/(rad*s)');
                    pthCtrl1.rollCtrl.kp.setValue(200,'(deg)/(rad)');        pthCtrl1.rollCtrl.ki.setValue(0,'(deg)/(rad*s)');
                    pthCtrl1.rollCtrl.kd.setValue(150,'(deg)/(rad/s)');      pthCtrl1.rollCtrl.tau.setValue(0.001,'s');
                    pthCtrl2.setFcnName(PATHGEOMETRY,'');
                    pthCtrl2.setInitPathVar(vhcl.initPosVecGnd.Value,hiLvlCtrl.basisParams.Value,gndStn.posVec.Value);
                    pthCtrl2.AoASP.setValue(1,'');                           pthCtrl2.AoAConst.setValue(vhcl.optAlpha.Value*pi/180,'deg');
                    pthCtrl2.AoACtrl.setValue(1,'');                         pthCtrl2.Tmax.setValue(Tmax-.5,'kN');
                    pthCtrl2.alphaCtrl.kp.setValue(.2,'(rad)/(kN)');         pthCtrl2.alphaCtrl.ki.setValue(.08,'(rad)/(kN*s)');
                    pthCtrl2.elevCtrl.kp.setValue(125,'(deg)/(rad)');        pthCtrl2.elevCtrl.ki.setValue(1,'(deg)/(rad*s)');
                    pthCtrl2.rollCtrl.kp.setValue(200,'(deg)/(rad)');        pthCtrl2.rollCtrl.ki.setValue(0,'(deg)/(rad*s)');
                    pthCtrl2.rollCtrl.kd.setValue(150,'(deg)/(rad/s)');      pthCtrl2.rollCtrl.tau.setValue(0.001,'s');
                    slfCtrl.LaRelevationSP.setValue(el*180/pi,'deg');        slfCtrl.pitchCtrl.setValue(2,''); slfCtrl.pitchConst.setValue(0,'deg');
                    slfCtrl.pitchAngleMax.upperLimit.setValue(20,'');        slfCtrl.pitchAngleMax.lowerLimit.setValue(-20,'')
                    slfCtrl.winchActive.setValue(0,'');                      slfCtrl.minThrTension.setValue(50,'N');
                case 3
                    fltCtrl.LaRelevationSP.setValue(45,'deg');
                    fltCtrl.pitchCtrl.setValue(2,'');                   fltCtrl.pitchConst.setValue(-10,'deg');
                    elevatorCtrl = 1;   tRef = 0:500:2000;    elevCommand = -2:2;
                case 4
                    fltCtrl.LaRelevationSP.setValue(60,'deg');          fltCtrl.setNomSpoolSpeed(.0,'m/s');
            end
            vhcl.setBuoyFactor(getBuoyancyFactor(vhcl,env,thr),'');
            env.scale(scale,1);
            hiLvlCtrl.scale(scale,1);
            gndStn.scale(scale,1);
            thr.scale(scale,1);
            fltCtrl.scale(scale,1);
            wnch.scale(scale,1);
            vhcl.scale(scale,1);
            vhcl.turb1.scale(scale,1);
            vhcl.turb2.scale(scale,1);
%             thr.tether1.dragEnable.setValue(0,'');
            %%  Set up critical system parameters and run simulation
            fprintf('\nFlow Speed = %.3f m/s;\tTether Length = %.1f m;\t Altitude = %d m;\t ThrD = %.1f mm\n',flwSpd,thrLength,altitude,thrDiam);
            simParams = SIM.simParams;  simParams.setDuration(tFinal,'s');  dynamicCalc = '';
            vhcl.setBuoyFactor(getBuoyancyFactor(vhcl,env,thr),'');
            if ~isnan(el)
                simWithMonitor('OCTModel')
                %%  Log Results
                tsc = signalcontainer(logsout);
                if tsc.lapNumS.Data(end) >= 2
                    dt = datestr(now,'mm-dd_HH-MM');
                    [Idx1,Idx2] = tsc.getLapIdxs(max(tsc.lapNumS.Data)-1);  ran = Idx1:Idx2;
                    [CLtot,CDtot] = tsc.getCLCD(vhcl,thr);
                    [Lift,Drag,Fuse,Thr] = tsc.getLiftDrag;
                    Turb = squeeze(sqrt(sum(tsc.FTurbBdy.Data.^2,1)));
                    Pow = tsc.rotPowerSummary(vhcl,env,thr);
                    R.Pavg(i,j,k) = Pow.avg;
                    R.Pnet(i,j,k) = Pow.net;
                    V = squeeze(sqrt(sum(tsc.velCMvec.Data.^2,1)));
                    R.Vavg(i,j,k) = mean(V(ran));
                    R.AoA(i,j,k) = mean(squeeze(tsc.vhclAngleOfAttack.Data(:,:,ran)));
                    airNode = squeeze(sqrt(sum(tsc.airTenVecs.Data.^2,1)))*1e-3;
                    gndNode = squeeze(sqrt(sum(tsc.gndNodeTenVecs.Data.^2,1)))*1e-3;
                    R.ten(i,j,k) = max([max(airNode(ran)) max(gndNode(ran))]);
                    R.CL(i,j,k) = mean(CLtot(ran));   R.CD(i,j,k) = mean(CDtot(ran));
                    R.Fdrag(i,j,k) = mean(Drag(ran)); R.Flift(i,j,k) = mean(Lift(ran));
                    R.Ffuse(i,j,k) = mean(Fuse(ran)); R.Fthr(i,j,k) = mean(Thr(ran));   R.Fturb(i,j,k) = mean(Turb(ran));
                    R.elevation(i,j,k) = el*180/pi;
                    R.thrL(i,j,k) = thrLength; R.alt(i,j,k) = altitude; R.flw(i,j,k) = flwSpd;
                    filename = sprintf(strcat('CDR_V-%.3f_alt-%.d_thrL-%d_thrD-%.1f_Fair-%d.mat'),flwSpd,altitude,thrLength,thrDiam,fairing);
                    fpath = 'D:\Thr-L Study\';
                    save(strcat(fpath,filename),'tsc','vhcl','thr','fltCtrl','env','simParams','LIBRARY','gndStn')
                else
                    R.Pavg(i,j,k) = NaN;  R.AoA(i,j,k) = NaN;   R.ten(i,j,k) = NaN;
                    R.CL(i,j,k) = NaN;    R.CD(i,j,k) = NaN;    R.Fdrag(i,j,k) = NaN;
                    R.Flift(i,j,k) = NaN; R.Ffuse(i,j,k) = NaN; R.Fthr(i,j,k) = NaN;
                    R.Fturb(i,j,k) = NaN; R.elevation(i,j,k) = el*180/pi; 
                    R.Pnet(i,j,k) = NaN;  R.Vavg(i,j,k) = NaN; 
                    R.thrL(i,j,k) = thrLength; R.alt(i,j,k) = altitude; R.flw(i,j,k) = flwSpd;
                end
            else
                R.Pavg(i,j,k) = NaN;  R.AoA(i,j,k) = NaN;   R.ten(i,j,k) = NaN;
                R.CL(i,j,k) = NaN;    R.CD(i,j,k) = NaN;    R.Fdrag(i,j,k) = NaN;
                R.Flift(i,j,k) = NaN; R.Ffuse(i,j,k) = NaN; R.Fthr(i,j,k) = NaN;
                R.Fturb(i,j,k) = NaN; R.elevation(i,j,k) = el*180/pi;
                R.Pnet(i,j,k) = NaN;  R.Vavg(i,j,k) = NaN;
                R.thrL(i,j,k) = thrLength; R.alt(i,j,k) = altitude; R.flw(i,j,k) = flwSpd;
            end
        end
    end
end

filename1 = sprintf('Pow_Study_CDR_ThrD-%.1f_Fair-%d.mat',thrDiam,fairing);
fpath1 = fullfile(fileparts(which('OCTProject.prj')),'output\');
save([fpath1,filename1],'R','thrLength','fairing','flwSpd','thrDiam','Tmax','altitude')
%%
% filename1 = sprintf('Tmax_Study_AR8b8.mat');
% fpath1 = fullfile(fileparts(which('OCTProject.prj')),'output','Tmax Study\');
% save([fpath1,filename1],'Pavg','AoA','CL','CD','Fdrag','Flift','Ffuse','Fthr',...
%     'Fturb','thrLength','elevation','flwSpd','ten','Tmax','altitude','ii','jj','ll','kk')
