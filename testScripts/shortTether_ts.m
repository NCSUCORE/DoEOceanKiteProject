% This is the section where the simulation parameters are set. Mainly the
Simulink.sdi.clear
clear;clc;close all
simParams = SIM.simParams;
simParams.setDuration(20,'s');

dynamicCalc = '';

% set tether number "000 or 001"

TetherNum = 001;
%%
%%%1
MinLinkLength    = 1;a=1;b=0;c=0;%[.01,.1,1,10];a=1;b=0;c=0;
A = MinLinkLength;
minLinkDeviation = .1;
minSoftLength    = 0;
% for ii = 1:length(MinLinkLength)

%
%%.1
% MinLinkDeviation = [.0001,.001,.01,.1];a=0;b=1;c=0;
% A = MinLinkDeviation;
% minLinkLength     = 1;
% minSoftLength     = 0;
% for ii = 1:length(MinLinkDeviation)
 
%%
%%%1
% MinSoftLength   = 0; a=0;b=0;c=1;%[.001,.01,.1,1];a=0;b=0;c=1;
% A = MinSoftLength;
% minLinkLength    = .01;
% minLinkDeviation = .001;
%for ii = 1:length(MinSoftLength)
  
    %% Load components
ii = 1;
for TetherNum = 001%[000, 001]
    %This is the section where all of the objects, simulation parameters and
    %variant subsystem identifiers are loaded into the model

    % Flight Controller
%     loadComponent('newSpoolCtrl');
    loadComponent('LaRController');
    %loadComponent('fullCycleCtrl');
    %loadComponent('pathFollowingCtrlForILC');

    % Ground station controller
    loadComponent('oneDoFGSCtrlBasic');
    % High level controller
    loadComponent('constBoothLem');
    % Ground station
    loadComponent('pathFollowingGndStn');
    % Winches
    loadComponent('oneDOFWnch');
    % Tether
    if TetherNum==000
        loadComponent('shortTetherCompare');
    elseif TetherNum==001
        loadComponent('shortTether');
    end

    % Vehicle
%     loadComponent('fullScale1thr');
    loadComponent('MantaFullScale1thr');
    % Environment
    loadComponent('constXYZT');
    % Sensors
    loadComponent('idealSensors')
    % Sensor processing
    loadComponent('idealSensorProcessing')

    %%
%     if a==1
%         thr.tether1.setMinLinkLength(MinLinkLength(ii),'m');
%     end
%     if b==1
%         thr.tether1.setMinLinkDeviation(MinLinkDeviation(ii),'m');
%     end
%     if c==1
%         thr.tether1.setMinSoftLength(MinSoftLength(ii),'m');
%     end
    %% Environment IC's and dependant properties

    %if you are using constant flow, this is where the constant flow speed is
    %set
    env.water.setflowVec([.25 0 0],'m/s')

    %% Set basis parameters for high level controller

    %This is where the path parameters are set. The first value dictates the
    %width of the figure eight, the second determines the height, the third
    %determines the center of the paths elevation angle, the four sets the path
    %centers azimuth angle, the fifth is the initial tether length
    hiLvlCtrl.basisParams.setValue(...
        [.8,1.6,30*pi/180,0*pi/180,400],...
        '[rad rad rad rad m]') % Lemniscate of Booth


    %% Ground Station IC's and dependant properties

    % this is where the ground station initial parameters are set. 
    gndStn.setPosVec([0 0 0],'m')
    gndStn.setVelVec([0 0 0],'m/s')
    gndStn.initAngPos.setValue(0,'rad');
    gndStn.initAngVel.setValue(0,'rad/s');

    %% Set vehicle initial conditions

    %This is where the vehicle initial conditions are aet.
