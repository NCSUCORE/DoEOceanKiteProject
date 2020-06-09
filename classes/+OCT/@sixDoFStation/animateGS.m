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
addParameter(p,'endTime',tsc.eulerAngles.Time(end),@isnumeric);

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
% Plot the ground station
addParameter(p,'GroundStation',[],@(x) isa(x,'OCT.sixDoFStation'))
% Color tracer according to power production/consumption
addParameter(p,'ColorTracer',false,@islogical)
% How long (in seconds) to keep the tracer on for
addParameter(p,'TracerDuration',5,@isnumeric)
% Plot a red dot on the closest point on the path
addParameter(p,'PathPosition',false,@islogical)
% Plot normal, tangent and desired vectors
addParameter(p,'NavigationVecs',false,@islogical)
% Plot tether nodal net force vecs
addParameter(p,'TetherNodeForces',false,@islogical)
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
tscTmp = tsc.resample(p.Results.timeStep);



sz = getBusDims;


hold on
   

if ~isempty(p.Results.GroundStation)
    [xCyl,yCyl,zCyl] = cylinder([0 p.Results.GroundStation.cylRad.Value*ones(1,98) 0]);
    if isempty(p.Results.GroundStation.cylTotH.Value)
        warning('Warning total height property empty, using zMatExt values')
        height = max(p.Results.GroundStation.zMatExt.Value)-min(p.Results.GroundStation.zMatExt.Value);
    else
        height = p.Results.GroundStation.cylTotH.Value;
    end
    zCyl = zCyl*height-height/2;
    xCyl = xCyl([1 2 99 100],:);
    yCyl = yCyl([1 2 99 100],:);
    zCyl = zCyl([1 2 99 100],:);
    h.gndStn = surf(xCyl,yCyl,zCyl,'FaceColor',0.5*[1 1 1]);
end


if p.Results.TetherNodeForces
    posVecs    = tscTmp.anchThrNodePosVecs.getsamples(1).Data;
    force1Vecs = tscTmp.anchThrNode1FVec.getsamples(1).Data;
    forceNVecs = tscTmp.anchThrNodeNFVec.getsamples(1).Data;
    
    lengthScl = 10;
   
    % For each tether
    for ii = 1:size(posVecs,3)
        fVec1 = force1Vecs(:,:,ii);
        fVecN = forceNVecs(:,:,ii);
        
        fVec1 = lengthScl*fVec1./sqrt(sum(fVec1.^2));
        fVecN = lengthScl*fVecN./sqrt(sum(fVecN.^2));
        
        h.anchThrFrcVec1(ii) = plot3(...
            [posVecs(1,1,ii) posVecs(1,1,ii)+fVec1(1)],...
            [posVecs(2,1,ii) posVecs(2,1,ii)+fVec1(2)],...
            [posVecs(3,1,ii) posVecs(3,1,ii)+fVec1(3)],...
            'Color','r','LineStyle','-');
        
        h.anchThrFrcVecN(ii) = plot3(...
            [posVecs(1,end,ii) posVecs(1,end,ii)+fVecN(1)],...
            [posVecs(2,end,ii) posVecs(2,end,ii)+fVecN(2)],...
            [posVecs(3,end,ii) posVecs(3,end,ii)+fVecN(3)],...
            'Color','r','LineStyle','-');
    end
end

% Plot the anchor tethers
if ~isempty(p.Results.GroundStation) && isprop(tscTmp,'anchThrNodePosVecs')
    nodePosVecs = tscTmp.anchThrNodePosVecs.getsamples(1).Data;
    for ii = 1:sz.numTethersAnchor
        h.anchThr{ii} = plot3(...
            nodePosVecs(1,:,ii),...
            nodePosVecs(2,:,ii),...
            nodePosVecs(3,:,ii),...
            'Color','k','LineWidth',1.5,'LineStyle','-','Marker','o',...
            'MarkerSize',4,'MarkerFaceColor','k');
    end
end



% Set the font size
set(gca,'FontSize',p.Results.FontSize);

% Set the viewpoint
view(p.Results.View)

