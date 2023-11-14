clear all;
clc;
% close all;
Simulink.sdi.clear

saveSim=0;%Binary flag to save sim results
animateFlag=1;% Binary flag to shown an animation post-sim

%Simulation sweep parameters (all of these can be vectors to simulate multiple scenerios sequentially)
thrSweep = 500;%Tether Lengths to Sweep Through
altSweep = 250;%Altitudes to sweep through
flwSweep = 1;%Flow Speed to simulate

%Create empty vectors to populate with sim results
x = meshgrid(thrSweep,altSweep,flwSweep);
[n,m,r] = size(x);
numCase = n*m*r;
powGen = zeros(n,m,r);
pathErr = zeros(n,m,r);
dragRatio = zeros(n,m,r);
Pow = cell(n,m,r);

fpath = 'C:\Users\';%Save Path for simulations

%Make save directory if it does not exist
if ~exist(fpath,'dir') && saveSim
    mkdir(fpath)

end

%Sweep through all the simulation scenarios
for i = 1:n
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
            %Print sim sweep progress
            fprintf(sprintf('%.2f Percent Complete\n',((i-1)*m*r+(j-1)*r+k)/(n*m*r)*100))
            Simulink.sdi.clear
            %%  Set Test Parameters
            tFinal = 1000;      tSwitch = 10000;                        %   s - maximum sim duration
            flwSpd = flwSweep(k);                                              %   m/s - Flow speed
            altitude = altSweep(i);                        %   m/m - cross-current and initial altitude
            thrLength = thrSweep(j);    initThrLength =  thrSweep(j);
            el = asin(altitude/thrLength);                              %   rad - Initial elevation angle
           
       
                b = 20; %Figure-8 Path Height
                a = 60;%Figure-8 Width

            %% Load vehicle model
            loadComponent('ultDoeKite');
            VEHICLE = 'vhcl4turb';%use 'vhcl2turb' for vehicles with 2 turbines
            %% Load Flight Controller
            loadComponent('constBoothLem'); %Select path geomwtry as figure-8
            hiLvlCtrl.basisParams.setValue([a,b,altitude,0*pi/180,... %   Initialize basis parameters
                thrLength],'[rad rad rad rad m]');

            loadComponent('pathFollowWithAoACtrlDOE');             %   Path-following controller with AoA control
            loadComponent('pathFollowingTether');                       %   Load tether model
            
            %% Load and initalize tether

            %Set number of thr nodes
            thr.numNodes.setValue(max([10 thrLength/200]),'');
            thr.tether1.numNodes.setValue(max([10 thrLength/200]),'');
            %Set tether physical properties
            thr.tether1.setDensity(1000,'kg/m^3')
            thr.tether1.diameter.setValue(0.022,'m')
            %% Load Enviornment
            loadComponent('ConstXYZT');                         %   Constant flow
            ENVIRONMENT = 'env4turb';                           %   Four turbines
            env.water.setflowVec([flwSpd 0 0],'m/s');           %   m/s - Flow speed vector
            %% Loag Ground Station and Gnd Stn Controller
            loadComponent('oneDoFGSCtrlBasic');                         %   Ground station controller
            loadComponent('oneThrGndStn000');    
            GROUNDSTATION = 'GroundStation000'%   Ground station
            loadComponent('oneWnch');  
            WINCH = 'constThr'%   Winches
            %% Load Sensor Processing and sensors
            loadComponent('idealSensors')                               %   Sensors
            loadComponent('idealSensorProcessing')                      %   Sensor processing
            %             SENSORS = 'deadRecPos'
            %%  Vehicle Initial Conditions
            PATHGEOMETRY = 'lemBoothNew';   % Set desired path shape (figure-8)
            
            %Initalize vehicle states
            vhcl.setICsOnPath(0.875,PATHGEOMETRY,hiLvlCtrl.basisParams.Value,gndStn.posVec.Value,3*flwSpd)

            %%  Tether
            % Initalize tether position
            thr.tether1.initGndNodePos.setValue(gndStn.thrAttch1.posVec.Value(:)+gndStn.posVec.Value(:),'m');
            thr.tether1.initAirNodePos.setValue(vhcl.initPosVecGnd.Value(:)...
                +rotation_sequence(vhcl.initEulAng.Value)*vhcl.thrAttchPts_B.posVec.Value,'m');
            thr.tether1.initGndNodeVel.setValue([0 0 0]','m/s');
            thr.tether1.initAirNodeVel.setValue(rotation_sequence(vhcl.initEulAng.Value)*vhcl.initVelVecBdy.Value(:),'m/s');
            
            %Set Tether properties
            thr.tether1.vehicleMass.setValue(vhcl.mass.Value,'kg');
            thr.tether1.dragCoeff.setValue(1.2,'');
            %%  Winches Properties
            %Initalize winch
            wnch.setTetherInitLength(vhcl,gndStn.posVec.Value,env,thr,env.water.flowVec.Value);
            %%  Controller User Def. Parameters and dependant properties
            fltCtrl.setFcnName(PATHGEOMETRY,'');
            fltCtrl.setInitPathVar(vhcl.initPosVecGnd.Value,hiLvlCtrl.basisParams.Value,gndStn.posVec.Value);

            
            %%  Set up critical system parameters
            simParams = SIM.simParams;  simParams.setDuration(tFinal,'s');  dynamicCalc = '';
            progress = sprintf('%d Thr %.1f Altitude %.2f Flow Speed\n',...
                thrLength,altitude,flwSpd);
            fprintf(progress)
            %% Run Simulation
            simWithMonitor('OCTModel','timeStep',2,'minRate',0.1)
            %%  Log Results
            tsc = signalcontainer(logsout);%Log simulation data
            lap = max(tsc.lapNumS.Data)-1;%# of laps flown 
            
            %% Log data for sweep
                Pow{i,j,k} = tsc.rotPowerSummary(vhcl,env,thr);
                [Idx1,Idx2,lapCheck] = tsc.getLapIdxs(max(tsc.lapNumS.Data)-1);  ran = Idx1:Idx2;
                AoA = mean(squeeze(tsc.vhclAngleOfAttack.Data(:,:,ran)));
                airNode = squeeze(sqrt(sum(tsc.airTenVecs.Data.^2,1)))*1e-3;
                gndNode = squeeze(sqrt(sum(tsc.gndNodeTenVecs.Data.^2,1)))*1e-3;
                ten = max([max(airNode(ran)) max(gndNode(ran))]);
                fprintf('Average AoA = %.3f;\t Max Tension = %.1f kN\n\n',AoA,ten);
            
            %% Save simulation data

                filename = sprintf(strcat('PathFollow_V-%.2f_Alt-%d_thr-%d.mat'),flwSpd,altitude,thrLength);            
           
                if saveSim
                save(strcat(fpath,filename),'tsc','vhcl','thr','fltCtrl','env','simParams','LIBRARY','gndStn')
                end
        end
    end
end

%% Animate Simulation
if animateFlag
    vhcl.animateSim(tsc,2,'tracerDuration',100)
end
