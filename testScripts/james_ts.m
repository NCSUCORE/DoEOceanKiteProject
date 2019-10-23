%% Script to run ILC path optimization
tetherLengths = [ 50 125 200];
flowSpeeds = [ 2 1.5 1 .5 .1 ];
for ppp = 3:3
    for qqq = 3:3
        clc;close all
        clearvars -except ppp qqq flowSpeeds tetherLengths
        if ~slreportgen.utils.isModelLoaded('OCTModel')
            OCTModel
        end
        sim = SIM.sim;
        sim.setDuration(600,'s')
        dynamicCalc = '';
        
        %% Load components
        % Flight Controller
        loadComponent('pathFollowingForILC');
        % Ground station controller
        loadComponent('oneDoFGSCtrlBasic');
        % High level controller
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
        % loadComponent('constXYZ_varT_SineWave');
        loadComponent('constX_YZvarT_CNAPSTurb');
        %          loadComponent('constX_YZvarT_ADCPTurb');
        %             loadComponent('constXY_ZvarT_CNAPS');
        %         loadComponent('constXYZT');
        
        %% Set basis parameters for high level controller
                hiLvlCtrl.basisParams.setValue([.8,1.6,.3,0,tetherLengths(ppp)],'') % Lemniscate of Booth for trying to get 200m working
        
        
        % [3*pi/8,pi/8,pi/8,0,125]% ellipse
        %% Environment IC's and dependant properties
        %         env.water.flowVec.setValue([flowSpeeds(qqq) 0 0]','m/s')
        
        
        %% ellipse
        
        %   SPOOLINGCONTROLLER = 'netZeroSpoolingControllerEllipsePath';
%         PATHGEOMETRY = 'ellipse';
%         hiLvlCtrl.basisParams.setValue([1.6,.3,.3,.0,tetherLengths(ppp)],''); % ellipse
        %% Ground Station IC's and dependant properties
        gndStn.initAngPos.setValue(0,'rad');
        gndStn.initAngVel.setValue(0,'rad/s');
        
        %% Set vehicle initial conditions
        % vhcl.setICsOnPath(...
        %     0,... % Initial path position
        %     PATHGEOMETRY,... % Name of path function
        %     hiLvlCtrl.basisParams.Value,... % Geometry parameters
        %     (11.5/2)*norm(env.water.flowVec.Value)) % Initial speed
        % vhcl.setAddedMISwitch(false,'');
        vhcl.setICsOnPath(...
            0,... % Initial path position
            PATHGEOMETRY,... % Name of path function
            hiLvlCtrl.basisParams.Value,... % Geometry parameters
            (11.5/2)*norm([flowSpeeds(qqq)  0 0])) % Initial speed
        vhcl.setAddedMISwitch(false,'');
        
        %% Tethers IC's and dependant properties
        thr.tether1.initGndNodePos.setValue(gndStn.thrAttch1.posVec.Value(:),'m');
        thr.tether1.initAirNodePos.setValue(vhcl.initPosVecGnd.Value(:)+rotation_sequence(vhcl.initEulAng.Value)*vhcl.thrAttchPts.posVec.Value,'m');
        thr.tether1.initGndNodeVel.setValue([0 0 0]','m/s');
        thr.tether1.initAirNodeVel.setValue(vhcl.initVelVecBdy.Value(:),'m/s');
        thr.tether1.vehicleMass.setValue(vhcl.mass.Value,'kg');
        
        %% Winches IC's and dependant properties
        wnch.setTetherInitLength(vhcl,env,thr,[flowSpeeds(qqq),0,0]);
        
        %% Controller User Def. Parameters and dependant properties
        fltCtrl.setFcnName(PATHGEOMETRY,'');
        %  fltCtrl.setFcnName('ellipse','');% PATHGEOMETRY is defined in fig8ILC_bs.m
        % Set initial conditions
        fltCtrl.setInitPathVar(vhcl.initPosVecGnd.Value,hiLvlCtrl.basisParams.Value)
        % fltCtrl.winchSpeedIn.setValue(-norm(env.water.flowVec.Value)/3,'m/s');
        % fltCtrl.winchSpeedOut.setValue(norm(env.water.flowVec.Value)/3,'m/s');
        
        
        %% Run the simulation
        simWithMonitor('OCTModel')
        parseLogsout;
        % kiteAxesPlot
        %%
%         plotThrVSP
        
        
        
        %% Animate the results
        % animateVehicle
        
        avgFlowMag =[ mean( diff(tsc.vhclFlowVecs.time)); diff(tsc.vhclFlowVecs.time)]' .* sqrt(sum(squeeze(tsc.vhclFlowVecs.data(:,5,:)).^2));
        
        rAvg = sum(avgFlowMag)/tsc.vhclFlowVecs.time(end)
        
        
        
        
        avgCAMag =[ mean( diff(tsc.vhclFlowVecs.time)); diff(tsc.vhclFlowVecs.time)] .* tsc.central_angle.data;
        
        rCAvg = sum(avgCAMag)/(tsc.vhclFlowVecs.time(end))
        
%         plotCentralAngle
%         plotMeanPower
        
%         plotPower
        %%  Flow Speed PLOT mag plot
        
        figure;
        
        h6 = plot(tsc.vhclFlowVecs.time, sqrt(sum(squeeze(tsc.vhclFlowVecs.data(:,5,:)).^2)));
        % title('Flow Speed Mag. at Kite CoM vs. Time ' )
        xlabel('Time (s) ' )
        ylabel('Flow Speed (m/s)')
        %         ylim([1.15,1.7])
        %          xlim([500 750])
        grid on
        box off
        ax6 = gca;
        ax6.FontSize = 16;
        h6.LineWidth = 1.5;
        h6.Color = [0, 0 ,0]
        % x0=10;
        % y0=10;
        % width=550;
        % height= 200;
        % set(gcf,'position',[x0,y0,width,height])
        
        % legend(' U Velocity', 'V Velocity', 'W velocity')
        
        %% Central Angle
        % plotCentralAngle
        
        %%
        % plot(squeeze(tsc.vhclFlowVecs.data(1,5,:)))
        
        %
        %
        % fprintf('\nRunning stopcallback.m \nParsing logsout\n')
        % parseLogsout
        
        % Create folder name to dump all results
%         folderName = strcat('Ellipse_',num2str(tetherLengths(ppp)),'CNAPSTurb');  %datestr(now,'ddmmmyy_HHMMSS');
%         folderName = fullfile(fileparts(which('OCTModel')),'output',folderName);
%         % If the folder doesn't exist, create it
%         if ~(7==exist(fullfile(folderName),'dir'))
%             fprintf('Creating directory  %s\n',folderName)
%             mkdir(fullfile(folderName))
%         end
%         
%         % Save data
%         fprintf('Saving all data to workspace.mat \n')
%         save(fullfile(folderName,'workspace.mat'),'-v7.3')
%         
%         % Plot Everything
%         % fprintf('Running all plot script in ./scripts/plotScripts \n')
%         % plotEverything
%         
%         % Get handles to all the figures
%         fprintf('Saving all resulting plots. \n')
%         saveAllPlots('Folder',folderName)
%         fprintf('Done. \n')
%         
        
    end
end