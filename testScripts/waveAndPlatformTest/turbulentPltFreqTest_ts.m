%% Test script to test the floating ground station simulation and animation


periodMat   = [2.7654052,3.9542334, 5.3515553, 6.7327666, 8.0227079, 9.4304562,  11.0628986,  12.8641157, 14.2856693 , 15.3846302, 16.6666775, 18.1818218, 20];
Amplitudes  =  [0.6621026, 0.9118301, 1.1457409,  1.3625439, 1.3299433,1.3610456,1.5558991,1.6783912, 1.8545873, 1.7698500,1.8685672, 1.2764912, 0.8311110];
Frequencies =  (2*pi)./(periodMat);
waveNumber  =  (Frequencies.^2)/9.81;
tetherL = [125,200];
flowSpeeds = [1,2];

tetherDist = [ 200 250 300 350 400]; 


heights = [4 8];
for qq = 2:2
    for pp = 1:2
        for kk = 1:1
            for jj = 1:13
                for ii = 1:1
                    
                    clearvars -except 'Amplitudes' 'Frequencies' 'waveNumber' 'ii' 'jj' 'qq' 'powerMatSaverKiteFloatingStationTurb' 'kk' 'tetherL'  'flowSpeeds' 'heights' 'pp' 'tetherDist'
                    
                    %%
                    GROUNDSTATION         = 'groundStation001';
                    sixDOFDynamics         = 'sixDoFDynamicsEuler';
                    gndStn = OCT.sixDoFStation;
                    
                    height = heights(pp);
                    gndStn.cylRad.setValue(1.5*height,'m')
                    gndStn.angSpac.setValue(pi/4,'rad')
                    gndStn.heightSpac.setValue(height/4,'m')
                    gndStn.setVolume(pi*gndStn.cylRad.Value^2*height,'m^3');
                    gndStn.setMass(gndStn.volume.Value*(1000/2),'kg');
                    gndStn.setInertia([.25*gndStn.mass.Value*gndStn.cylRad.Value^2,0,0;...
                        0,.25*gndStn.mass.Value*gndStn.cylRad.Value^2,0;
                        0,0,.5*gndStn.mass.Value*gndStn.cylRad.Value^2],'kg*m^2');
                    
                    
                    
                    gndStn.angMatExt.setValue([linspace(0,1.75*pi,8),linspace(0,1.75*pi,8),linspace(0,1.75*pi,8),linspace(0,1.75*pi,8)],'rad');
                    gndStn.zMatExt.setValue([-(height/2)*ones(1,8),(height/2)*ones(1,8),(height/4)*ones(1,8),-(height/4)*ones(1,8)],'m');
                    gndStn.rMatExt.setValue(repmat(gndStn.cylRad.Value,[1,32]),'m');
                    
                    gndStn.angMatT.setValue([linspace(0,1.75*pi,8),0],'rad')
                    gndStn.angMatB.setValue([linspace(0,1.75*pi,8),0],'rad')
                    
                    gndStn.zMatB.setValue(-(height/2)*ones(1,9),'m')
                    gndStn.zMatT.setValue((height/2)*ones(1,9),'m')
                    
                    gndStn.rMatT.setValue([repmat(.5*gndStn.cylRad.Value,[1,8]),0],'m')
                    gndStn.rMatB.setValue([repmat(.5*gndStn.cylRad.Value,[1,8]),0],'m')
                    
                    gndStn.angMatInt.setValue([linspace(0,1.75*pi,8),linspace(0,1.75*pi,8),linspace(0,1.75*pi,8),linspace(0,1.75*pi,8)],'rad')
                    gndStn.zMatInt.setValue([-(height/4)*ones(1,8),(height/4)*ones(1,8),-(height/8)*ones(1,8),(height/8)*ones(1,8)],'m');
                    gndStn.rMatInt.setValue(repmat(.5*gndStn.cylRad.Value,[1,32]),'m')
                    
                    
                    %number of tethers that go from the GS to the KITE
                    gndStn.numTethers.setValue(1,'');
                    
                    gndStn.build;
                    gndStn.buildCylStation
                    gndStn.thrAttch1.posVec.setValue([0 0 0]','m');
                    gndStn.bouyancy
                    
                    % added mass and drag coefficants of lumped masses
                    gndStn.cdX.setValue(1,'')
                    gndStn.cdY.setValue(1,'')
                    gndStn.cdZ.setValue(1,'')
                    gndStn.aMX.setValue(.1,'')
                    gndStn.aMY.setValue(.1,'')
                    gndStn.aMZ.setValue(.1,'')
                    gndStn.addedMass.setValue(zeros(3,3),'')
                    gndStn.addedInertia.setValue(zeros(3,3),'')
                    
                    gndStn.lumpedMassSphereRadius.setValue(.5*gndStn.heightSpac.Value,'m');
                    
                    
                    % tether attach point for the tether that goes from the GS to the KITE
                    % gndStn.addThrAttch('kitThrAttchPt1',[gndStn.cylRad.Value 0 -0.5*gndStn.cylTotH.Value]);
                    gndStn.addThrAttch('kitThrAttchPt1',[0 0 0]);
                    
                    
                    % tether attach points for the tether that goes from the GS to the GND
                    gndStn.addThrAttch('pltThrAttchPt1',[gndStn.cylRad.Value 0 -0.5*gndStn.cylTotH.Value]');
                    gndStn.addThrAttch('pltThrAttchPt2',rotation_sequence([0 0  2*pi/3])*gndStn.pltThrAttchPt1.posVec.Value(:));
                    gndStn.addThrAttch('pltThrAttchPt3',rotation_sequence([0 0 -2*pi/3])*gndStn.pltThrAttchPt1.posVec.Value(:));
                    
                    gndStn.addThrAttch('inrThrAttchPt1',[tetherDist(qq) 0 0]');
                    gndStn.addThrAttch('inrThrAttchPt2',rotation_sequence([0 0  2*pi/3])*gndStn.inrThrAttchPt1.posVec.Value(:));
                    gndStn.addThrAttch('inrThrAttchPt3',rotation_sequence([0 0 -2*pi/3])*gndStn.inrThrAttchPt1.posVec.Value(:));
                    
                    gndStn.setInitPosVecGnd([0 0 200],'m')
                    % gndStn.calcInitTetherLen 0.9937
                    % gndStn.initAnchTetherLength.setValue(.9937*gndStn.calcInitTetherLen,'m')
                    gndStn.initAnchTetherLength.setValue(.985*gndStn.calcInitTetherLen,'m')
                    
                    
                    % Anchor Tethers
                    gndStn.anchThrs.setNumNodes(2,'');
                    gndStn.anchThrs.setNumTethers(3,'');
                    gndStn.anchThrs.build;
                    
                    % Tether 1 properties
                    gndStn.anchThrs.tether1.diameter.setValue(.05,'m');              % tether diameter
                    gndStn.anchThrs.tether1.youngsMod.setValue(500e9,'Pa');          % tether Young's Modulus
                    gndStn.anchThrs.tether1.dampingRatio.setValue(.3,'');           % zeta, damping ratio
                    gndStn.anchThrs.tether1.dragCoeff.setValue(.5,'');               % drag coefficient for intermediate nodes
                    gndStn.anchThrs.tether1.density.setValue(1300,'kg/m^3');         % tether density
                    gndStn.anchThrs.tether1.vehicleMass.setValue(gndStn.mass.Value,'kg'); % mass of platform for damping coefficient calculations
                    gndStn.anchThrs.tether1.dragEnable.setValue(1,'');
                    gndStn.anchThrs.tether1.netBuoyEnable.setValue(1,'');
                    
                    
                    % Tether 2 properties
                    gndStn.anchThrs.tether2.diameter.setValue(.05,'m');              % tether diameter
                    gndStn.anchThrs.tether2.youngsMod.setValue(500e9,'Pa');          % tether Young's Modulus
                    gndStn.anchThrs.tether2.dampingRatio.setValue(.3,'');           % zeta, damping ratio
                    gndStn.anchThrs.tether2.dragCoeff.setValue(.5,'');               % drag coefficient for intermediate nodes
                    gndStn.anchThrs.tether2.density.setValue(1300,'kg/m^3');         % tether density
                    gndStn.anchThrs.tether2.vehicleMass.setValue(gndStn.mass.Value,'kg'); % mass of platform for damping coefficient calculations
                    gndStn.anchThrs.tether2.dragEnable.setValue(1,'');
                    gndStn.anchThrs.tether2.netBuoyEnable.setValue(1,'');
                    
                    
                    
                    % Tether 3 properties
                    gndStn.anchThrs.tether3.diameter.setValue(.05,'m');              % tether diameter
                    gndStn.anchThrs.tether3.youngsMod.setValue(500e9,'Pa');          % tether Young's Modulus
                    gndStn.anchThrs.tether3.dampingRatio.setValue(.3,'');           % zeta, damping ratio
                    gndStn.anchThrs.tether3.dragCoeff.setValue(.5,'');               % drag coefficient for intermediate nodes
                    gndStn.anchThrs.tether3.density.setValue(1300,'kg/m^3');         % tether density
                    gndStn.anchThrs.tether3.vehicleMass.setValue(gndStn.mass.Value,'kg'); % mass of platform for damping coefficient calculations
                    gndStn.anchThrs.tether3.dragEnable.setValue(1,'');
                    gndStn.anchThrs.tether3.netBuoyEnable.setValue(1,'');
                    
                    % Save the variable
                    saveBuildFile('gndStn','oneThrThreeAnchGndStn001_bs','variant','GROUNDSTATION');
                    
                    
                    %%
                    % %% Script to run ILC path optimization
                    clearvars -except 'Amplitudes' 'Frequencies' 'waveNumber' 'ii' 'jj' 'qq' 'pp' 'powerMatSaverKiteFloatingStationTurb' 'kk' 'tetherL'  'flowSpeeds' 'heights' 'tetherDist'
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
                    %                 loadComponent('pathFollowingGndStn');
                    loadComponent('oneThrThreeAnchGndStn001');
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
                    % loadComponent('CNAPsTurbJames');
                    % loadComponent('CNAPsTurbMitchell');
                    %             loadComponent('ConstXYZT');
%                     loadComponent('hurricaneSandyWave')
                    loadComponent('CNAPsTurbJames');
                     FLOWCALCULATION = 'combinedHighLowFreqDataPlanarWave';
                     env.addFlow({'waterWave'},{'planarWaves'});
                     env.waterWave.setNumWaves(2,'');
                     env.waterWave.build;
                    
                    env.waterWave.waveParamMat.setValue([waveNumber(jj),Frequencies(jj),Amplitudes(jj) ,0;0,0,0,0],'')
                    %              env.waterWave.waveParamMat.setValue([0,0,0 ,0;0,0,0,0],'')
                    
                    
                    %% Set basis parameters for high level controller
                    % hiLvlCtrl.initBasisParams.setValue([0.8,1.4,-20*pi/180,0*pi/180,125],'[]') % Lemniscate of Booth
                    hiLvlCtrl.basisParams.setValue([1.2,2.2,-.36,0*pi/180,tetherL(ii)],'[rad rad rad rad m]') % Lemniscate of Booth
                    %% Ground Station IC's and dependant properties
                    gndStn.initPosVecGnd.setValue([0 0 200],'m')
                    gndStn.initEulAng.setValue([0;0;0],'rad');
                    gndStn.initAngVelVec.setValue([0;0;0],'rad/s');
                    gndStn.initVelVecBdy.setValue([0;0;0],'m/s');
                    %% Set vehicle initial conditions
                    vhcl.setICsOnPath(...
                        0,... % Initial path position
                        PATHGEOMETRY,... % Name of path function
                        hiLvlCtrl.basisParams.Value,... % Geometry parameters
                        gndStn.initPosVecGnd.Value,... % Center point of path sphere
                        (11/2)*norm([ 1 0 0 ])) % Initial speed
                    
                    %% Tethers IC's and dependant properties
                    thr.tether1.initGndNodePos.setValue(gndStn.thrAttch1.posVec.Value(:)...
                        +gndStn.initPosVecGnd.Value(:),'m');
                    thr.tether1.initAirNodePos.setValue(vhcl.initPosVecGnd.Value(:)...
                        +rotation_sequence(vhcl.initEulAng.Value)*vhcl.thrAttchPts_B.posVec.Value,'m');
                    
                    thr.tether1.initGndNodeVel.setValue([0 0 0]','m/s');
                    thr.tether1.initAirNodeVel.setValue(vhcl.initVelVecBdy.Value(:),'m/s');
                    
                    thr.tether1.vehicleMass.setValue(vhcl.mass.Value,'kg');
                    %% Winches IC's and dependant properties
                    wnch.setTetherInitLength(vhcl,gndStn.initPosVecGnd.Value,env,thr,[1 0 0]);
                    
                    %% Controller User Def. Parameters and dependant properties
                    fltCtrl.setFcnName(PATHGEOMETRY,''); % PATHGEOMETRY is defined in fig8ILC_bs.m
                    % vhcl.addedMass.setValue(zeros(3,3),'kg')
                    fltCtrl.setInitPathVar(vhcl.initPosVecGnd.Value,...
                        hiLvlCtrl.basisParams.Value,...
                        gndStn.initPosVecGnd.Value);
                    simWithMonitor('OCTModel')
                    tsc = signalcontainer(logsout);
                    
                    
                    try
                        load('pow.mat')
                        
                        powerMatSaverKiteFloatingStationTurb(ii,jj,kk,pp,qq) = powAvg;
                         save('powerMatSaverKiteFloatingStationTurb.mat','powerMatSaverKiteFloatingStationTurb')
                        
                        
                    catch
                    end
                    
                    
                end
            end
        end
    end
end

plot(tsc.winchPower.Time,tsc.winchPower.Data)
title('Power (W)')
xlabel('Time')
ylabel('Power (Watts)')
