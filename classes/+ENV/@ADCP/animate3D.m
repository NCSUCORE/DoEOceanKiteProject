function animate3D(obj,varargin)
%% Input parsing
p = inputParser;

% ---Parameters for saving a gif---
% Switch to enable saving 0 = don't save
addParameter(p,'SaveGif',false,@islogical)
% Path to saved file, default is ./output
addParameter(p,'GifPath',fullfile(fileparts(which('OCTProject.prj')),'output')); % Default output location is ./output folder
% Name of saved file, default is flowProfileAnimation.gif
addParameter(p,'GifFile','flowHeading.gif');
% Time step between frames of gif, default is 30 fps
addParameter(p,'GifTimeStep',1/30,@isnumeric)

% Start time
addParameter(p,'StartTime',0,@isnumeric)
% End time
addParameter(p,'EndTime',obj.flowVecTSeries.Value.Time(end),@isnumeric)

% ---Parameters used for plotting---
% Set font size
addParameter(p,'FontSize',get(0,'defaultAxesFontSize'),@isnumeric)
% ---Parse the output---
parse(p,varargin{:})

if p.Results.StartTime>=p.Results.EndTime
    error('StartTime must be less than EndTime')
end

% Setup some infrastructure type things
% If the user wants to save something and the specified directory does not
% exist, create it
if p.Results.SaveGif && ~exist(p.Results.GifPath, 'dir')
    mkdir(p.Results.GifPath)
end

[flowTimeseries,dirTimeseries] = crop(obj,p.Results.StartTime,p.Results.EndTime);

h.fig = figure;
hold(gca,'on')
grid(gca,'on')
h.allVecs = quiver3(...
    zeros(1,numel(obj.depths.Value)),...
    zeros(1,numel(obj.depths.Value)),...
    obj.depths.Value,...
    flowTimeseries.Data(1,:,1),...
    flowTimeseries.Data(2,:,1),...
    flowTimeseries.Data(3,:,1),...
    0,...
    'DisplayName','Flow Vector',...
    'Color',[0    0.4470    0.7410]);
hold on
h.instantMean = quiver3(0,0,0,...
    mean(squeeze(flowTimeseries.Data(1,:,1))),...
    mean(squeeze(flowTimeseries.Data(2,:,1))),...
    0,...
    'DisplayName','Instantaneous Mean',...
    'Color','r');
h.totalMean = quiver3(0,0,0,...
    mean(mean(flowTimeseries.Data(1,:,:))),...
    mean(mean(flowTimeseries.Data(1,:,:))),...
    0,...
    'DisplayName','All Time Mean',...
    'Color',[0 0.75 0]);

axis equal
xlabel('X')
ylabel('Y')
zlabel('Z')
h.legend = legend;
view([66 87])
xlim([-2.5 2.5])
ylim([-2.5 2.5])
zlim([0 max(obj.depths.Value)])
if strcmpi(getenv('username'),'M.Cobb') % If this is on mitchells laptop
    h.fig.Position = 1e3*[1.0178    0.0418    0.5184    0.7408];
end

if p.Results.SaveGif
    frame = getframe(h.fig);
    im = frame2im(frame);
    [imind,cm] = rgb2ind(im,256);
    imwrite(imind,cm,fullfile(p.Results.GifPath,p.Results.GifFile),'gif', 'Loopcount',inf);
end

for ii = 2:numel(flowTimeseries.Time)
    h.allVecs.UData = flowTimeseries.Data(1,:,ii);
    h.allVecs.VData = flowTimeseries.Data(2,:,ii);
    h.allVecs.WData = flowTimeseries.Data(3,:,ii);
    
    h.instantMean.UData = mean(squeeze(flowTimeseries.Data(1,:,ii)));
    h.instantMean.VData = mean(squeeze(flowTimeseries.Data(2,:,ii)));
    
    drawnow
    % Save gif of results
    if p.Results.SaveGif
        frame = getframe(h.fig);
        im = frame2im(frame);
        [imind,cm] = rgb2ind(im,256);
        imwrite(imind,cm,fullfile(p.Results.GifPath,p.Results.GifFile),'gif','WriteMode','append','DelayTime',p.Results.GifTimeStep)
        
    end
end
end