% % Set plot limits
% setLimsToQuartSphere(gca,squeeze(tscTmp.positionVec.Data)',...
%     'PlotAxes',true);

% Attempt to set plot axes limits automatically
allPlots = allchild(gca);


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
h.title = title(sprintf('Time = %.1f s',0));


for ii = 1:numel(tscTmp.gndStnFlowVecs.Time)
%     timeStamp = tscTmp.positionVec.Time(ii);
%     eulAngs   = tscTmp.eulerAngles.getsamples(ii).Data;
%     posVec    = tscTmp.positionVec.getsamples(ii).Data;
grid on
    

    if isfield(h,'gndStn')
        R = rotation_sequence(tscTmp.gndStnEulerAngles.getsamples(ii).Data);
        posVec = tscTmp.gndStnPositionVec.getsamples(ii).Data(:);
        pts = R*[xCyl(:)' ; yCyl(:)' ; zCyl(:)'];
        h.gndStn.XData = reshape(pts(1,:),size(xCyl)) + posVec(1);
        h.gndStn.YData = reshape(pts(2,:),size(yCyl)) + posVec(2);
        h.gndStn.ZData = reshape(pts(3,:),size(zCyl)) + posVec(3);
        
    end
    
 
    if p.Results.TetherNodeForces
        posVecs    = tscTmp.anchThrNodePosVecs.getsamples(ii).Data;
        force1Vecs = tscTmp.anchThrNode1FVec.getsamples(ii).Data;
        forceNVecs = tscTmp.anchThrNodeNFVec.getsamples(ii).Data;
        
        lengthScl = 10;
        
        % For each tether
        for jj = 1:size(posVecs,3)
            fVec1 = force1Vecs(:,:,jj);
            fVecN = forceNVecs(:,:,jj);
            
            fVec1 = lengthScl*fVec1./sqrt(sum(fVec1.^2));
            fVecN = lengthScl*fVecN./sqrt(sum(fVecN.^2));

            h.anchThrFrcVec1(jj).XData = [posVecs(1,1,jj) posVecs(1,1,jj)+fVec1(1)];
            h.anchThrFrcVec1(jj).YData = [posVecs(2,1,jj) posVecs(2,1,jj)+fVec1(2)];
            h.anchThrFrcVec1(jj).ZData = [posVecs(3,1,jj) posVecs(3,1,jj)+fVec1(3)];

            h.anchThrFrcVecN(jj).XData = [posVecs(1,end,jj) posVecs(1,end,jj)+fVecN(1)];
            h.anchThrFrcVecN(jj).YData = [posVecs(2,end,jj) posVecs(2,end,jj)+fVecN(2)];
            h.anchThrFrcVecN(jj).ZData = [posVecs(3,end,jj) posVecs(3,end,jj)+fVecN(3)];
        end
    end
    
   


    % update the anchor tether(s) if exists
    if isfield(h,'anchThr')
        nodePosVecs = tscTmp.anchThrNodePosVecs.getsamples(ii).Data;
        for jj = 1:sz.numTethersAnchor
            h.anchThr{jj}.XData = nodePosVecs(1,:,jj);
            h.anchThr{jj}.YData = nodePosVecs(2,:,jj);
            h.anchThr{jj}.ZData = nodePosVecs(3,:,jj);
        end
    end
    
    % Update the title
    h.title.String =  sprintf('Time = %.1f s',tscTmp.gndStnPositionVec.Time(ii));
    
    
    
   
    

%     
    % Update scrolling plots
    if ~isempty(p.Results.ScrollPlots)
        for jj = 1:numel(h.TimeLine)
            h.TimeLine(jj).XData = tscTmp.gndStnPositionVec.Time(ii)*[1 1];
        end
    end
    
    drawnow
    xlabel('X (m)')
    ylabel('Y (m)')
    zlabel('Distance from Seabed (m)')
    
    zlim([0,220])
    % Save gif of results
    if p.Results.SaveGif
        frame       = getframe(gca);
        im          = frame2im(frame);
        [imind,cm]  = rgb2ind(im,256);
        if ii == 1
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


