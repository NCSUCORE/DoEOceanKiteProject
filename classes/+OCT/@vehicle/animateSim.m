function animateSim(obj,tsc,timeStep,varargin)
%ANIMATESIM Method to animate a simulation using the provided timeseries

%% Input parsing
p = inputParser;


% ---Fundamental Animation Requirements---
% Timeseries collection structure with results from the simulation
addRequired(p,'tsc',@(x) or(isa(x,'signalcontainer'),isa(x,'struct')));
% Time step used in plotting
addRequired(p,'timeStep',@isnumeric);
% Time to start viewing
addParameter(p,'startTime',0,@isnumeric);
% Time to start viewing
addParameter(p,'endTime',tsc.positionVec.Time(end),@isnumeric);

% Vector of time stamps used to crop data
addParameter(p,'CropTimes',[],@isnumeric)

% ---Parameters for saving a gif---
% Switch to enable saving 0 = don't save
addParameter(p,'SaveGif',false,@islogical)
% Path to saved file, default is ./output
addParameter(p,'GifPath',fullfile(fileparts(which('OCTProject.prj')),'output'));
% Name of saved file, default is animation.gif
addParameter(p,'GifFile','animation.gif');
% Time step between frames of gif, default is time step (real time plot)
addParameter(p,'GifTimeStep',timeStep,@isnumeric)

% ---Parameters to save MPEG---
addParameter(p,'SaveMPEG',false,@islogical) % Boolean switch to save a MPEG
addParameter(p,'MPEGPath',fullfile(fileparts(which('OCTProject.prj')),'output'));
addParameter(p,'MPEGFile','animation');

% ---Plot Features---
% X limits on the plot
addParameter(p,'XLim',[],@isnumeric)
% Y limits on the plot
addParameter(p,'YLim',[],@isnumeric)
% Z limits on the plot
addParameter(p,'ZLim',[],@isnumeric)
% Name of the path geometry used 
addParameter(p,'PathFunc',[],@ischar);
% Plot ground coordinate system axes
addParameter(p,'PlotAxes',true,@islogical);
% Set camera view angle [azimuth, elevation]
addParameter(p,'View',[71,22],@isnumeric)
% Set font size
addParameter(p,'FontSize',get(0,'defaultAxesFontSize'),@isnumeric)
% Tracer (streaming red line behind the model)
addParameter(p,'PlotTracer',true,@islogical)
% Color tracer according to power production/consumption
addParameter(p,'ColorTracer',false,@islogical)
% How long (in seconds) to keep the tracer on for
addParameter(p,'TracerDuration',5,@isnumeric)
% Plot a red dot on the closest point on the path
addParameter(p,'PathPosition',false,@islogical)
% Plot normal, tangent and desired vectors
addParameter(p,'NavigationVecs',false,@islogical)
% Plot velocity vector
addParameter(p,'VelocityVec',false,@islogical)
% Plot local aerodynamic force vectors on surfaces
addParameter(p,'LocalAero',false,@islogical)
% Add resulting net moment in the body frame to the table readout
addParameter(p,'FluidMoments',false,@islogical)
% Pause after each plot update (to go frame by frame)
addParameter(p,'Pause',false,@islogical)
% Zoom in the plot axes to focus on the body
addParameter(p,'ZoomIn',false,@islogical)
% Colorbar on right showing iteration power
addParameter(p,'PowerBar',false,@islogical)
% Plot the tangent coordinate system
addParameter(p,'TangentCoordSys',false,@islogical);
% Optional scrolling plots on the side
addParameter(p,'ScrollPlots',{}, @(x) isa(x,'cell') && all(isa([x{:}],'timeseries'))); % Must be a cell array of timeseries objects

% ---Parse the output---
parse(p,tsc,timeStep,varargin{:})


%% Setup some infrastructure type things
% If the user wants to save something and the specified directory does not
% exist, create it
if p.Results.SaveGif && ~exist(p.Results.GifPath, 'dir')
    mkdir(p.Results.GifPath)
