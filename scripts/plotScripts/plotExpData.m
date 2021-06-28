function [varargout] = plotExpData(runData,flightVar,varargin)
%Flexible Plot Function for Experimental Data

p = inputParser;
p.KeepUnmatched = true;
%Required Inputs
addRequired(p,'runData');
addRequired(p,'flightVar', @(x) isfield(runData{1},x));
%Optional Inputs
%Run Number if plotting multiple runs
addParameter(p,'runNum',1);
%Figure number if looping through runs with multiple figures
addParameter(p,'figNum',1);
%Legend Entry
addParameter(p,'legendEntry','',@(x) ischar(x) || isstr(x))
%Y Axis Label
addParameter(p,'yLegend','Value',@(x) ischar(x) || isstr(x))
%Data scaling for converting from rad to deg etc.
addParameter(p,'dataScale',1,@(x) isnumeric(x))

parse(p,runData,flightVar,varargin{:})

j = p.Results.figNum;
%Turn off legend entry for blank legend entries
if isempty(p.Results.legendEntry)
    displayLeg = 'off';
else
    displayLeg = 'on';
end

dataStr = strcat('runData{i}.',p.Results.flightVar);
plotData = evalin('base',dataStr);
p.Unmatched
figure(j); hold on; grid on;
set(gcf,'Position',[100 100 800 400])
set(gca,'ColorOrderIndex',p.Results.runNum)
if ~isempty(fieldnames(p.Unmatched))
    plot(plotData*p.Results.dataScale,'LineWidth',1.5,...
        'DisplayName',p.Results.legendEntry,p.Unmatched)
else
    plot(plotData*p.Results.dataScale,'LineWidth',1.5,...
        'DisplayName',p.Results.legendEntry)
end
a = gca;
a.Children(end).Annotation.LegendInformation.set...
    ('IconDisplayStyle',displayLeg)
xlabel 'Time [s]'
ylabel(p.Results.yLegend)
legend('Location','northwest')
set(gca,'FontSize',15)
%iterate figure number if called 
if nargout ~= 0
    varargout{1} = j+1;
end
end

