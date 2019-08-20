function animateSim(obj,tsc,timeStep,varargin)
%ANIMATESIM Function to animate a simulation.

p = inputParser;
addRequired(p,'tsc',@isstruct);
addRequired(p,'timeStep',@isnumeric);

% Save parameters
addParameter(p,'PathFunc',[],@ischar); % Path geometry function that we're tracing
addParameter(p,'SaveGif',false,@islogical) % Boolean switch to save a gif
addParameter(p,'GifPath',[]);
addParameter(p,'GifFile','animation.gif');
addParameter(p,'SaveMPEG',false,@islogical) % Boolean switch to save a MPEG
addParameter(p,'MPEGPath',[]);
addParameter(p,'MPEGFile','animation.mpeg');
% Plot features
addParameter(p,'PlotAxes',true,@islogical); % Plot coordinate system unit vectors
addParameter(p,'View',[71,22],@isnumeric) % Camera view angle [azimuth elevation]
addParameter(p,'FontSize',get(0,'defaultAxesFontSize'),@isnumeric) % Font size
addParameter(p,'PlotTracer',true,@islogical) % Plot tracer yes/no
addParameter(p,'TracerDuration',5,@isnumeric) % Time duration in seconds spanned by tracer
addParameter(p,'PathPosition',false,@islogical) % closest point on the path
addParameter(p,'NavigationVecs',false,@islogical) % Plot normal and tangent vectors
addParameter(p,'LocalAero',false,@islogical) % Plot local aerodynamic force vectors
addParameter(p,'FluidMoments',false,@islogical)% Add moments to the table readout
addParameter(p,'Pause',false,@islogical) % Pause after every image update

parse(p,tsc,timeStep,varargin{:})

% Resample the timeseries to the specified framerate
tsc = resampleTSC(tsc,p.Results.timeStep);

% Plot the aerodynamic surfaces
h = obj.plot('Basic',true);

% Get the "nominal" positions
for ii = 1:length(h.surf)
    hStatic{ii}.x = h.surf{ii}.XData;
    hStatic{ii}.y = h.surf{ii}.YData;
    hStatic{ii}.z = h.surf{ii}.ZData;
end

hold on

% Set plot limits
setLimsToQuartSphere(gca,squeeze(tsc.positionVec.Data)',...
    'PlotAxes',true);

% Set data aspect ratio to realistic (not skewed)
daspect([1 1 1])

% Plot x, y and z axes
if p.Results.PlotAxes
    posData = squeeze(tsc.positionVec.Data)';
    r = sqrt(sum(posData.^2,2));
    len = 0.1*max(r);
    plot3([0 len],[0 0],[0 0],...
        'Color','r','LineStyle','-');
    plot3([0 0],[0 len],[0 0],...
        'Color','g','LineStyle','-');
    plot3([0 0],[0 0],[0 len],...
        'Color','b','LineStyle','-');
end

view(p.Results.View)

% Title
h.title = title({sprintf('Time = %.1f s',0),...
    sprintf('Speed = %.1f m/s',norm(tsc.velocityVec.Data(:,:,1)))});

% Tracer
if p.Results.PlotTracer
    h.tracer = plot3(...
        nan([round(p.Results.TracerDuration/p.Results.timeStep) 1]),...
        nan([round(p.Results.TracerDuration/p.Results.timeStep) 1]),...
        nan([round(p.Results.TracerDuration/p.Results.timeStep) 1]),...
        'Color','r','LineStyle','-','LineWidth',1.5);
end

% Plot the path
if ~isempty(p.Results.PathFunc)
    path = eval(sprintf('%s(linspace(0,1,1000),tsc.basisParams.Data(:,:,1))',...
        p.Results.PathFunc));
    h.path = plot3(...
        path(1,:),...
        path(2,:),...
        path(3,:),...
        'LineStyle','-','Color','k');
end

% Plot current path position
if p.Results.PathPosition
    pt = eval(sprintf('%s(tsc.currentPathVar.Data(1),tsc.basisParams.Data(:,:,1))',...
        p.Results.PathFunc));
    h.pathPosition = plot3(pt(1),pt(2),pt(3),'ro');
end

