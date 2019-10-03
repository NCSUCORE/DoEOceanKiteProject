function animate(obj,varargin)
%% Input parsing
p = inputParser;


% ---Parameters for saving a gif---
% Switch to enable saving 0 = don't save
addParameter(p,'SaveGif',false,@islogical)
% Path to saved file, default is ./output
addParameter(p,'GifPath',fullfile(fileparts(which('OCTProject.prj')),'output')); % Default output location is ./output folder
% Name of saved file, default is flowProfileAnimation.gif
addParameter(p,'GifFile','flowProfileAnimation.gif');
% Time step between frames of gif, default is 30 fps
addParameter(p,'GifTimeStep',1/30,@isnumeric)

% ---Parameters used for plotting---
% Set font size
addParameter(p,'FontSize',get(0,'defaultAxesFontSize'),@isnumeric)
% ---Parse the output---
parse(p,varargin{:})

% Setup some infrastructure type things
% If the user wants to save something and the specified directory does not
% exist, create it
if p.Results.SaveGif && ~exist(p.Results.GifPath, 'dir')
    mkdir(p.Results.GifPath)
end

h.fig = figure;
subplot(1,4,1);
h.magPlot = plot(sqrt(sum(obj.flowVecTSeries.Data(:,:,1).^2)),obj.depths.Value,...
    'LineWidth',1.5,'Color','k');
grid on
xlabel('Speed [m/s]')
ylabel('Height from sea floor [m]')

subplot(1,4,2);
h.EPlot = plot(obj.flowVecTSeries.Data(1,:,1),obj.depths.Value,...
    'LineWidth',1.5,'Color','k');
grid on
xlabel('$v_x$ [m/s]')
ylabel('Height from sea floor [m]')

subplot(1,4,3);
h.NPlot = plot(obj.flowVecTSeries.Data(2,:,1),obj.depths.Value,...
    'LineWidth',1.5,'Color','k');
grid on
xlabel('$v_y$ [m/s]')
ylabel('Height from sea floor [m]')

subplot(1,4,4);
h.ZPlot = plot(obj.flowVecTSeries.Data(3,:,1),obj.depths.Value,...
    'LineWidth',1.5,'Color','k');
grid on
xlabel('$v_z$ [m/s]')
ylabel('Height from sea floor [m]')

h.title = annotation('textbox', [0 0.875 1 0.1], ...
    'String', datestr(obj.dateTimes(1),'dd-mmm-yyyy HH:MM:SS'), ...
    'EdgeColor', 'none', ...
    'HorizontalAlignment', 'center',...
    'FontSize',22);

linkaxes(findall(gcf,'Type','axes'),'xy')
xlim([-5 5])
% Set the font size
set(gca,'FontSize',p.Results.FontSize);

if p.Results.SaveGif
    frame = getframe(h.fig);
    im = frame2im(frame);
    [imind,cm] = rgb2ind(im,256);
    imwrite(imind,cm,fullfile(p.Results.GifPath,p.Results.GifFile),'gif', 'Loopcount',inf);
end

for ii = 2:size(obj.flowVecTSeries.Data,3)
    h.title.String = datestr(obj.dateTimes(ii),'dd-mmm-yyyy HH:MM:SS');
    h.magPlot.XData = sqrt(sum(obj.flowVecTSeries.Data(:,:,ii).^2));
    h.EPlot.XData = obj.flowVecTSeries.Data(1,:,ii);
    h.NPlot.XData = obj.flowVecTSeries.Data(2,:,ii);
    h.ZPlot.XData = obj.flowVecTSeries.Data(3,:,ii);
    drawnow
    % Save gif of results
    if p.Results.SaveGif
        frame = getframe(h.fig);
        im    = frame2im(frame);
        [imind,cm] = rgb2ind(im,256);
        imwrite(imind,cm,fullfile(p.Results.GifPath,p.Results.GifFile),'gif','WriteMode','append','DelayTime',p.Results.GifTimeStep)
    end
end
end