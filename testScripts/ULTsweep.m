%% Test script for John to control the kite model
clear all;
clc;
% close all;
Simulink.sdi.clear
%% Simulation Setup
% 1 - Vehicle Model:         1 = AR8b8, 2 = AR9b9, 3 = AR9b10
% 2 - High-level Controller: 1 = const basis, 2 = const basis/stategit  flow
% 3 - Flight controller:     1 = pathFlow, 2 = full cycle
% 4 - Tether Model:          1 = Single link, 2 = Reel-in, 3 = Multi-node, 4 = Multi-node faired
% 5 - Environment:           1 = const flow, 2 = variable flow
% 6 - Save Results
% 7 - Animate
% 8 - Plotting
%%             1 2 3 4 5 6     7     8
simScenario = [1 1 1 3 1 1==0  1==0 1==1];
thrSweep = 600%[400 600 800:400:4800]%200:50:600;
altSweep = 300%thrSweep/2%50:50:450;
tauLim = 35
defl = -1
flwSweep = 1%0.5:-0.05:0.15;
x = meshgrid(thrSweep,altSweep,flwSweep);
[n,m,r] = size(x);
numCase = n*m*r;
powGen = zeros(n,m,r);
pathErr = zeros(n,m,r);
dragRatio = zeros(n,m,r);
Pow = cell(n,m,r);
fpath = 'C:\Users\adabney\Documents\Results\longTetherStudy04-08-2022\';
%%
if ~exist(fpath,'dir')
    mkdir(fpath)
else
    if simScenario(6)
        fprintf(['These Sims are set to save. Do you want to save even if it may overwrite existing data']);
        str = input('(Y/N): \n','s');
        if isempty(str)
            str = 'Y';
        end
        if ~strcmpi(str,'Y')
            simScenario(6) = (1==0);
        end
    else
    end