if p.Results.NavigationVecs
    posData = squeeze(tsc.positionVec.Data)';
    r = sqrt(sum(posData.^2,2));
    len = 0.1*max(r);
    pathPt = eval(sprintf('%s(tsc.currentPathVar.Data(1),tsc.basisParams.Data(:,:,1))',...
        p.Results.PathFunc));
    h.tanVec = quiver3(...
        pathPt(1),pathPt(2),pathPt(3),...
        len*tsc.tanVec.Data(1,1),...
        len*tsc.tanVec.Data(1,2),...
        len*tsc.tanVec.Data(1,3),...
        'MaxHeadSize',0,'Color','r','LineStyle','-');
    h.perpVec = quiver3(...
        posData(1,1),posData(1,2),posData(1,3),...
        len*tsc.perpVec.Data(1,1,1),...
        len*tsc.perpVec.Data(2,1,1),...
        len*tsc.perpVec.Data(3,1,1),...
        'MaxHeadSize',0,'Color','g','LineStyle','-');
    h.desVec = quiver3(...
        posData(1,1),posData(1,2),posData(1,3),...
        len*tsc.velVectorDes.Data(1,1),...
        len*tsc.velVectorDes.Data(1,2),...
        len*tsc.velVectorDes.Data(1,3),...
        'MaxHeadSize',0,'Color','b','LineStyle','-');
    
end

if p.Results.LocalAero || p.FluidMoments.Moments
    h.table = uitable(h.fig,'Units','Normalized','FontSize',16,...
        'Position',[0.0099    0.0197    0.2880    0.9668],...
        'ColumnWidth','auto',...
        'ColumnName',{'Description','Value'},...
        'ColumnWidth',{150,200});
end

if p.Results.LocalAero
    [aeroStruct,surfNames] = obj.struct('OCT.aeroSurf');
    FLiftPart = rotation_sequence(tsc.eulerAngles.Data(:,:,1))*tsc.FLiftBdyPart.Data(:,:,1);
    FDragPart = rotation_sequence(tsc.eulerAngles.Data(:,:,1))*tsc.FDragBdyPart.Data(:,:,1);
    vAppPart  = rotation_sequence(tsc.eulerAngles.Data(:,:,1))*tsc.vAppLclBdy.Data(:,:,1);
    
    uLiftPart = FLiftPart./sqrt(sum(FLiftPart.^2,1));
    uDragPart = FDragPart./sqrt(sum(FDragPart.^2,1));
    uAppPart = vAppPart./sqrt(sum(vAppPart.^2,1));
    
    xlim(tsc.positionVec.Data(1,:,1)+obj.fuse.length.Value*[-1.5 1.5])
    ylim(tsc.positionVec.Data(2,:,1)+obj.fuse.length.Value*[-1.5 1.5])
    zlim(tsc.positionVec.Data(3,:,1)+obj.fuse.length.Value*[-1.5 1.5])
    

    for ii = 1:numel(surfNames)
    h.table.Data = [h.table.Data;...
        {surfNames{ii}},{''};...
        {'V App'} ,{sprintf('%0.2f',sqrt(sum(vAppPart(ii).^2,1)))};...
        {'F Lift'},{sprintf('%0.0f',sqrt(sum(FLiftPart(ii).^2,1)))};...
        {'F Drag'},{sprintf('%0.0f',sqrt(sum(FDragPart(ii).^2,1)))}];
    
        aeroCentVec = tsc.positionVec.Data(:,:,1)+...
            rotation_sequence(tsc.eulerAngles.Data(:,:,1))*aeroStruct(ii).aeroCentPosVec(:);
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

if p.Results.FluidMoments
    fluidStartRow = size(h.table.Data,1);
    h.table.Data = [h.table.Data;
        {'M Fluid Roll'} ,{sprintf('%0.0f',tsc.MFluidBdy.Data(1,1,1))};...
        {'M Fluid Pitch'},{sprintf('%0.0f',tsc.MFluidBdy.Data(2,1,1))};...
        {'M Fluid Yaw'}  ,{sprintf('%0.0f',tsc.MFluidBdy.Data(3,1,1))}];
end

% Set the font size
set(gca,'FontSize',p.Results.FontSize);