end
if p.Results.SaveMPEG && ~exist(p.Results.MPEGPath, 'dir')
    mkdir(p.Results.MPEGPath)
end

if p.Results.SaveMPEG
   vidWriter = VideoWriter(fullfile(p.Results.MPEGPath,p.Results.MPEGFile), 'MPEG-4');
   open(vidWriter);
end

% Crop to the specified times
tscTmp = tsc.crop(p.Results.startTime,p.Results.endTime);
% Resample the timeseries to the specified framerate
tscTmp = tscTmp.resample(p.Results.timeStep);

% Resample mean power to iteration domain
if p.Results.PowerBar
    iterMeanPower = tsc.meanPower.resample(tsc.estGradient.Time);
end

%% Plot things
% Plot the aerodynamic surfaces
h = obj.plot('Basic',true);
h.ax = gca;

% Add scroll plots if specified
if ~isempty(p.Results.ScrollPlots)
    numPlots        = numel(p.Results.ScrollPlots);
    allPlotNums     = 1:numPlots*3;
    scrollPlotNums  = 1:3:numPlots*3;
    mainPlotNums    = allPlotNums(~ismember(allPlotNums,scrollPlotNums));
    subplot(numPlots,3,mainPlotNums,h.ax)
    cnt = 1;
    for ii = scrollPlotNums
        subplot(numPlots,3,ii)
        p.Results.ScrollPlots{cnt}.plot('LineStyle','-','Color','k')
        hold on
        grid on
        h.TimeLine(cnt) = line(p.Results.ScrollPlots{cnt}.Time(1)*[1 1],...
            get(gca,'YLim'),'Color','r','LineStyle','--');
        
        unitString = p.Results.ScrollPlots{cnt}.DataInfo.Units;
        if isempty(unitString)
           unitString = '-';
        end
        ylabel(sprintf('%s [%s]',p.Results.ScrollPlots{cnt}.Name,unitString))
        title('')
        cnt = cnt+1;
    end
end
axes(h.ax)
% Get the "nominal" positions of the aerodynamic surfaces from that plot
for ii = 1:length(h.surf)
    hStatic{ii}.x = h.surf{ii}.XData;
    hStatic{ii}.y = h.surf{ii}.YData;
    hStatic{ii}.z = h.surf{ii}.ZData;
end
hold on

% Plot x, y and z ground fixed axes
if p.Results.PlotAxes
    posData = squeeze(tscTmp.positionVec.Data)';
    r = sqrt(sum(posData.^2,2));
    len = 0.1*max(r);
    plot3([0 len],[0 0],[0 0],...
        'Color','r','LineStyle','-');
    plot3([0 0],[0 len],[0 0],...
        'Color','g','LineStyle','-');
    plot3([0 0],[0 0],[0 len],...
        'Color','b','LineStyle','-');
end