end
tauRPM = 0
for i = 1:2
    if i < 1
        continue
    end
    for j = 1:m
        if j < 1
            continue
        end
        for k = 1:r
            if k < 1
                continue
            end
            
            fprintf(sprintf('%.2f Percent Complete\n',((i-1)*m*r+(j-1)*r+k)/(n*m*r)*100))
            Simulink.sdi.clear
            %%  Set Test Parameters
            tFinal = 1000;      tSwitch = 10000;                        %   s - maximum sim duration
            flwSpd = flwSweep(k);                                              %   m/s - Flow speed
            altitude = 300;%altSweep(i);     initAltitude = 100;                     %   m/m - cross-current and initial altitude
            thrLength = thrSweep(j);    initThrLength = 200;
            el = asin(altitude/thrLength);                              %   rad - Initial elevation angle
            if i == 1
                b = 20;
                a = 60;
            else
                b = 40;
                a = 200;
            end
            
            loadComponent('ultDoeKite')
            VEHICLE = 'vhcl4turb'
            loadComponent('constBoothLem');
            hiLvlCtrl.basisParams.setValue([a,b,el,0*pi/180,... %   Initialize basis parameters
                thrLength],'[rad rad rad rad m]');
            
            loadComponent('pathFollowWithAoACtrlDOE');             %   Path-following controller with AoA control
            loadComponent('pathFollowingTether');                       %   Manta Ray tether
            thr.numNodes.setValue(max([10 thrLength/200]),'');
            thr.tether1.numNodes.setValue(max([10 thrLength/200]),'');
            thr.tether1.setDensity(1000,'kg/m^3')
            thr.tether1.diameter.setValue(0.022,'m')
            loadComponent('ConstXYZT');                         %   Constant flow
            ENVIRONMENT = 'env4turb';                           %   Two turbines
            env.water.setflowVec([flwSpd 0 0],'m/s');           %   m/s - Flow speed vector
            loadComponent('oneDoFGSCtrlBasic');                         %   Ground station controller
            loadComponent('oneThrGndStn000');    
            GROUNDSTATION = 'GroundStation000'%   Ground station
            loadComponent('oneWnch');  
            WINCH = 'constThr'%   Winches
            loadComponent('idealSensors')                               %   Sensors
            loadComponent('idealSensorProcessing')                      %   Sensor processing
            %             SENSORS = 'deadRecPos'
            %%  Vehicle Initial Conditions
                                 %   Constant basis parameters
            PATHGEOMETRY = 'lemBoothNew';
            if simScenario(3) == 1
                if simScenario(2) == 4
                    vhcl.setICsOnPath(0.875,PATHGEOMETRY,hiLvlCtrl.initBasisParams.Value,gndStn.posVec.Value,3*flwSpd)
                else
                    vhcl.setICsOnPath(0.875,PATHGEOMETRY,hiLvlCtrl.basisParams.Value,gndStn.posVec.Value,3*flwSpd)
                end
            else
                vhcl.setICsOnPath(0,PATHGEOMETRY,hiLvlCtrl.basisParams.Value,gndStn.posVec.Value,0)
                vhcl.setInitEulAng([0,0,0]*pi/180,'rad')
            end
            %%  Tethers Properties
            %   kN - candidate tether tension limits
            thr.tether1.initGndNodePos.setValue(gndStn.thrAttch1.posVec.Value(:)+gndStn.posVec.Value(:),'m');
            thr.tether1.initAirNodePos.setValue(vhcl.initPosVecGnd.Value(:)...
                +rotation_sequence(vhcl.initEulAng.Value)*vhcl.thrAttchPts_B.posVec.Value,'m');
            thr.tether1.initGndNodeVel.setValue([0 0 0]','m/s');
            thr.tether1.initAirNodeVel.setValue(rotation_sequence(vhcl.initEulAng.Value)*vhcl.initVelVecBdy.Value(:),'m/s');
            thr.tether1.vehicleMass.setValue(vhcl.mass.Value,'kg');
            thr.tether1.dragCoeff.setValue(1.2,'')
            %%  Winches Properties
            wnch.setTetherInitLength(vhcl,gndStn.posVec.Value,env,thr,env.water.flowVec.Value);
%             wnch.winch1.LaRspeed.setValue(1,'m/s');
            %%  Controller User Def. Parameters and dependant properties
            fltCtrl.setFcnName(PATHGEOMETRY,'');
            if simScenario(2) == 4
                fltCtrl.setInitPathVar(vhcl.initPosVecGnd.Value,hiLvlCtrl.initBasisParams.Value,gndStn.posVec.Value);
            else
                fltCtrl.setInitPathVar(vhcl.initPosVecGnd.Value,hiLvlCtrl.basisParams.Value,gndStn.posVec.Value);
            end
            
            %%  Set up critical system parameters and run simulation
            simParams = SIM.simParams;  simParams.setDuration(tFinal,'s');  dynamicCalc = '';
            progress = sprintf('%d Thr %.1f Altitude %.2f Flow Speed\n',...
                thrLength,altitude,flwSpd);
            fprintf(progress)
            simWithMonitor('OCTModel','timeStep',2,'minRate',1)
            %%  Log Results
            tsc = signalcontainer(logsout);
%             tsc = tsc.resample(0:0.1:tsc.positionVec.Time(end));
            %             plotRotorInfo
            lap = max(tsc.lapNumS.Data)-1;
            %             tsc.plotFlightResults(vhcl,env,thr,'plot1Lap',1==0,'plotS',1==0,'lapNum',lap,'dragChar',1==0,'cross',1==0)
            if simScenario(3) == 1
                Pow{i,j,k} = tsc.rotPowerSummary(vhcl,env,thr);
                [Idx1,Idx2,lapCheck] = tsc.getLapIdxs(max(tsc.lapNumS.Data)-1);  ran = Idx1:Idx2;
                AoA = mean(squeeze(tsc.vhclAngleOfAttack.Data(:,:,ran)));
                airNode = squeeze(sqrt(sum(tsc.airTenVecs.Data.^2,1)))*1e-3;
                gndNode = squeeze(sqrt(sum(tsc.gndNodeTenVecs.Data.^2,1)))*1e-3;
                ten = max([max(airNode(ran)) max(gndNode(ran))]);
                fprintf('Average AoA = %.3f;\t Max Tension = %.1f kN\n\n',AoA,ten);
            end
            if i == 1
                filename = sprintf(strcat('ConstAlt_V-%.2f_Alt-%d_thr-%d.mat'),flwSpd,altitude,thrLength);
            else
                filename = sprintf(strcat('BPConstAlt_V-%.2f_Alt-%d_thr-%d.mat'),flwSpd,altitude,thrLength);            end
            if simScenario(6)
                save(strcat(fpath,filename),'tsc','vhcl','thr','fltCtrl','env','simParams','LIBRARY','gndStn')
            end
        end
    end
end