for ii = 1:length(tsc.eulerAngles.Time)
    for jj = 1:numel(hStatic)
        % Rotate and translate all aero surfaces
        pts = rotation_sequence(tsc.eulerAngles.Data(:,:,ii))*[...
            hStatic{jj}.x(:)';...
            hStatic{jj}.y(:)';...
            hStatic{jj}.z(:)']+...
            tsc.positionVec.Data(:,:,ii);
        
        h.surf{jj}.XData = pts(1,:);
        h.surf{jj}.YData = pts(2,:);
        h.surf{jj}.ZData = pts(3,:);
    end
    if p.Results.PlotTracer
        h.tracer.XData = [h.tracer.XData(2:end) tsc.positionVec.Data(1,:,ii)];
        h.tracer.YData = [h.tracer.YData(2:end) tsc.positionVec.Data(2,:,ii)];
        h.tracer.ZData = [h.tracer.ZData(2:end) tsc.positionVec.Data(3,:,ii)];
    end
    
    if ~isempty(p.Results.PathFunc)
        path = eval(sprintf('%s(linspace(0,1,1000),tsc.basisParams.Data(:,:,ii))',...
            p.Results.PathFunc));
        h.path.XData = path(1,:);
        h.path.YData = path(2,:);
        h.path.ZData = path(3,:);
    end
    
    % Plot current path position
    if p.Results.PathPosition
        pt = eval(sprintf('%s(tsc.currentPathVar.Data(ii),tsc.basisParams.Data(:,:,ii))',...
            p.Results.PathFunc));
        h.pathPosition.XData = pt(1);
        h.pathPosition.YData = pt(2);
        h.pathPosition.ZData = pt(3);
    end
    if p.Results.NavigationVecs
        pathPt = eval(sprintf('%s(tsc.currentPathVar.Data(ii),tsc.basisParams.Data(:,:,ii))',...
            p.Results.PathFunc));
        h.tanVec.XData = pathPt(1);
        h.tanVec.YData = pathPt(2);
        h.tanVec.ZData = pathPt(3);
        h.tanVec.UData = len*tsc.tanVec.Data(ii,1);
        h.tanVec.VData = len*tsc.tanVec.Data(ii,2);
        h.tanVec.WData = len*tsc.tanVec.Data(ii,3);
        
        h.perpVec.XData = tsc.positionVec.Data(1,:,ii);
        h.perpVec.YData = tsc.positionVec.Data(2,:,ii);
        h.perpVec.ZData = tsc.positionVec.Data(3,:,ii);
        h.perpVec.UData = len*tsc.perpVec.Data(ii,1);
        h.perpVec.VData = len*tsc.perpVec.Data(ii,2);
        h.perpVec.WData = len*tsc.perpVec.Data(ii,3);
        
        
        h.desVec.XData = tsc.positionVec.Data(1,:,ii);
        h.desVec.YData = tsc.positionVec.Data(2,:,ii);
        h.desVec.ZData = tsc.positionVec.Data(3,:,ii);
        h.desVec.UData = len*tsc.velVectorDes.Data(ii,1);
        h.desVec.VData = len*tsc.velVectorDes.Data(ii,2);
        h.desVec.WData = len*tsc.velVectorDes.Data(ii,3);
    end
    if p.Results.LocalAero
        aeroStruct = obj.struct('OCT.aeroSurf');
        FLiftPart = rotation_sequence(tsc.eulerAngles.Data(:,:,ii))*tsc.FLiftBdyPart.Data(:,:,ii);
        FDragPart = rotation_sequence(tsc.eulerAngles.Data(:,:,ii))*tsc.FDragBdyPart.Data(:,:,ii);
        vAppPart  = rotation_sequence(tsc.eulerAngles.Data(:,:,ii))*tsc.vAppLclBdy.Data(:,:,ii);
        
        uLiftPart = FLiftPart./sqrt(sum(FLiftPart.^2,1));
        uDragPart = FDragPart./sqrt(sum(FDragPart.^2,1));
        uAppPart  = vAppPart./sqrt(sum(vAppPart.^2,1));
        for jj = 1:numel(aeroStruct)
            h.table.Data{4*jj-2,2} = sprintf('%0.2f',sqrt(sum(vAppPart(jj).^2,1)));
            h.table.Data{4*jj-1,2} = sprintf('%0.0f',sqrt(sum(FLiftPart(jj).^2,1)));
            h.table.Data{4*jj+0,2} = sprintf('%0.0f',sqrt(sum(FDragPart(jj).^2,1)));
            
            aeroCentVec = tsc.positionVec.Data(:,:,ii)+...
                rotation_sequence(tsc.eulerAngles.Data(:,:,ii))*aeroStruct(jj).aeroCentPosVec(:);

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
            
            xlim(tsc.positionVec.Data(1,:,ii)+obj.fuse.length.Value*[-1.5 1.5])
            ylim(tsc.positionVec.Data(2,:,ii)+obj.fuse.length.Value*[-1.5 1.5])
            zlim(tsc.positionVec.Data(3,:,ii)+obj.fuse.length.Value*[-1.5 1.5])
        end
    end
    
    if p.Results.FluidMoments
        h.table.Data{fluidStartRow+1,2}   = sprintf('%0.0f',tsc.MFluidBdy.Data(1,1,ii));
        h.table.Data{fluidStartRow+2,2} = sprintf('%0.0f',tsc.MFluidBdy.Data(2,1,ii));
        h.table.Data{fluidStartRow+3,2} = sprintf('%0.0f',tsc.MFluidBdy.Data(3,1,ii));
    end

    
    h.title.String = {sprintf('Time = %.1f s',tsc.velocityVec.Time(ii)),...
        sprintf('Speed = %.1f m/s',norm(tsc.velocityVec.Data(:,:,ii)))};
    drawnow
    if p.Results.Pause
        pause
    end
end

end

