%% Test script for John to control the kite model
clear; clc; close all;
Simulink.sdi.clear
%% Simulation Setup
% 1 - choose vehicle design:        1 = AR8b8, 2 = AR9b9, 3 = AR9b10
% 2 - choose high level controller: 1 = const basis, 2 = variable alt, 3 = const basis/state flow
% 3 - choose flight controller:     1 = pathFlow, 2 = full cycle, 3 = steady, 4 = reel-in
% 4 - choose tether:                1 = Single link, 2 = Reel-in, 3 = Multi-node, 4 = Faired, 5 = Multi-node faired
% 5 - choose environment:           1 = const flow, 2 = variable flow.
% 6 - save simulation results
% 7 - animate
% 8 - plotting
%%             1 2 3 4 5  6    7     8
simScenario = [1 1 1 5 1 false false 1==1];
flwArray = .25;[.1:.05:.5];
altArray = 150;[50:50:424];
thrArray = 300;[200:100:600];
tDiamArray = 13.6;% [12.4 10.6 9.4];
TmaxArray = 12;% [9.5 6.8 5.4];
% thrArray = 80;[80 110 140];
% tDiamArray = 12.7;[12.7 11.3 10.4];
% TmaxArray = 10.6;[10.6 9.0 8.0]*2;
scale = 1;
q = 1
for i = 1:numel(flwArray)
    for j = 1:numel(thrArray)
        for k = 1:numel(altArray)
        Simulink.sdi.clear
        thrLength = thrArray(j)/scale;  altitude = altArray(k);                           %   m/m - Nominal tether length/operating altitude
        initTL = thrLength;200;      initAltitude = altitude;100;                      %   m/m - Initial tether length/operating altitude
        flwSpd = flwArray(i)/scale^0.5;                                               %   m/s - Flow speed
        Tmax = TmaxArray/scale^3;        Tdiam = tDiamArray/scale;                               %   kN/mm - Max tether tension/tether diameter
        h = 10*pi/180;  w = 40*pi/180;                              %   rad - Path width/height
        [a,b] = boothParamConversion(w,h);                          %   Path basis parameters
        subCtrl = 1;    sC = 0;
        TD = 1; tf = 2500;
        fairing = 100;   AoAsp = 14;
        if altitude >= 0.7071*thrLength || altitude <= 0.1736*thrLength
            fprintf('Elevation angle is out of range\n')
            peakAug(i,j,k) = NaN;
            lapAvgPow(i,j,k) = NaN;
            tenMax(i,j,k) = NaN;
            continue
        end
        %%  Load components
        switch simScenario(1)                                   %   Vehicle
            case 1
                loadComponent('Manta2RotXFoil_AR8_b8');             %   AR = 8; 8m span
            case 2
                loadComponent('Manta2RotXFoil_AR9_b9');             %   AR = 9; 9m span
            case 3
                loadComponent('Manta2RotXFoil_AR9_b10');            %   AR = 9; 10m span
        end
        switch simScenario(2)                                   %   Flight Controller
            case 1
                loadComponent('constBoothLem');                     %   Constant basis parameters
                el = asin(altitude/thrLength);                      %   rad - Initial elevation angle
                hiLvlCtrl.basisParams.setValue([a,b,el,0*pi/180,... %   Initialize basis parameters
                    thrLength],'[rad rad rad rad m]');
            case 2
                loadComponent('varAltitudeBooth');                  %   Variable altitude controller
                el = asin(altitude/thrLength);                      %   rad - Initial elevation angle
                hiLvlCtrl.basisParams.setValue([a,b,el,0*pi/180,... %   Initialize basis parameters
                    thrLength],'[rad rad rad rad m]');
                hiLvlCtrl.ELctrl.setValue(1,'');
                hiLvlCtrl.ELslew.setValue(0.25,'deg/s');
                hiLvlCtrl.ThrCtrl.setValue(1,'');
            case 3
                loadComponent('mantaFSHiLvl');                     %   Constant basis parameters
                el = asin(altitude/thrLength);                      %   rad - Initial elevation angle
                hiLvlCtrl.stateCtrl.setValue(sC,'');
                hiLvlCtrl.stateConst.setValue(subCtrl,'');
                hiLvlCtrl.preXelevation.setValue(max(el-h,5*pi/180),'rad')
                hiLvlCtrl.initXelevation.setValue(max(el-h/2,5*pi/180),'rad')
                m = (hiLvlCtrl.preXelevation.Value-pi/2)/hiLvlCtrl.maxThrLength.Value;
                %         initEL = m*initTL+pi/2;                      %   rad - Initial elevation angle
                initEL = asin(initAltitude/initTL);                      %   rad - Initial elevation angle
                %         hiLvlCtrl.basisParams.setValue([a,b,el,0*pi/180,... %   Initialize basis parameters
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
                %         pthCtrl2.fcnName.setValue('ellipse','');
                loadComponent('LaRController');                     %   Launch and recovery controller
                slfCtrl = fltCtrl;
                loadComponent('MantaFSController');                 %   Path-following controller with AoA control
            case 3
                %         loadComponent('SteadyController');                  %   Steady-flight controller
                load('C:\Users\andre\Documents\OCT\DoEOceanKiteProject\compositions\flightController\launchRecoveryController\library\SteadyController\SteadyController.mat')
                fltCtrl.rollMoment.kp.setValue(1000,'(N*m)/(rad)')
                fltCtrl.rollMoment.ki.setValue(0,'(N*m)/(rad*s)');
                fltCtrl.rollMoment.kd.setValue(1000,'(N*m)/(rad/s)');
                fltCtrl.rollMoment.tau.setValue(0.001,'s');
                fltCtrl.yawMoment.kp.setValue(0,'(N*m)/(rad)');
                fltCtrl.rudderGain.setValue(-1,'')
                fltCtrl.LaRelevationSP.setValue(20,'deg');
                fltCtrl.pitchCtrl.setValue(2,'');
            case 4
                loadComponent('LaRController');                     %   Launch and recovery controller
        end
        switch simScenario(4)                                   %   Tether model
            case 1
                loadComponent('MantaTether');                       %   Manta Ray tether
            case 2
                loadComponent('shortTether');                       %   Tether for reeling
                thr.tether1.setInitTetherLength(initTL,'m');     %   Initialize tether length
            case 3
                loadComponent('MantaTetherReal');                       %   Manta Ray tether
                %         thr.setNumNodes(11,'');
            case 4
                loadComponent('MantaFSTether');
                thr.initTetherLength.setValue(initTL,'m')%   Manta Ray tether
            case 5
                loadComponent('fairedNNodeTether');                       %   Manta Ray tether
                thr.tether1.diameter.setValue(Tdiam*10^-3,'m')
        end
        switch simScenario(5)                                   %   Environment
            case 1
                loadComponent('ConstXYZT');                         %   Constant flow
                ENVIRONMENT = 'env2turb';               %   Two turbines
                env.water.setflowVec([flwSpd 0 0],'m/s');           %   m/s - Flow speed vector
            case 2
                loadComponent('ConstYZTvarX');                      %   Variable X
                ENVIRONMENT = 'env2turb';               %   Two turbines
                env.water.setflowVec([flwSpd 0 0],'m/s');           %   m/s - Flow speed vector
        end
        loadComponent('oneDoFGSCtrlBasic');                         %   Ground station controller
        loadComponent('MantaGndStn');                               %   Ground station
        loadComponent('winchManta');                                %   Winches
        loadComponent('idealSensors')                               %   Sensors
        loadComponent('idealSensorProcessing')                      %   Sensor processing
        
        
        
        %%  Vehicle Initial Conditions
        if simScenario(3) == 1
            vhcl.setICsOnPath(0.05,PATHGEOMETRY,hiLvlCtrl.basisParams.Value,gndStn.posVec.Value,4*flwSpd)
        else
            vhcl.setICsOnPath(0,PATHGEOMETRY,hiLvlCtrl.basisParams.Value,gndStn.posVec.Value,0)
            vhcl.setInitEulAng([0,0,0]*pi/180,'rad')
        end
        %%  Tethers Properties
        if simScenario(4)~=4
            thr.tether1.initGndNodePos.setValue(gndStn.thrAttch1.posVec.Value(:)+gndStn.posVec.Value(:),'m');
            thr.tether1.initAirNodePos.setValue(vhcl.initPosVecGnd.Value(:)...
                +rotation_sequence(vhcl.initEulAng.Value)*vhcl.thrAttchPts_B.posVec.Value,'m');
            thr.tether1.initGndNodeVel.setValue([0 0 0]','m/s');
            thr.tether1.initAirNodeVel.setValue(vhcl.initVelVecBdy.Value(:),'m/s');
            thr.tether1.vehicleMass.setValue(vhcl.mass.Value,'kg');
            if simScenario(4) == 5
                thr.tether1.fairedLength.setValue(fairing,'m');
                thr.tether1.maxThrLength.setValue(thrLength,'m');
            end
            thr.tether1.diameter.setValue(Tdiam*10^-3,'m')
        else
            thr.initGndNodePos.setValue(gndStn.thrAttch1.posVec.Value(:)+gndStn.posVec.Value(:),'m');
            thr.initAirNodePos.setValue(vhcl.initPosVecGnd.Value(:)...
                +rotation_sequence(vhcl.initEulAng.Value)*vhcl.thrAttchPts_B.posVec.Value,'m');
            thr.initGndNodeVel.setValue([0 0 0]','m/s');
            thr.initAirNodeVel.setValue(vhcl.initVelVecBdy.Value(:),'m/s');
            %     thr.initTetherLength.setValue(initTL,'m')
        end
        %%  Winches Properties
        vhcl.hStab.CL.setValue(vhcl.hStab.alpha.Value*0.02156+.04334,'')
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
                    %
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
        
        % vhcl.setBuoyFactor(getBuoyancyFactor(vhcl,env,thr),'');
        %%  Set up critical system parameters and run simulation
        simParams = SIM.simParams;  simParams.setDuration(tf,'s');  dynamicCalc = '';

        simWithMonitor('OCTModel')
        %%  Log Results
        tsc = signalcontainer(logsout);
        if simScenario(3) == 1
            Pow = tsc.rotPowerSummary(vhcl,env,thr);
            [Idx1,Idx2] = tsc.getLapIdxs(max(tsc.lapNumS.Data)-1);  ran = Idx1:Idx2;
            AoA = mean(squeeze(tsc.vhclAngleOfAttack.Data(:,:,ran)));
            airNode = squeeze(sqrt(sum(tsc.airTenVecs.Data.^2,1)))*1e-3;
            gndNode = squeeze(sqrt(sum(tsc.gndNodeTenVecs.Data.^2,1)))*1e-3;
            ten = max([max(airNode(ran)) max(gndNode(ran))]);
            fprintf('Average AoA = %.3f;\t Max Tension = %.1f kN\n\n',AoA,ten);
        end
        switch simScenario(3)
            case 1
                filename = sprintf(strcat('Turb_V-%.2f_Alt-%d_thr-%d_Tmax-%d.mat'),flwSpd,altitude,thrLength,Tmax);
%                 filename = sprintf(strcat('Turb_Scale-%.3f_Diam-%.1f_thr-%.2f_Tmax-%.2f.mat'),scale,thr.tether1.diameter.Value*10^3,thrLength*scale,fltCtrl.Tmax.Value/.95)
%                 fpath = fullfile(fileparts(which('OCTProject.prj')),'Results','Manta 2.0','Rotor\');
            case 2
                filename = sprintf(strcat('FS_V-%.3f_Alt-%d_thr-%d_Tmax-%d_FL-%d.mat'),flwSpd,altitude,thrLength,Tmax,thr.fairingLength.Value);
                fpath = 'C:\Users\jborek\Documents\MATLAB\Manta Results';
            case 3
                filename = sprintf(strcat('Steady_EL-%.1f_kp-%.2f_ki-%.2f.mat'),el*180/pi,fltCtrl.elevCmd.kp.Value,fltCtrl.elevCmd.ki.Value);
                fpath = fullfile(fileparts(which('OCTProject.prj')),'Results','Manta 2.0','Steady\');
            case 4
                filename = sprintf(strcat('LaR_V-%.3f_EL-%.1f_SP-%.1f_Wnch-%.1f.mat'),flwSpd,el*180/pi,fltCtrl.LaRelevationSP.Value,fltCtrl.nomSpoolSpeed.Value);
                fpath = fullfile(fileparts(which('OCTProject.prj')),'Results','Manta 2.0','LaR\');
        end
        if simScenario(6)
                save(strcat('output/powStudy/',filename),'tsc','vhcl','thr','fltCtrl','env','simParams','LIBRARY','gndStn')
%             save(strcat('output/powStudy/',filename),'tsc','vhcl','thr','fltCtrl','env','simParams','LIBRARY','gndStn')
        end
        %%  Plot Results
        if simScenario(8)
            switch simScenario(3)
                case 1
                    lap = max(tsc.lapNumS.Data)-1;
                    if max(tsc.lapNumS.Data) < 2
                        tsc.plotFlightResults(vhcl,env,thr,'plot1Lap',1==0,'plotS',1==0,'lapNum',lap,'dragChar',1==0,'cross',1==0)
                    else
                        tsc.plotFlightResults(vhcl,env,thr,'plot1Lap',1==1,'plotS',1==1,'lapNum',lap,'dragChar',1==0,'cross',1==0)
                    end
                case 2
                    tsc.plotFSslf(fltCtrl,'Steady',true);
                case 3
                    tsc.plotLaR(fltCtrl,'Steady',true);
                case 4
                    tsc.plotLaR(fltCtrl,'Steady',true);
            end
        end
        % set(gcf,'OuterPosition',[-773.4000   34.6000  780.8000  830.4000]);
        %%  Animate Simulation
        if simScenario(7)
            if simScenario(3) == 1
                vhcl.animateSim(tsc,10,'PathFunc',fltCtrl.fcnName.Value,'TracerDuration',20,...
                    'GifTimeStep',.01,'PlotTracer',true,'FontSize',12,'Pause',1==0,...
                    'ZoomIn',1==0,'SaveGif',1==0,'GifFile',strrep(filename,'.mat','.gif'));
            elseif simScenario(3) == 2
                vhcl.animateSim(tsc,2,'PathFunc',pthCtrl2.fcnName.Value,'TracerDuration',20,...
                    'GifTimeStep',.01,'PlotTracer',true,'FontSize',12,'Pause',1==0,...
                    'ZoomIn',1==0,'SaveGif',1==0,'GifFile',strrep(filename,'.mat','.gif'));
            else
                vhcl.animateSim(tsc,2,'View',[0,0],'Pause',1==0,...
                    'GifTimeStep',.05,'PlotTracer',true,'FontSize',12,'ZoomIn',1==0,...
                    'SaveGif',1==0,'GifFile',strrep(filename,'.mat','zoom.gif'));
            end
        end
        plotVelMags
        hold on
        plot(tsc.tanRollDes)
        
        vel = tsc.velCMvec.getsampleusingtime(100,tsc.velCMvec.Time(end));
        vels = squeeze(vel.Data);
        velmags = sqrt(sum((vels).^2,1));
        peakAug(i,j,k) = max(velmags)/(flwSpd*scale^(1/2));
        lapAvgPow(i,j,k) = Pow.avg;
        tenMax(i,j,k) = ten;
        figure(1); hold on; grid on;
        plot(q/360,q/360)
        xlim([0 1])
        q = q+1
    end
    end
end

figure
plot(tsc.airTenVecs.Time,gndNode,'DisplayName','Tether Tension','LineWidth',1.5)
hold on;
line([1000 1000],[0 14],'DisplayName','Failure Point','Color','r','LineWidth',1.5)
line([0 2000],[12 12],'DisplayName','Tension Limit','Color','k','LineWidth',1.5,'LineStyle','--')
legend('Location','southeast')
xlabel 'Time [s]'
ylabel 'Tether Tension [kN]'
set(gca,'FontSize',15)
xlim([0 2000])

figure
plot(thrArray,peakAug,'x')
xlabel 'Tether Length [m]'
ylabel 'Peak Velocity Augmentation'

figure
plot(thrArray,lapAvgPow,'x')
xlabel 'Tether Length [m]'
ylabel 'Peak Velocity Augmentation'

for i = 1:numel(flwArray)
    for j = 1:numel(thrArray)
        for k = 1:numel(altArray)
            if tenMax(i,j,k) > 12.2
                peakAugProc(i,j,k) = NaN;
                tenMaxProc(i,j,k) = NaN;
                lapAvgPowProc(i,j,k) = NaN;
            else
                peakAugProc(i,j,k) = peakAug(i,j,k);
                tenMaxProc(i,j,k) = tenMax(i,j,k);
                lapAvgPowProc(i,j,k) = lapAvgPow(i,j,k);
            end
        end
    end
end
flwArray = [.1:.05:.5];
altArray = [50:50:424];
thrArray = [200:100:600];
lapAvgPowAlt = squeeze(max(lapAvgPowProc,[],2));
lapAvgPowAlt(1,7) = NaN;
lapAvgPowAlt(1,8) = NaN;

figure
[X,Y]=meshgrid(altArray,flwArray)
%%
contour(X,Y,lapAvgPowAlt,[0:.05:.2 .3:.1:1],'Fill','on','ShowText','on')
xlabel 'Altitude [m]'
ylabel 'Flow Speed [m/s]'