%     vhcl.setICsOnPath(...
%         0,... % Initial path position
%         PATHGEOMETRY,... % Name of path function
%         hiLvlCtrl.basisParams.Value,... % Geometry parameters
%         gndStn.posVec.Value,... % Center point of path sphere
%         (11/2)*norm(env.water.flowVec.Value)) % Initial speed
    vhcl.setICsOnPath(0,PATHGEOMETRY,hiLvlCtrl.basisParams.Value,gndStn.posVec.Value,0)
    vhcl.setInitEulAng([0,0,0]*pi/180,'rad')
    %% Tethers IC's and dependant properties'

    % This is where the Kite tether initial conditions and parameter values are set

    if TetherNum==000 %Tether000
        thr.tether1.initGndNodePos.setValue(gndStn.thrAttch1.posVec.Value(:)...
            +gndStn.posVec.Value(:),'m');
        thr.tether1.initAirNodePos.setValue(vhcl.initPosVecGnd.Value(:)...
            +rotation_sequence(vhcl.initEulAng.Value)*vhcl.thrAttchPts_B.posVec.Value,'m');
        thr.tether1.initGndNodeVel.setValue([0 0 0]','m/s');
        thr.tether1.initAirNodeVel.setValue(vhcl.initVelVecBdy.Value(:),'m/s');
        thr.tether1.vehicleMass.setValue(vhcl.mass.Value,'kg');
    elseif TetherNum==001%Tether001
        thr.tether1.setInitGndNodePos(gndStn.thrAttch1.posVec.Value(:)...
            +gndStn.posVec.Value(:),'m');
        thr.tether1.setInitAirNodePos(vhcl.initPosVecGnd.Value(:)...
            +rotation_sequence(vhcl.initEulAng.Value)*vhcl.thrAttchPts_B.posVec.Value,'m');
        thr.tether1.setInitGndNodeVel([0 0 0]','m/s');
        thr.tether1.setInitAirNodeVel(vhcl.initVelVecBdy.Value(:),'m/s');
        thr.tether1.setVehicleMass(vhcl.mass.Value,'kg');
    end


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
% fltCtrl.setInitTL(400,'m')

    %% Run the simulation
    % this is where the simulation is commanded to run
    if a==1
        minLinkLength = MinLinkLength(ii);
    end
    if b==1
        minLinkDeviation = MinLinkDeviation(ii);
    end
    if c==1
        minSoftLength = MinSoftLength(ii);
    end
    
    simWithMonitor('OCTModel')
    tsc = signalcontainer(logsout);

    %this stores all of the logged signals from the model. To veiw, type
%     %tsc.signalname.data to view data, tsc.signalname.plot to plot etc.
%     if TetherNum == 000
%         tsc = signalcontainer(logsout);
%     elseif TetherNum == 001
%         tsc2 = signalcontainer(logsout);
%     end

%    tsc{ii} = signalcontainer(logsout);
%     %vhcl.animateSim(tsc,.5)
    %%
    % figure(2)
    % Tension = [];
    % for ii=1:size(tsc.airTenVecs.Data,3)
    %     Tension(ii) = norm(tsc.airTenVecs.Data(:,:,ii));
    % end
    % plot(tsc.airTenVecs.Time,Tension)
end
%%
vhcl.animateSim(tsc,2,'View',[0,0],'FigPos',[488-00 342 560 420],...
    'GifTimeStep',.05,'PlotTracer',true,'FontSize',12,...
    'Pause',false,'ZoomIn',false,'SaveGif',true,'GifFile','Tether_Reelin_V-1.gif');
%     'Pause',false,'ZoomIn',true,'SaveGif',true,'GifFile','Tether_Reelin_V-1.gif');

%%
% for ii = 1:length(A)
%     for jj = 1:size(tsc{ii}.airTenVecs.Data(:,:),2)
%         AirTen(ii,jj) = norm(tsc{ii}.airTenVecs.Data(:,jj));
%         GndTen(ii,jj) = norm(tsc{ii}.gndNodeTenVecs.Data(:,jj));
%     end
% end


%%

% for ii = 1:length(A)
%     clear('AirTen')
%     clear('GndTen')
%     for jj = 1:size(tsc{ii}.airTenVecs.Data(:,:),2)
%         AirTen(1,jj) = norm(tsc{ii}.airTenVecs.Data(:,jj));
%         GndTen(1,jj) = norm(tsc{ii}.gndNodeTenVecs.Data(:,jj));
%     end
%     subplot(2,1,1)
%     hold on
%     plot(tsc{ii}.airTenVecs.Time,AirTen)
%     hold off
%     title('Kite Tension')
%     subplot(2,1,2)
%     hold on
%     plot(tsc{ii}.gndNodeTenVecs.Time,GndTen)
%     hold off
%     title('Ground (AUV) Tension')
%     xlabel('Time (s)')
% end
% 
% if a==1
%     legend(num2str(MinLinkLength(1)),num2str(MinLinkLength(2)),num2str(MinLinkLength(3)),num2str(MinLinkLength(4)),'Location','northeast')
% end
% if b==1
%     legend(num2str(MinLinkDeviation(1)),num2str(MinLinkDeviation(2)),num2str(MinLinkDeviation(3)),num2str(MinLinkDeviation(4)),'Location','northeast')
% end
% if c==1
%     legend(num2str(MinSoftLength(1)),num2str(MinSoftLength(2)),num2str(MinSoftLength(3)),num2str(MinSoftLength(4)),'Location','northeast')
% end


% 
% Plotting
%Euler Angles
figure(1)
    subplot(3,1,1)
    plot(tsc.eulerAngles.Time,tsc.eulerAngles.Data(1,:))
    hold on 
    plot(tsc2.eulerAngles.Time,tsc2.eulerAngles.Data(1,:))
    title('Euler Angles')
    subplot(3,1,2)   
    plot(tsc.eulerAngles.Time,tsc.eulerAngles.Data(2,:))
    hold on 
    plot(tsc2.eulerAngles.Time,tsc2.eulerAngles.Data(2,:))
    subplot(3,1,3) 
    plot(tsc.eulerAngles.Time,tsc.eulerAngles.Data(3,:))
    hold on 
    plot(tsc2.eulerAngles.Time,tsc2.eulerAngles.Data(3,:))
    legend('Current tether','New Tether')
    xlabel('Time (s)')
    ylabel('Angle (rad)')

%Positions
figure(2)
    subplot(3,1,1)
    plot(tsc.positionVec.Time,tsc.positionVec.Data(1,:))
    hold on 
    plot(tsc2.positionVec.Time,tsc2.positionVec.Data(1,:))
    title('Kite Positions')
    subplot(3,1,2)   
    plot(tsc.positionVec.Time,tsc.positionVec.Data(2,:))
    hold on 
    plot(tsc2.positionVec.Time,tsc2.positionVec.Data(2,:))
    subplot(3,1,3) 
    plot(tsc.positionVec.Time,tsc.positionVec.Data(3,:))
    hold on 
    plot(tsc2.positionVec.Time,tsc2.positionVec.Data(3,:))
    legend('Current tether','New Tether')
    xlabel('Time (s)')
    ylabel('Position (m)')
%Velocities
figure(3)
    subplot(3,1,1)
    plot(tsc.velocityVec.Time,tsc.velocityVec.Data(1,:))
    hold on 
    plot(tsc2.velocityVec.Time,tsc2.velocityVec.Data(1,:))
    title('Kite Velocities')
    subplot(3,1,2)   
    plot(tsc.velocityVec.Time,tsc.velocityVec.Data(2,:))
    hold on 
    plot(tsc2.velocityVec.Time,tsc2.velocityVec.Data(2,:))
    subplot(3,1,3) 
    plot(tsc.velocityVec.Time,tsc.velocityVec.Data(3,:))
    hold on 
    plot(tsc2.velocityVec.Time,tsc2.velocityVec.Data(3,:))
    legend('Current tether','New Tether')
    xlabel('Time (s)')
    ylabel('Velocity (m/s)')
%Angular Velocities
figure(4)
    subplot(3,1,1)
    plot(tsc.angularVel.Time,tsc.angularVel.Data(1,:))
    hold on 
    plot(tsc2.angularVel.Time,tsc2.angularVel.Data(1,:))
    title('Kite Angular Velocities')
    subplot(3,1,2)   
    plot(tsc.angularVel.Time,tsc.angularVel.Data(2,:))
    hold on 
    plot(tsc2.angularVel.Time,tsc2.angularVel.Data(2,:))
    subplot(3,1,3) 
    plot(tsc.angularVel.Time,tsc.angularVel.Data(3,:))
    hold on 
    plot(tsc2.angularVel.Time,tsc2.angularVel.Data(3,:))
    legend('Current tether','New Tether')
    xlabel('Time (s)')
    ylabel('Ang Vel (rad/sec)')

figure(5)
for ii = 1:length(A)
    clear('AirTen1')
    clear('GndTen1')
    clear('AirTen2')
    clear('GndTen2')
    for jj = 1:size(tsc.airTenVecs.Data(:,:),2)
        AirTen1(1,jj) = norm(tsc.airTenVecs.Data(:,jj));
        GndTen1(1,jj) = norm(tsc.gndNodeTenVecs.Data(:,jj));
    end
    for jj = 1:size(tsc2.airTenVecs.Data(:,:),2)
        AirTen2(1,jj) = norm(tsc2.airTenVecs.Data(:,jj));
        GndTen2(1,jj) = norm(tsc2.gndNodeTenVecs.Data(:,jj));
    end
    subplot(2,1,1)
    hold on
    plot(tsc.airTenVecs.Time,AirTen1)
    plot(tsc2.airTenVecs.Time,AirTen2)
    hold off
    title('Kite Tension')
    subplot(2,1,2)
    hold on
    plot(tsc.gndNodeTenVecs.Time,GndTen1)
    plot(tsc2.gndNodeTenVecs.Time,GndTen2)
    hold off
    title('Ground (AUV) Tension')
    xlabel('Time (s)')
    ylabel('Force (N)')
    legend('Current tether','New Tether')
end

    
    vhcl.animateSim(tsc2,.5,'SaveGif',false)