% Plot the tracer (empty/NAN's)
if p.Results.PlotTracer
    for ii = 1:round(p.Results.TracerDuration/p.Results.timeStep)
       h.tracer(ii) = line([nan nan],[nan nan],[nan nan],...
           'Color','r','LineWidth',2);
    end
end

% Plot the path
if ~isempty(p.Results.PathFunc)
    path = eval(sprintf('%s(linspace(0,1,1000),tscTmp.basisParams.Data(:,:,1),tscTmp.gndStnPositionVec.Data(:,:,1))',...
        p.Results.PathFunc));
    h.path = plot3(...
        path(1,:),...
        path(2,:),...
        path(3,:),...
        'LineStyle','-',...
        'Color',0.5*[1 1 1],...
        'LineWidth',1.5);
end

% Plot current path position
if p.Results.PathPosition
    %     pt = eval(sprintf('%s(tscTmp.currentPathVar.Data(1),tscTmp.basisParams.Data(:,:,1),tscTmp.gndStnPositionVec.Data(:,:,1))',...
    %         p.Results.PathFunc));
    h.pathPosition = plot3(...
        tscTmp.pathPosGnd.Data(1,:,1),...
        tscTmp.pathPosGnd.Data(2,:,1),...
        tscTmp.pathPosGnd.Data(3,:,1),...
        'ro');
end

% Plot navigation vectors
if p.Results.NavigationVecs
    posData = squeeze(tscTmp.positionVec.Data)';
%     r = sqrt(sum(posData.^2,2));
    len = obj.fuse.length.Value;
    pathPt = eval(sprintf('%s(tscTmp.currentPathVar.Data(1),tscTmp.basisParams.Data(:,:,1),tscTmp.gndStnPositionVec.Data(:,:,1))',...
        p.Results.PathFunc));
    h.tanVec = quiver3(...
        pathPt(1),pathPt(2),pathPt(3),...
        len*tscTmp.tanVec.Data(1,1),...
        len*tscTmp.tanVec.Data(1,2),...
        len*tscTmp.tanVec.Data(1,3),...
        'MaxHeadSize',0,'Color','r','LineStyle','--','LineWidth',1.5);
    h.perpVec = quiver3(...
        posData(1,1),posData(1,2),posData(1,3),...
        len*tscTmp.perpVec.Data(1,:,ii),...
        len*tscTmp.perpVec.Data(2,:,ii),...
        len*tscTmp.perpVec.Data(3,:,ii),...
        'MaxHeadSize',0,'Color',0.75*[0 1 0],'LineStyle','--','LineWidth',1.5);
    h.desVec = quiver3(...
        posData(1,1),posData(1,2),posData(1,3),...
        len*tscTmp.velVectorDes.Data(1,1),...
        len*tscTmp.velVectorDes.Data(1,2),...
        len*tscTmp.velVectorDes.Data(1,3),...
        'MaxHeadSize',0,'Color','b','LineStyle','--','LineWidth',1.5);
end

% Create a table
if p.Results.LocalAero || p.Results.FluidMoments
    h.table = uitable(h.fig,'Units','Normalized','FontSize',16,...
        'Position',[0.0099    0.0197    0.2880    0.9668],...
        'ColumnWidth','auto',...
        'ColumnName',{'Description','Value'},...
        'ColumnWidth',{150,200});
end

% Set the plot limits to zoom in on the body
if p.Results.ZoomIn
    xlim(tscTmp.positionVec.Data(1,:,1)+obj.fuse.length.Value*[-1.5 1.5])
    ylim(tscTmp.positionVec.Data(2,:,1)+obj.fuse.length.Value*[-1.5 1.5])
    zlim(tscTmp.positionVec.Data(3,:,1)+obj.fuse.length.Value*[-1.5 1.5])
end



% Plot local aerodynamic force vectors
if p.Results.LocalAero
    % Get the surface names
    [aeroStruct,surfNames] = obj.struct('OCT.aeroSurf');
    
    % Get the aerodynamic vectors in the ground frames
    FLiftPart = rotation_sequence(tscTmp.eulerAngles.Data(:,:,1))*tscTmp.FLiftBdyPart.Data(:,:,1);
    FDragPart = rotation_sequence(tscTmp.eulerAngles.Data(:,:,1))*tscTmp.FDragBdyPart.Data(:,:,1);
    vAppPart  = rotation_sequence(tscTmp.eulerAngles.Data(:,:,1))*tscTmp.vAppLclBdy.Data(:,:,1);
    
    % Normalize them for plotting purposes
    uLiftPart = FLiftPart./sqrt(sum(FLiftPart.^2,1));
    uDragPart = FDragPart./sqrt(sum(FDragPart.^2,1));
    uAppPart = vAppPart./sqrt(sum(vAppPart.^2,1));
   
    % Plot the vectors on each surface
    for ii = 1:numel(surfNames)
        % Update the table
        h.table.Data = [h.table.Data;...
            {surfNames{ii}},{''};...
            {'V App'} ,{sprintf('%0.2f',sqrt(sum(vAppPart(ii).^2,1)))};...
            {'F Lift'},{sprintf('%0.0f',sqrt(sum(FLiftPart(ii).^2,1)))};...
            {'F Drag'},{sprintf('%0.0f',sqrt(sum(FDragPart(ii).^2,1)))}];
        
        % Calculate the position of the aerodynamic center
        aeroCentVec = tscTmp.positionVec.Data(:,:,1)+...
            rotation_sequence(tscTmp.eulerAngles.Data(:,:,1))*aeroStruct(ii).aeroCentPosVec(:);
        
        % Plot the vectors
        h.liftVecs(ii) = quiver3(...
            aeroCentVec(1),...
            aeroCentVec(2),...
            aeroCentVec(3),...
            uLiftPart(1,ii),...
            uLiftPart(2,ii),...
            uLiftPart(3,ii),...
            'Color','g','LineWidth',1.5,'LineStyle','-');
        h.dragVecs(ii) = quiver3(...
            aeroCentVec(1),...
            aeroCentVec(2),...
            aeroCentVec(3),...
            uDragPart(1,ii),...
            uDragPart(2,ii),...
            uDragPart(3,ii),...
            'Color','r','LineWidth',1.5,'LineStyle','-');
        h.vAppVecs(ii) = quiver3(...
            aeroCentVec(1),...
            aeroCentVec(2),...
            aeroCentVec(3),...
            -uAppPart(1,ii),...
            -uAppPart(2,ii),...
            -uAppPart(3,ii),...
            'Color','b','LineWidth',1.5,'LineStyle','-');
    end
end

% Put the fluid dynamic moments in the table
if p.Results.FluidMoments
    fluidStartRow = size(h.table.Data,1);
    h.table.Data = [h.table.Data;
        {'M Fluid Roll'} ,{sprintf('%0.0f',tscTmp.MFluidBdy.Data(1,1,1))};...
        {'M Fluid Pitch'},{sprintf('%0.0f',tscTmp.MFluidBdy.Data(2,1,1))};...
        {'M Fluid Yaw'}  ,{sprintf('%0.0f',tscTmp.MFluidBdy.Data(3,1,1))}];
end

% Plot the tethers
for ii = 1:numel(tscTmp.thrNodeBus)
    h.thr{ii} = plot3(...
        squeeze(tscTmp.thrNodeBus.nodePositions.Data(1,:,1)),...
        squeeze(tscTmp.thrNodeBus.nodePositions.Data(2,:,1)),...
        squeeze(tscTmp.thrNodeBus.nodePositions.Data(3,:,1)),...
        'Color','k','LineWidth',1.5,'LineStyle','-','Marker','o',...
        'MarkerSize',4,'MarkerFaceColor','k');
end

% Add the color bar
if p.Results.PowerBar
    h.colorBar = colorbar;
    h.colorBar.Label.String = 'Iteration Mean Power [W]';
    h.colorBar.Label.Interpreter = 'Latex';
    h.colorBar.Limits = [min(iterMeanPower.Data) max(iterMeanPower.Data)];
    caxis([min(iterMeanPower.Data) max(iterMeanPower.Data)])
    colormap('hot')
    h.powerIndicatorArrow = ...
        annotation('TextArrow',...
        [h.colorBar.Position(1)-.025 h.colorBar.Position(1)],...
        h.colorBar.Position(2)*[1 1],...
        'String',sprintf('Iter. %d',max([tscTmp.iterationNumber.Data(1),1])),...
        'FontSize',p.Results.FontSize,...
        'HeadStyle','none',...
        'LineWidth',1.5);
end

% Plot the tangent coordinate system
if p.Results.TangentCoordSys
   h.tanCoordX = plot3(...
        [tscTmp.positionVec.Data(1,:,1) tscTmp.positionVec.Data(1,:,1)+tscTmp.tanXUnitVecGnd.Data(1,:,1)*obj.fuse.length.Value],...
        [tscTmp.positionVec.Data(2,:,1) tscTmp.positionVec.Data(2,:,1)+tscTmp.tanXUnitVecGnd.Data(2,:,1)*obj.fuse.length.Value],...
        [tscTmp.positionVec.Data(3,:,1) tscTmp.positionVec.Data(3,:,1)+tscTmp.tanXUnitVecGnd.Data(3,:,1)*obj.fuse.length.Value],...
        'Color','r','LineWidth',1.5,'LineStyle','-');
    h.tanCoordY = plot3(...
        [tscTmp.positionVec.Data(1,:,1) tscTmp.positionVec.Data(1,:,1)+tscTmp.tanYUnitVecGnd.Data(1,:,1)*obj.fuse.length.Value],...
        [tscTmp.positionVec.Data(2,:,1) tscTmp.positionVec.Data(2,:,1)+tscTmp.tanYUnitVecGnd.Data(2,:,1)*obj.fuse.length.Value],...
        [tscTmp.positionVec.Data(3,:,1) tscTmp.positionVec.Data(3,:,1)+tscTmp.tanYUnitVecGnd.Data(3,:,1)*obj.fuse.length.Value],...
        'Color','g','LineWidth',1.5,'LineStyle','-');
    h.tanCoordZ = plot3(...
        [tscTmp.positionVec.Data(1,:,1) tscTmp.positionVec.Data(1,:,1)+tscTmp.tanZUnitVecGnd.Data(1,:,1)*obj.fuse.length.Value],...
        [tscTmp.positionVec.Data(2,:,1) tscTmp.positionVec.Data(2,:,1)+tscTmp.tanZUnitVecGnd.Data(2,:,1)*obj.fuse.length.Value],...
        [tscTmp.positionVec.Data(3,:,1) tscTmp.positionVec.Data(3,:,1)+tscTmp.tanZUnitVecGnd.Data(3,:,1)*obj.fuse.length.Value],...
        'Color','b','LineWidth',1.5,'LineStyle','-');
end

if p.Results.VelocityVec
   h.velVec = plot3(...
        [tscTmp.positionVec.Data(1,:,1) tscTmp.positionVec.Data(1,:,1)+tscTmp.velocityVec.Data(1,:,1)*obj.fuse.length.Value./norm(tscTmp.velocityVec.Data(:,:,1))],...
        [tscTmp.positionVec.Data(2,:,1) tscTmp.positionVec.Data(2,:,1)+tscTmp.velocityVec.Data(2,:,1)*obj.fuse.length.Value./norm(tscTmp.velocityVec.Data(:,:,1))],...
        [tscTmp.positionVec.Data(3,:,1) tscTmp.positionVec.Data(3,:,1)+tscTmp.velocityVec.Data(3,:,1)*obj.fuse.length.Value./norm(tscTmp.velocityVec.Data(:,:,1))],...
        'Color','k','LineWidth',1.5,'LineStyle','--');
end

% Set the font size
set(gca,'FontSize',p.Results.FontSize);

% Set the viewpoint
view(p.Results.View)

% Set plot limits
setLimsToQuartSphere(gca,squeeze(tscTmp.positionVec.Data)',...
    'PlotAxes',true);

% Set the custom x, y and z limits
if ~isempty(p.Results.XLim)
    xlim(p.Results.XLim)
end
if ~isempty(p.Results.YLim)
    ylim(p.Results.YLim)
end
if ~isempty(p.Results.ZLim)
    zlim(p.Results.ZLim)
end

% Set data aspect ratio to realistic (not skewed)
daspect([1 1 1])

% Create a title
h.title = title({strcat(sprintf('Time = %.1f s',0),',',...
    sprintf(' Speed = %.1f m/s',norm(tscTmp.velocityVec.Data(:,:,1)))),...
    sprintf('Flow Speed = %.1f m/s',norm(tscTmp.vhclFlowVecs.Data(:,end,1)))});

   
for ii = 1:numel(tsc.positionVec.Time)
    timeStamp = tsc.positionVec.Time(ii);
    eulAngs   = tsc.eulerAngles.getsampleusingtime(timeStamp).Data;
    posVec    = tscTmp.positionVec.getsampleusingtime(timeStamp).Data;
    
    for jj = 1:numel(hStatic)
        % Rotate and translate all aero surfaces
        pts = rotation_sequence(eulAngs)...
            *[...
            hStatic{jj}.x(:)';...
            hStatic{jj}.y(:)';...
            hStatic{jj}.z(:)']+...
            tscTmp.positionVec.Data(:,:,ii);
        % Update the OCT outline
        h.surf{jj}.XData = pts(1,:);
        h.surf{jj}.YData = pts(2,:);
        h.surf{jj}.ZData = pts(3,:);
    end
    % Update the tracer
    if p.Results.PlotTracer
        delete(h.tracer(1));
        
        newLine = line(...
            [h.tracer(end).XData(end) posVec(1)],...
            [h.tracer(end).YData(end) posVec(2)],...
            [h.tracer(end).ZData(end) posVec(3)],...
            'Color','r','LineWidth',2);
    
        h.tracer(end).XData(end+1) = newLine.XData(1);
        h.tracer(end).YData(end+1) = newLine.YData(1);
        h.tracer(end).ZData(end+1) = newLine.ZData(1);

        if p.Results.ColorTracer
            newColor = [1 0 0];
           if tscTmp.winchPower.Data(ii)>0
               newColor = [0 0.75 0];
           end
           newLine.Color = newColor;
        end
        h.tracer = [h.tracer(2:end) newLine];
        uistack(h.tracer(end),'top');
    end
    
    % Update the path
    if ~isempty(p.Results.PathFunc)
        currentBasisParams = tscTmp.basisParams.getsampleusingtime(timeStamp).Data;
        currentBasisParams(end) = norm(tscTmp.positionVec.Data(:,1,ii)-tscTmp.gndStnPositionVec.Data(:,:,ii)) ;
        
        path = feval(p.Results.PathFunc,linspace(0,1,1000),currentBasisParams,tscTmp.gndStnPositionVec.getsampleusingtime(timeStamp).Data);

        h.path.XData = path(1,:);
        h.path.YData = path(2,:);
        h.path.ZData = path(3,:);
    end
    
    % Update current path position
    if p.Results.PathPosition
        pathPt = tscTmp.pathPosGnd.getsampleusingtime(timeStamp).Data;
        h.pathPosition.XData = pathPt(1);
        h.pathPosition.YData = pathPt(2);
        h.pathPosition.ZData = pathPt(3);
    end
    
    % Update navigation vectors
    if p.Results.NavigationVecs
        tanVec  = len*tscTmp.tanVec.getsampleusingtime(timeStamp).Data;
        perpVec = len*tscTmp.perpVec.getsampleusingtime(timeStamp).Data; 
        desVec  = len*tscTmp.velVectorDes.getsampleusingtime(timeStamp).Data; 
        
        h.tanVec.XData = posVec(1);
        h.tanVec.YData = posVec(2);
        h.tanVec.ZData = posVec(3);
        h.tanVec.UData = tanVec(1);
        h.tanVec.VData = tanVec(2);
        h.tanVec.WData = tanVec(3);
        
        h.perpVec.XData = posVec(1);
        h.perpVec.YData = posVec(2);
        h.perpVec.ZData = posVec(3);
        h.perpVec.UData = perpVec(1);
        h.perpVec.VData = perpVec(2);
        h.perpVec.WData = perpVec(3);
        
        h.desVec.XData = posVec(1);
        h.desVec.YData = posVec(2);
        h.desVec.ZData = posVec(3);
        h.desVec.UData = desVec(1);
        h.desVec.VData = desVec(2);
        h.desVec.WData = desVec(3);
    end
    
    % Update local aerodynamic force vectors
    if p.Results.LocalAero
        aeroStruct = obj.struct('OCT.aeroSurf');

        FLiftPart = rotation_sequence(eulAngs)*tscTmp.FLiftBdyPart.getsampleusingtime(timeStamp).Data;
        FDragPart = rotation_sequence(eulAngs)*tscTmp.FDragBdyPart.getsampleusingtime(timeStamp).Data;
        vAppPart  = rotation_sequence(eulAngs)*tscTmp.vAppLclBdy.getsampleusingtime(timeStamp).Data;
        
        uLiftPart = FLiftPart./sqrt(sum(FLiftPart.^2,1));
        uDragPart = FDragPart./sqrt(sum(FDragPart.^2,1));
        uAppPart  = vAppPart./sqrt(sum(vAppPart.^2,1));
        
        for jj = 1:numel(aeroStruct)
            h.table.Data{4*jj-2,2} = sprintf('%0.2f',sqrt(sum(vAppPart(jj).^2,1)));
            h.table.Data{4*jj-1,2} = sprintf('%0.0f',sqrt(sum(FLiftPart(jj).^2,1)));
            h.table.Data{4*jj+0,2} = sprintf('%0.0f',sqrt(sum(FDragPart(jj).^2,1)));
            
            aeroCentVec = posVec(:)+...
                rotation_sequence(eulAngs)*aeroStruct(jj).aeroCentPosVec(:);

            h.liftVecs(jj).XData = aeroCentVec(1);
            h.liftVecs(jj).YData = aeroCentVec(2);
            h.liftVecs(jj).ZData = aeroCentVec(3);
            h.liftVecs(jj).UData = uLiftPart(1,jj);
            h.liftVecs(jj).VData = uLiftPart(2,jj);
            h.liftVecs(jj).WData = uLiftPart(3,jj);
            
            h.dragVecs(jj).XData = aeroCentVec(1);
            h.dragVecs(jj).YData = aeroCentVec(2);
            h.dragVecs(jj).ZData = aeroCentVec(3);
            h.dragVecs(jj).UData = uDragPart(1,jj);
            h.dragVecs(jj).VData = uDragPart(2,jj);
            h.dragVecs(jj).WData = uDragPart(3,jj);
            
            h.vAppVecs(jj).XData = aeroCentVec(1);
            h.vAppVecs(jj).YData = aeroCentVec(2);
            h.vAppVecs(jj).ZData = aeroCentVec(3);
            h.vAppVecs(jj).UData = -uAppPart(1,jj);
            h.vAppVecs(jj).VData = -uAppPart(2,jj);
            h.vAppVecs(jj).WData = -uAppPart(3,jj);
        end
    end
    
    % Update moments in the table
    if p.Results.FluidMoments
        MFluidBdy = tscTmp.MFluidBdy.getsampleusingtime(timeStamp).Data;
        h.table.Data{fluidStartRow+1,2} = sprintf('%0.0f',MFluidBdy(1));
        h.table.Data{fluidStartRow+2,2} = sprintf('%0.0f',MFluidBdy(2));
        h.table.Data{fluidStartRow+3,2} = sprintf('%0.0f',MFluidBdy(3));
    end
    
    % Update the tethers
    for jj = numel(tscTmp.thrNodeBus)
        thrNodePos = tscTmp.thrNodeBus.nodePositions.getsampleusingtime(timeStamp).Data;
        h.thr{jj}.XData = squeeze(thrNodePos(1,:));
        h.thr{jj}.YData = squeeze(thrNodePos(2,:));
        h.thr{jj}.ZData = squeeze(thrNodePos(3,:));
    end
    % Update the title
    h.title.String = {strcat(...
        sprintf('Time = %.1f s',tscTmp.velocityVec.Time(ii)),',',...
        sprintf(' Speed = %.1f m/s',norm(tscTmp.velocityVec.getsampleusingtime(timeStamp).Data))),...
        sprintf('Flow Speed = %.1f m/s',norm(tscTmp.vhclFlowVecs.getsampleusingtime(timeStamp).Data))};
    
    
    if p.Results.PowerBar
        yPos = interp1(h.colorBar.Limits,...
            [h.colorBar.Position(2) h.colorBar.Position(2)+h.colorBar.Position(4)],...
            iterMeanPower.Data(max([tscTmp.iterationNumber.getsampleusingtime(timeStamp).Data 1])));
        h.powerIndicatorArrow.Y = yPos*[1 1];
        h.powerIndicatorArrow.String = sprintf('Iter. %d',tscTmp.iterationNumber.Data(ii));
    end
    
    if p.Results.TangentCoordSys
       
        originPt = tscTmp.positionVec.getsampleusingtime(timeStamp).Data;
        xVec = tscTmp.tanXUnitVecGnd.getsampleusingtime(timeStamp).Data;
        yVec = tscTmp.tanYUnitVecGnd.getsampleusingtime(timeStamp).Data;
        zVec = tscTmp.tanZUnitVecGnd.getsampleusingtime(timeStamp).Data;
        
        h.tanCoordX.XData = [originPt(1) originPt(1)+xVec(1)*obj.fuse.length.Value];
        h.tanCoordX.YData = [originPt(2) originPt(2)+xVec(2)*obj.fuse.length.Value];
        h.tanCoordX.ZData = [originPt(3) originPt(3)+xVec(3)*obj.fuse.length.Value];
        
        h.tanCoordY.XData = [originPt(1) originPt(1)+yVec(1)*obj.fuse.length.Value];
        h.tanCoordY.YData = [originPt(2) originPt(2)+yVec(2)*obj.fuse.length.Value];
        h.tanCoordY.ZData = [originPt(3) originPt(3)+yVec(3)*obj.fuse.length.Value];
        
        h.tanCoordZ.XData = [originPt(1) originPt(1)+zVec(1)*obj.fuse.length.Value];
        h.tanCoordZ.YData = [originPt(2) originPt(2)+zVec(2)*obj.fuse.length.Value];
        h.tanCoordZ.ZData = [originPt(3) originPt(3)+zVec(3)*obj.fuse.length.Value];
    end
    
    if p.Results.VelocityVec
        pt = tscTmp.positionVec.getsampleusingtime(timeStamp).Data;
        velVec = tscTmp.velocityVec.getsampleusingtime(timeStamp).Data;
        speed = sqrt(sum(velVec.^2));
        
        h.velVec.XData = [pt(1) pt(1)+velVec(1)*obj.fuse.length.Value./speed];
        h.velVec.YData = [pt(2) pt(2)+velVec(2)*obj.fuse.length.Value./speed];
        h.velVec.ZData = [pt(3) pt(3)+velVec(3)*obj.fuse.length.Value./speed];
        
    end
    
    % Set the plot limits to zoom in on the body
    if p.Results.ZoomIn
        pt = tscTmp.positionVec.getsampleusingtime(timeStamp).Data;
        xlim(pt(1)+obj.fuse.length.Value*[-1.5 1.5])
        ylim(pt(2)+obj.fuse.length.Value*[-1.5 1.5])
        zlim(pt(3)+obj.fuse.length.Value*[-1.5 1.5])
    end
    
    % Update scrolling plots
    if ~isempty(p.Results.ScrollPlots)
        for jj = 1:numel(h.TimeLine)
            h.TimeLine(jj).XData = tscTmp.positionVec.Time(ii)*[1 1];
        end
    end
    
    drawnow
    
    % Save gif of results
    if p.Results.SaveGif
        frame       = getframe(h.fig);
        im          = frame2im(frame);
        [imind,cm]  = rgb2ind(im,256);
        if ii == firstInd
            imwrite(imind,cm,fullfile(p.Results.GifPath,p.Results.GifFile),'gif', 'Loopcount',inf);
        else
            imwrite(imind,cm,fullfile(p.Results.GifPath,p.Results.GifFile),'gif','WriteMode','append','DelayTime',p.Results.GifTimeStep)
        end
    end
    
    % Save gif of results
    if p.Results.SaveMPEG
           frame = getframe(gcf);
           writeVideo(vidWriter,frame)
    end
    if p.Results.Pause
        pause
    end
end

if p.Results.SaveMPEG
   close(vidWriter);
end

end

