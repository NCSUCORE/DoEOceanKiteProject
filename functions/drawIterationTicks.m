function drawIterationTicks(varargin)
switch nargin
    case 1
        axHandle = gca;
        tickTimes = varargin{1};
    case 2
        axHandle = varargin{1};
        tickTimes = varargin{2};
    otherwise
        error('Incorrect number of input arguments')
end
% Calculate what the iteration numbers will be
tickLabels = 0:5:numel(tickTimes);
% Set axes units to be normalized
set(gca,'Units','Normalized')
% Subtract some from the vertical so that the axis label will fit
set(gca,'Position',get(gca,'Position')-[0 0 0 0.05])
% Turn on the grid lines
% set(gca,'XGrid','on')
% set(gca,'GridLineStyle','--')
% Create the overlay axes with the different tick marks
topAxHandle = axes('Position',get(axHandle,'Position'),...
    'XAxisLocation','top',...
    'YTick',[],...
    'Color','none');
% Set the locations of the ticks in time
topAxHandle.XTick = tickTimes(tickLabels+1);
% Set the label of the axis
xlabel('Iteration Number')
% Set the label
topAxHandle.XTickLabel = sprintfc('%d',tickLabels);
% Link the axes between the two
linkaxes([axHandle topAxHandle],'x')
% Set the grid on
% set(gca,'XGrid','on')

% Return focus to the origional axes
axes(axHandle)
% Set background color of origional to clear
axHandle.Color = 'none';
box off

end