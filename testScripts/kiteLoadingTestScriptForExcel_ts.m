

flowspeeds = [1 1.5 2];
tetherLengths = [125 200];
for ii = 1:3
    for jj = 1:2
        
        % This is the section where the simulation parameters are set. Mainly the
        % length of the simulation
        simParams = SIM.simParams;
        simParams.setDuration(500,'s');
        dynamicCalc = '';
        
        % runBaseline = true;
        
        %% Load components
        
        %This is the section where all of the objects, simulation parameters and
        %variant subsystem identifiers are loaded into the model
        
        loadComponent('pathFollowingCtrlForILC');
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
        % Environment
        loadComponent('ConstXYZT');
        
        
        
        %% Environment IC's and dependant properties
        
        %if you are using constant flow, this is where the constant flow speed is
        %set
        env.water.setflowVec([1 0 0],'m/s')
        
        %% Set basis parameters for high level controller
        
        %This is where the path parameters are set. The first value dictates the
        %width of the figure eight, the second determines the height, the third
        %determines the center of the paths elevation angle, the four sets the path
        %centers azimuth angle, the fifth is the initial tether length
        hiLvlCtrl.basisParams.setValue([1,1.4,-20*pi/180,0*pi/180,125],'[rad rad rad rad m]') % Lemniscate of Booth
        
        
        %% Ground Station IC's and dependant properties
        
        % this is where the ground station initial parameters are set.
        gndStn.setPosVec([0 0 200],'m')
        gndStn.initAngPos.setValue(0,'rad');
        gndStn.initAngVel.setValue(0,'rad/s');
        
        %% Set vehicle initial conditions
        
        %This is where the vehicle initial conditions are aet.
        vhcl.setICsOnPath(...
            0,... % Initial path position
            PATHGEOMETRY,... % Name of path function
            hiLvlCtrl.basisParams.Value,... % Geometry parameters
            gndStn.posVec.Value,... % Center point of path sphere
            (11/2)*norm(env.water.flowVec.Value)) % Initial speed
        
        %% Tethers IC's and dependant properties'
        
        % This is where the Kite tether initial conditions and parameter values are
        % set
        thr.tether1.initGndNodePos.setValue(gndStn.thrAttch1.posVec.Value(:)...
            +gndStn.posVec.Value(:),'m');
        thr.tether1.initAirNodePos.setValue(vhcl.initPosVecGnd.Value(:)...
            +rotation_sequence(vhcl.initEulAng.Value)*vhcl.thrAttchPts_B.posVec.Value,'m');
        
        thr.tether1.initGndNodeVel.setValue([0 0 0]','m/s');
        thr.tether1.initAirNodeVel.setValue(vhcl.initVelVecBdy.Value(:),'m/s');
        
        thr.tether1.vehicleMass.setValue(vhcl.mass.Value,'kg');
        
        %% Winches IC's and dependant properties
        %this sets the initial tether length that the winch has spooled out
        wnch.setTetherInitLength(vhcl,gndStn.posVec.Value,env,thr,env.water.flowVec.Value);
        
        %% Controller User Def. Parameters and dependant properties
        
        % This is where the path geometry is set, (lemOfBooth is figure eight, race track, ellipse,ect...)
        fltCtrl.setFcnName(PATHGEOMETRY,''); % PATHGEOMETRY is defined in fig8ILC_bs.m
        % Set initial conditions
        fltCtrl.setInitPathVar(vhcl.initPosVecGnd.Value,...
            hiLvlCtrl.basisParams.Value,...
            gndStn.posVec.Value);
        
        
        %% Run the simulation
        % this is where the simulation is commanded to run
        vhcl.setMa6x6_LE([125  0    0     0     0     0;...
            0   1233 0     -627  0     2585;...
            0   0    8922  0     -7359 0;...
            0   -627 0     67503 0     -2892;...
            9   0    -7359 0     20312 0;...
            0   2525 0     -2892 0     14381;],'');
        
        
        simWithMonitor('OCTModel')
        
        %this stores all of the logged signals from the model. To veiw, type
        %tsc.signalname.data to veiw data, tsc.signalname.plot to plot ect.
        tsc = signalcontainer(logsout);
        
        % tsc.FDragBdy.plot
        % tsc.FLiftBdy.plot
        tscTmp = tsc.resample(5);
        TimeInSeconds  = tscTmp.FDragBdy.Time;
        ForceOnHStab    = squeeze(tscTmp.FDragBdyPart.Data(:,3,:)) + squeeze(tscTmp.FDragBdyPart.Data(:,3,:));
        ForceOnHStabX    = ForceOnHStab(1,:)';
        ForceOnHStabY    = ForceOnHStab(2,:)';
        ForceOnHStabZ    = ForceOnHStab(3,:)';
        
        ForceOnVStab    = squeeze(tscTmp.FDragBdyPart.Data(:,4,:)) + squeeze(tscTmp.FDragBdyPart.Data(:,4,:));
        ForceOnVStabX    = ForceOnVStab(1,:)';
        ForceOnVStabY    = ForceOnVStab(2,:)';
        ForceOnVStabZ    = ForceOnVStab(3,:)';
        
        ForceOnPortWing = squeeze(tscTmp.FDragBdyPart.Data(:,1,:)) + squeeze(tscTmp.FDragBdyPart.Data(:,1,:));
        ForceOnPortWingX    = ForceOnPortWing(1,:)';
        ForceOnPortWingY    = ForceOnPortWing(2,:)';
        ForceOnPortWingZ    = ForceOnPortWing(3,:)';
        
        ForceOnStarWing = squeeze(tscTmp.FDragBdyPart.Data(:,2,:)) + squeeze(tscTmp.FDragBdyPart.Data(:,2,:));
        ForceOnStarWingX    = ForceOnStarWing(1,:)';
        ForceOnStarWingY    = ForceOnStarWing(2,:)';
        ForceOnStarWingZ    = ForceOnStarWing(3,:)';
        
        ForceFromTether = squeeze(tscTmp.fThrNetBody.Data);
        ForceFromTetherX    = ForceFromTether(1,:)';
        ForceFromTetherY    = ForceFromTether(2,:)';
        ForceFromTetherZ    = ForceFromTether(3,:)';
        
        T = table(TimeInSeconds,ForceOnHStabX,ForceOnHStabY,ForceOnHStabZ,ForceOnVStabX,ForceOnVStabY,ForceOnVStabZ,...
            ForceOnPortWingX,ForceOnPortWingY,ForceOnPortWingZ,ForceOnStarWingX,ForceOnStarWingY,ForceOnStarWingZ,ForceFromTetherX,ForceFromTetherY,ForceFromTetherZ);
        
        
        filename = 'kiteLoading.xlsx';
        sheetString = 'FLOW_SPEED_%0.1f_MPS_TETHER_%dM';
        sheetName = sprintf(sheetString,flowspeeds(ii),tetherLengths(jj));
        writetable(T,filename,'Sheet',sheetName,'Range','D1')
        
        %% min max and nineteth percentile
        %HS
        minForceOnHStabX  = min(ForceOnHStabX);
        maxForceOnHStabX  = max(ForceOnHStabX);
        sortForceOnHStabX = sort(ForceOnHStabX);
        ninetyPercentileHSforceX = sortForceOnHStabX(90);
        
        minForceOnHStabY  = min(ForceOnHStabY);
        maxForceOnHStabY  = max(ForceOnHStabY);
        sortForceOnHStabY = sort(ForceOnHStabY);
        ninetyPercentileHSforceY = sortForceOnHStabY(90);
        
        minForceOnHStabZ  = min(ForceOnHStabZ);
        maxForceOnHStabZ  = max(ForceOnHStabZ);
        sortForceOnHStabZ = sort(ForceOnHStabZ);
        ninetyPercentileHSforceZ = sortForceOnHStabZ(90);
        
        %VS
        minForceOnVStabX  = min(ForceOnVStabX);
        maxForceOnVStabX  = max(ForceOnVStabX);
        sortForceOnVStabX = sort(ForceOnVStabX);
        ninetyPercentileVSforceX = sortForceOnVStabX(90);
        
        minForceOnVStabY  = min(ForceOnVStabY);
        maxForceOnVStabY  = max(ForceOnVStabY);
        sortForceOnVStabY = sort(ForceOnVStabY);
        ninetyPercentileVSforceY = sortForceOnVStabY(90);
        
        minForceOnVStabZ  = min(ForceOnVStabZ);
        maxForceOnVStabZ  = max(ForceOnVStabZ);
        sortForceOnVStabZ = sort(ForceOnVStabZ);
        ninetyPercentileVSforceZ = sortForceOnVStabZ(90);
        
        %PW
        minForceOnPortWingX   = min(ForceOnPortWingX);
        maxForceOnPortWingX   = max(ForceOnPortWingX);
        sortForceOnPortWingX  = sort(ForceOnPortWingX);
        ninetyPercentilePWforceX = sortForceOnPortWingX(90);
        
        minForceOnPortWingY   = min(ForceOnPortWingY);
        maxForceOnPortWingY   = max(ForceOnPortWingY);
        sortForceOnPortWingY  = sort(ForceOnPortWingY);
        ninetyPercentilePWforceY = sortForceOnPortWingY(90);
        
        minForceOnPortWingZ   = min(ForceOnPortWingZ);
        maxForceOnPortWingZ   = max(ForceOnPortWingZ);
        sortForceOnPortWingZ  = sort(ForceOnPortWingZ);
        ninetyPercentilePWforceZ = sortForceOnPortWingZ(90);
        
        %SW
        minForceOnStarWingX   = min(ForceOnStarWingX);
        maxForceOnStarWingX   = max(ForceOnStarWingX);
        sortForceOnStarWingX  = sort(ForceOnStarWingX);
        ninetyPercentileSWforceX = sortForceOnStarWingX(90);
        
        minForceOnStarWingY   = min(ForceOnStarWingY);
        maxForceOnStarWingY   = max(ForceOnStarWingY);
        sortForceOnStarWingY  = sort(ForceOnStarWingY);
        ninetyPercentileSWforceY = sortForceOnStarWingY(90);
        
        minForceOnStarWingZ   = min(ForceOnStarWingZ);
        maxForceOnStarWingZ   = max(ForceOnStarWingZ);
        sortForceOnStarWingZ  = sort(ForceOnStarWingZ);
        ninetyPercentileSWforceZ = sortForceOnStarWingZ(90);
        
        % Thr
        
        minForceFromTetherX   = min(ForceFromTetherX);
        maxForceFromTetherX   = max(ForceFromTetherX);
        sortForceFromTetherX  = sort(ForceFromTetherX);
        ninetyPercentileThrforceX = sortForceFromTetherX(90);
        
        
        minForceFromTetherY   = min(ForceFromTetherY);
        maxForceFromTetherY   = max(ForceFromTetherY);
        sortForceFromTetherY  = sort(ForceFromTetherY);
        ninetyPercentileThrforceY = sortForceFromTetherY(90);
        
        
        minForceFromTetherZ   = min(ForceFromTetherZ);
        maxForceFromTetherZ   = max(ForceFromTetherZ);
        sortForceFromTetherZ  = sort(ForceFromTetherZ);
        ninetyPercentileThrforceZ = sortForceFromTetherZ(90);
        
        
        minMaxPercVec = [ minForceOnHStabX; maxForceOnHStabX; ninetyPercentileHSforceX; minForceOnHStabY; maxForceOnHStabY; ninetyPercentileHSforceY; minForceOnHStabZ; maxForceOnHStabZ; ninetyPercentileHSforceZ; ...
            minForceOnVStabX; maxForceOnVStabX; ninetyPercentileVSforceX; minForceOnVStabY; maxForceOnVStabY; ninetyPercentileVSforceY; minForceOnVStabZ; maxForceOnVStabZ; ninetyPercentileVSforceZ;...
            minForceOnPortWingX; maxForceOnPortWingX; ninetyPercentilePWforceX; minForceOnPortWingY; maxForceOnPortWingY; ninetyPercentilePWforceY; minForceOnPortWingZ; maxForceOnPortWingZ; ninetyPercentilePWforceZ;...
            minForceOnStarWingX; maxForceOnStarWingX; ninetyPercentileSWforceX; minForceOnStarWingY; maxForceOnStarWingY; ninetyPercentileSWforceY; minForceOnStarWingZ; maxForceOnStarWingZ; ninetyPercentileSWforceZ;...
            minForceFromTetherX;maxForceFromTetherX;ninetyPercentileThrforceX;minForceFromTetherY;maxForceFromTetherY;ninetyPercentileThrforceY;minForceFromTetherZ;maxForceFromTetherZ;ninetyPercentileThrforceZ];
        
        minMaxPercVecString = [ "minForceOnHStabX"; "maxForceOnHStabX"; "ninetyPercentileHSforceX"; "minForceOnHStabY"; "maxForceOnHStabY"; "ninetyPercentileHSforceY"; "minForceOnHStabZ";" maxForceOnHStabZ"; "ninetyPercentileHSforceZ"; ...
            "minForceOnVStabX"; "maxForceOnVStabX"; "ninetyPercentileVSforceX"; "minForceOnVStabY"; "maxForceOnVStabY"; "ninetyPercentileVSforceY"; "minForceOnVStabZ"; "maxForceOnVStabZ"; "ninetyPercentileVSforceZ";...
            "minForceOnPortWingX"; "maxForceOnPortWingX"; "ninetyPercentilePWforceX"; "minForceOnPortWingY"; "maxForceOnPortWingY"; "ninetyPercentilePWforceY"; "minForceOnPortWingZ"; "maxForceOnPortWingZ";"ninetyPercentilePWforceZ";...
            "minForceOnStarWingX"; "maxForceOnStarWingX"; "ninetyPercentileSWforceX"; "minForceOnStarWingY"; "maxForceOnStarWingY"; "ninetyPercentileSWforceY"; "minForceOnStarWingZ"; "maxForceOnStarWingZ"; "ninetyPercentileSWforceZ";...
            "minForceFromTetherX";"maxForceFromTetherX";"ninetyPercentileThrforceX";"minForceFromTetherY";"maxForceFromTetherY";"ninetyPercentileThrforceY";"minForceFromTetherZ";"maxForceFromTetherZ";"ninetyPercentileThrforceZ";];
        
        TT = table(minMaxPercVecString,minMaxPercVec);
        writetable(TT,filename,'Sheet',sheetName,'Range','A1')
        
    end
end



