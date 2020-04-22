
% Hs = .27   % meters
% tp = 3; % seconds
% w =   2*pi/tp % rad/s
% k = (2*pi)/(8.5)%(w^2)/9.81 %rad/m

% Hs = 1.5;   % meters
% tp = 5.7; % seconds
% w =   2*pi/tp % rad/s
% k = (2*pi)/(33.8)%(w^2)/9.81 %rad/m
% Hs = 4.1;   % meters
% tp = 8.6; % seconds
% w =   2*pi/tp % rad/s
% k = (2*pi)/(78.5)%(w^2)/9.81 %rad/m


periodMat   = [ 9.2573,8.0477 7.9768, 8.4078, 8.6392,  9.4451, 10.1592,10.8998,11.7373,12.1387, 12.5184,12.9651];
Amplitudes  = [0.4404, 0.7794, 1.2161,1.7149,2.2178,2.7202,3.2127, 3.7207,4.2114,4.7203,5.2046,6.1315];
Frequencies =  (2*pi)./(periodMat);
waveNumber  =  (Frequencies.^2)/9.81;
tetherL = [125,200];
flowSpeeds = [1,2];

for kk = 1:1
    for jj = 1:12
        for ii = 1:1
            
            % %% Script to run ILC path optimization
            clearvars -except 'Amplitudes' 'Frequencies' 'waveNumber' 'ii' 'jj'  'powerMatSaverKiteBigStationTurbHS' 'kk' 'tetherL'  'flowSpeeds'
            clc;close all
            simParams = SIM.simParams;
            simParams.setDuration(1000,'s');
            dynamicCalc = '';
            
            %% Load components
            % Flight Controller
            % loadComponent('pathFollowingCtrlAddedMass');
            loadComponent('pathFollowingCtrlForILC');
            fltCtrl.rudderGain.setValue(0,'')
            SPOOLINGCONTROLLER = 'netZeroSpoolingController';
            % Ground station controller
            loadComponent('oneDoFGSCtrlBasic');
            % High level controller
            loadComponent('constBoothLem');
            % Ground station
            loadComponent('pathFollowingGndStn');
            % Winches
            loadComponent('oneDOFWnch');
            % Tether
            loadComponent('pathFollowingTether');
            % Sensors
            loadComponent('idealSensors')
            % Sensor processing
            loadComponent('idealSensorProcessing')
            % Vehicle
            loadComponent('fullScale1thr');
            % loadComponent('pathFollowingVhclForComp')
            
            % Environment
            % loadComponent('CNAPsNoTurbJosh');
             loadComponent('CNAPsTurbJames');
             FLOWCALCULATION = 'combinedHighLowFreqDataPlanarWave';
             env.addFlow({'waterWave'},{'planarWaves'});
             env.waterWave.setNumWaves(2,'');
             env.waterWave.build;
            % loadComponent('CNAPsTurbMitchell');
%             loadComponent('ConstXYZT');
%             loadComponent('hurricaneSandyWave')
            
            
          env.waterWave.waveParamMat.setValue([waveNumber(jj),Frequencies(jj),Amplitudes(jj) ,0;0,0,0,0],'')
%            env.waterWave.waveParamMat.setValue([0,0,0 ,0;0,0,0,0],'')
%             env.water.setflowVec([flowSpeeds(kk) 0 0],'m/s')
            
            %% Set basis parameters for high level controller
            % hiLvlCtrl.initBasisParams.setValue([0.8,1.4,-20*pi/180,0*pi/180,125],'[]') % Lemniscate of Booth
            hiLvlCtrl.basisParams.setValue([1.2,2.2,-.36,0*pi/180,tetherL(ii)],'[rad rad rad rad m]') % Lemniscate of Booth
            %% Ground Station IC's and dependant properties
            gndStn.setPosVec([0 0 200],'m')
            gndStn.initAngPos.setValue(0,'rad');
            gndStn.initAngVel.setValue(0,'rad/s');
            
            %% Set vehicle initial conditions
            vhcl.setICsOnPath(...
                0,... % Initial path position
                PATHGEOMETRY,... % Name of path function
                hiLvlCtrl.basisParams.Value,... % Geometry parameters
                gndStn.posVec.Value,... % Center point of path sphere
                (11/2)*norm([ 1 0 0 ])) % Initial speed
            
            %% Tethers IC's and dependant properties
            thr.tether1.initGndNodePos.setValue(gndStn.thrAttch1.posVec.Value(:)...
                +gndStn.posVec.Value(:),'m');
            thr.tether1.initAirNodePos.setValue(vhcl.initPosVecGnd.Value(:)...
                +rotation_sequence(vhcl.initEulAng.Value)*vhcl.thrAttchPts_B.posVec.Value,'m');
            
            thr.tether1.initGndNodeVel.setValue([0 0 0]','m/s');
            thr.tether1.initAirNodeVel.setValue(vhcl.initVelVecBdy.Value(:),'m/s');
            
            thr.tether1.vehicleMass.setValue(vhcl.mass.Value,'kg');
            %% Winches IC's and dependant properties
            wnch.setTetherInitLength(vhcl,gndStn.posVec.Value,env,thr,[1 0 0 ]');
            
            %% Controller User Def. Parameters and dependant properties
            fltCtrl.setFcnName(PATHGEOMETRY,''); % PATHGEOMETRY is defined in fig8ILC_bs.m
            % vhcl.addedMass.setValue(zeros(3,3),'kg')
            fltCtrl.setInitPathVar(vhcl.initPosVecGnd.Value,...
                hiLvlCtrl.basisParams.Value,...
                gndStn.posVec.Value);
            simWithMonitor('OCTModel')
            tsc = signalcontainer(logsout);
            
            
            try
                load('pow.mat')
                
                powerMatSaverKiteBigStationTurbHS(ii,jj,kk) = powAvg;
                
                save('powerMatSaverKiteBigStationTurbHS.mat',' powerMatSaverKiteBigStationTurbHS')
            catch
            end
            
            
        end
    end
end
%% Plot/Animate the Results
plot(tsc.winchPower.Time,tsc.winchPower.Data)
title('Power (W)')
xlabel('Time')
ylabel('Power (Watts)')
% vhcl.animateSim(tsc,1,...
%     'PathFunc',fltCtrl.fcnName.Value,...
%     'PlotTracer',true,...
%     'FontSize',24,...
%     'PowerBar',false,...
%     'PlotAxes',false,...
%     'TracerDuration',10,...
%     'SaveGif',false)