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
h.title = title(sprintf('Time = %.1f',0));

% Tracer
if p.Results.PlotTracer
    h.tracer = plot3(...
        nan([round(p.Results.TracerDuration/p.Results.timeStep) 1]),...
        nan([round(p.Results.TracerDuration/p.Results.timeStep) 1]),...
        nan([round(p.Results.TracerDuration/p.Results.timeStep) 1]),...
        'Color','r','LineStyle','-');
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
    
    h.title.String = sprintf('Time = %.1f',tsc.eulerAngles.Time(ii));
    drawnow
end

end

