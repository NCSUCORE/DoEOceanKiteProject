

flowspeeds = [0.25];
tetherLengths = [125];
for ii = 1:numel(flowspeeds)
    for jj = 1:numel(tetherLengths)
        
        % This is the section where the simulation parameters are set. Mainly the
        % length of the simulation
        simParams = SIM.simParams;
        simParams.setDuration(50,'s');
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
        env.water.setflowVec([flowspeeds(ii) 0 0],'m/s')
        
        %% Set basis parameters for high level controller
        
        %This is where the path parameters are set. The first value dictates the
        %width of the figure eight, the second determines the height, the third
        %determines the center of the paths elevation angle, the four sets the path
        %centers azimuth angle, the fifth is the initial tether length
       hiLvlCtrl.basisParams.setValue([1,1.4,-20*pi/180,0*pi/180,tetherLengths(jj)],'[rad rad rad rad m]') % Lemniscate of Booth

        
        
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
%         % this is where the simulation is commanded to run
%         vhcl.setMa6x6_B([125  0    0     0     0     0;...
%             0   1233 0     -627  0     2585;...
%             0   0    8922  0     -7359 0;...
%             0   -627 0     67503 0     -2892;...
%             9   0    -7359 0     20312 0;...
%             0   2525 0     -2892 0     14381;],'');
        
        
        simWithMonitor('OCTModel')
        
        %this stores all of the logged signals from the model. To veiw, type
        %tsc.signalname.data to veiw data, tsc.signalname.plot to plot ect.
        tsc = signalcontainer(logsout);
        gifString = 'FLOW_SPEED_%0.1f_MPS_TETHER_%dM.gif';
        gifName = sprintf(gifString,flowspeeds(ii),tetherLengths(jj));
        % Plot/Animate the Results
        vhcl.animateSim(tsc,1,...
            'PathFunc',fltCtrl.fcnName.Value,...
            'PlotTracer',true,...
            'FontSize',24,...
            'PowerBar',false,...
            'PlotAxes',false,...
            'TracerDuration',10,...
            'GifTimeStep',.05,...
            'ColorTracer',true,...
            'SaveGif',true,...
        'GifFile',gifName)
    end
end