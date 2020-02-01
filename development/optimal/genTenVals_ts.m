clear

if ~slreportgen.utils.isModelLoaded('OCTModel')
    OCTModel
end

lengthScaleFactor = 1/1;
densityScaleFactor = 1/1;
sim = SIM.simParams;
sim.setDuration(3000*sqrt(lengthScaleFactor),'s');

dynamicCalc = '';
SPOOLINGCONTROLLER = 'TimeSpoolingController';
% ZERO FOR MITCHELLS CONTROL ALLOCATION, ONE OLD CONTROL ALLOCATION MATRIX
controlAllocationBit = 0;
%% Opt stuff (move to mask)
Tens=cell(17,1);
spooldist = 15;
tic
maxspeed = .4;
validwait = 5;
for runSpoolSpeed = 0:maxspeed/8:maxspeed
    %% PLOT BITS
    fprintf("spool Speed = %4.3f\n",runSpoolSpeed);
    %% Load components
    % Flight Controller
    loadComponent('pathFollowingCtrlForILC');
    SPOOLINGCONTROLLER = 'TimeSpoolingController';
    % Ground station controller
    loadComponent('oneDoFGSCtrlBasic');
    % High Level Con
    loadComponent('constBoothLem')

    %PATHGEOMETRY = 'ellipse';
    PATHGEOMETRY = 'lemOfBooth';
    % Ground station
    loadComponent('pathFollowingGndStn');
    % Winches
    loadComponent('oneDOFWnch');
    % Tether
    loadComponent('fiveNodeSingleTether');
    % Vehicle
    loadComponent('pathFollowingVhcl');
    % Environment
    %loadComponent('constXYZ_varT_SineWave');
    loadComponent('constXYZT');
    %loadComponent('constXY_ZvarT_ADCP');
    %loadComponent('constX_YZvarT_ADCPTurb');
    % loadComponent('constX_YZvarT_CNAPSTurb');
    %% Choose Path Shape and Set basis parameters for high level controller
    %fltCtrl.setFcnName('ellipse','');
    % fltCtrl.setFcnName('circleOnSphere','');
    fltCtrl.setFcnName('lemOfBooth','');

    % hiLvlCtrl.basisParams.setValue([60 10 0 30 150],'') % Lemniscate of Gerono
    % hiLvlCtrl.basisParams.setValue([1.1,.5,.4,0,200],'');% ellipse
    % hiLvlCtrl.basisParams.setValue([.7,1,.36,.77,125,0.25,0.125],'')
    hiLvlCtrl.basisParams.setValue([.5,1,.36,0,125+(spooldist/2)],'');% Lemniscate of Booth
    %hiLvlCtrl.basisParams.setValue([pi/8,-3*pi/8,0,125],''); % Circle
    %% Environment IC's and dependant properties
    % Set Values
%     flowspeed = 1;

    env.water.flowVec.setValue([1,0,0],'m/s')
    flowspeed = norm(env.water.flowVec.Value);
    %% Set vehicle initial conditions
    vhcl.setICsOnPath(...
        .4,... % Initial path position
        fltCtrl.fcnName.Value,... % Name of path function
        hiLvlCtrl.basisParams.Value,... % Geometry parameters
        gndStn.posVec.Value,...
        (11.5/2)) % Initial speed
    vhcl.setAddedMISwitch(false,''); %true to have added mass on

    %% Ground Station IC's and dependant properties
    gndStn.initAngPos.setValue(0,'rad');
    gndStn.initAngVel.setValue(0,'rad/s');
    %gndStn.thrAttch1.velVec.setValue([0 0 0]','m/s');
    %% Tethers IC's and dependant properties
    thr.tether1.initGndNodePos.setValue(gndStn.thrAttch1.posVec.Value(:),'m');
    thr.tether1.initAirNodePos.setValue(vhcl.initPosVecGnd.Value(:)+rotation_sequence(vhcl.initEulAng.Value)*vhcl.thrAttchPts.posVec.Value,'m');
    thr.tether1.initGndNodeVel.setValue([0 0 0]','m/s');
    thr.tether1.initAirNodeVel.setValue(vhcl.initVelVecBdy.Value(:),'m/s');
    thr.tether1.vehicleMass.setValue(vhcl.mass.Value,'kg');
    thr.tether1.density.setValue(1000,'kg/m^3');
    %% winches IC's and dependant properties
    wnch.setTetherInitLength(vhcl,gndStn.posVec.Value,env,thr,[norm(env.water.flowVec.Value),0,0]);
    
    %% Controller User Def. Parameters and dependant properties
    fltCtrl.setFcnName(PATHGEOMETRY,''); % PATHGEOMETRY is defined in fig8ILC_bs.m
    % Set initial conditions
    fltCtrl.setInitPathVar(vhcl.initPosVecGnd.Value,hiLvlCtrl.basisParams.Value,gndStn.posVec.Value)

    %% Run the simulation
    simWithMonitor('OCTModel')
    parseLogsout;
    % kiteAxesPlot
    %stopCallback
    %%
    TenMags=sqrt(sum(squeeze(tsc.gndTenVecBusArry.tenVec.Data(:,1,tsc.validSpeed.Data(1:end-1)==1).^2),1));
    speeds=tsc.thrReleaseSpeeds.Data(tsc.validSpeed.Data(1:end-1)==1);
    pathVars=tsc.closestPathVariable.Data(tsc.validSpeed.Data(1:end-1)==1);
    
    m=zeros(size(0999));
    for i=0:999
        m(i+1)=mean(TenMags(and(speeds<0,floor(1000*pathVars)==i)));
    end
    Tens{round(9-(runSpoolSpeed/(maxspeed/8)))}=m;
    m=zeros(size(0:99));
    for i=0:999
        m(i+1)=mean(TenMags(and(speeds>=0,floor(1000*pathVars)==i)));
    end
    Tens{round(9+(runSpoolSpeed/(maxspeed/8)))}=m;
end
toc