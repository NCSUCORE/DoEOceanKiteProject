clc;clear
if ~slreportgen.utils.isModelLoaded('OCTModel')
    OCTModel
end
% spoolSpeeds = -.4:.05:.4;
spoolSpeeds = .2;%-.4:.05:.4;
durs = linspace(200,550,length(spoolSpeeds));
inds=cell(length(spoolSpeeds),1);
pathVars=cell(length(spoolSpeeds),1);
tens=cell(length(spoolSpeeds),1);
for iii = 1:length(spoolSpeeds)
    lengthScaleFactor = 1/1;
    densityScaleFactor = 1/1;
    duration_s  = durs(iii)*sqrt(lengthScaleFactor);
    dynamicCalc = '';
    SPOOLINGCONTROLLER = 'intra';
    PATHGEOMETRY = 'lemOfBooth';

    %% Load components
    % Flight Controller
    loadComponent('firstBuildPathFollowing');
    % Ground station controller
    loadComponent('oneDoFGSCtrlBasic');
    % High Level Con
    loadComponent('constBoothLem')
    % Ground station
    loadComponent('pathFollowingGndStn');
    % Winches
    loadComponent('oneDOFWnch');
    % Tether
    loadComponent('pathFollowingTether');
    % Vehicle
    loadComponent('pathFollowingVhcl');
    % Environment
    loadComponent('pathFollowingEnv');
    %% Choose Path Shape and Set basis parameters for high level controller
    fltCtrl.setFcnName('lemOfBooth','');
    hiLvlCtrl.basisParams.setValue([.75,1,20*pi/180,0,100],'');

    %% Environment IC's and dependant properties
    % Set Values
    flowspeed = 1; %m/s
    env.water.velVec.setValue([flowspeed 0 0],'m/s');
    %% Set vehicle initial conditions
    vhcl.setICsOnPath(...
        0.4,... % Initial path position
        fltCtrl.fcnName.Value,... % Name of path function
        hiLvlCtrl.basisParams.Value,... % Geometry parameters
        (11.5/2)*flowspeed) % Initial speed
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
    wnch.setTetherInitLength(vhcl,env,thr);
    wnch.winch1.setMaxSpeed(1,'m/s');
    %% ALL Controller Properties
    %General
    fltCtrl.setInitPathVar(vhcl.initPosVecGnd.Value,hiLvlCtrl.basisParams.Value)
    fltCtrl.setStartControl(0,'s')

    %Level 1, Velocity Angle Selection
    fltCtrl.setSearchSize(.5,'');
    fltCtrl.perpErrorVal.setValue(3*pi/180,'rad')

    %Level 2, Tangent Roll Selection
    fltCtrl.maxBank.upperLimit.setValue(45*pi/180,'');
    fltCtrl.maxBank.lowerLimit.setValue(-45*pi/180,'');

    fltCtrl.tanRoll.kp.setValue(.2,'(rad)/(rad)');
    fltCtrl.tanRoll.ki.setValue(0,'(rad)/(rad*s)');
    fltCtrl.tanRoll.kd.setValue(0,'(rad)/(rad/s)');
    fltCtrl.tanRoll.tau.setValue(.01,'s');

    %Level 3 Moment Selection


    fltCtrl.rollMoment.kp.setValue((3e3)/(10*pi/180),'(N*m)/(rad)')
    fltCtrl.rollMoment.ki.setValue(0,'(N*m)/(rad*s)');
    fltCtrl.rollMoment.kd.setValue(fltCtrl.rollMoment.kp.Value,'(N*m)/(rad/s)');
    fltCtrl.rollMoment.tau.setValue(.01,'s');

    fltCtrl.yawMoment.kp.setValue((1e3)/(10*pi/180),'(N*m)/(rad)');
    % fltCtrl.yawMoment.ki.setValue(0,'(N*m)/(rad*s)');
    % fltCtrl.yawMoment.kd.setValue(0,'(N*m)/(rad/s)');
    fltCtrl.yawMoment.tau.setValue(0.001,'s');

    %Control Allocation

    fltCtrl.controlSigMax.upperLimit.setValue(20,'')
    fltCtrl.controlSigMax.lowerLimit.setValue(-20,'')

    %Winch Controller
    fltCtrl.traditionalBool.setValue(0,'')

    fltCtrl.winchSpeedIn.setValue(-.4,'m/s')

    fltCtrl.elevatorReelInDef.setValue(20,'deg') %~2.8 degrees AoA

    fltCtrl.setMinR(100,'m')
    fltCtrl.setMaxR(200,'m')

    fltCtrl.winchSpeedIn.setValue(spoolSpeeds(iii),'m/s');
    fltCtrl.winchSpeedOut.setValue(spoolSpeeds(iii),'m/s');%(flowspeed/3)/cos(hiLvlCtrl.basisParams.Value(3)),'m/s')%dependant on basis params!!!
    if spoolSpeeds(iii)>=0
        fltCtrl.outRanges.setValue([0 1;2 2],'');
    else
        fltCtrl.outRanges.setValue([0 0;2 2],'');
    end
    %% Scale
    % scale environment
    env.scale(lengthScaleFactor,densityScaleFactor);
    % scale vehicle
    vhcl.scale(lengthScaleFactor,densityScaleFactor);
    vhcl.calcFluidDynamicCoefffs;
    % scale ground station
    gndStn.scale(lengthScaleFactor,densityScaleFactor);
    % scale tethers
    thr.scale(lengthScaleFactor,densityScaleFactor);
    % scale winches
    wnch.scale(lengthScaleFactor,densityScaleFactor);
    % scale controller
    fltCtrl.scale(lengthScaleFactor,densityScaleFactor);
    %% Run the simulation
    simWithMonitor('OCTModel')
    parseLogsout;
    fprintf("Completed %4.2f Percent\n",100*iii/length(spoolSpeeds))
    indlist = find(tsc.atZero.Data==1);
    ind1=indlist(1);
    doneflag=false;
    n=2;
    while n<=length(indlist) && ~doneflag
        if indlist(n)-ind1 > .05 * ind1
            ind1=indlist(n-1);
            ind2=indlist(n);
            doneflag = true;
        end
        n=n+1;
    end
    inds{iii} = [ind1 ind2];
    times{iii} = tsc.atZero.Time(ind1:ind2);
    pathVars{iii}=tsc.currentPathVar.Data(ind1:ind2);
    tens{iii} = squeeze(sqrt(sum(tsc.FThrNetBdy.Data(:,:,ind1:ind2).^2,1)));
    endpos(iii) = sqrt(sum(tsc.positionVec.Data(:,1,ind2).^2,1));
end
% disp("iteration script")
% iterationScript

