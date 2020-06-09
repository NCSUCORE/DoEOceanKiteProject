maskObj = Simulink.Mask.get(gcb);
airfoilSelectionObj = maskObj.Parameters(strcmpi({maskObj.Parameters.Name},'airfoilSelection'));

% Don't change to str2double, that throws nan for vector-valued parameters
clFitLims = str2num(get_param(gcb,'clFitLims'))*pi/180;
clFitOrder = str2num(get_param(gcb,'clFitOrder'));

cdFitLims = str2num(get_param(gcb,'cdFitLims'))*pi/180;
cdFitOrder = str2num(get_param(gcb,'cdFitOrder'));

AR = str2num(get_param(gcb,'AR'));
OE = str2num(get_param(gcb,'OE'));

useFitStr = get_param(gcb,'useFit');
useFit = false;
if strcmp(useFitStr,'on')
    useFit = true;
end

aeroTable = loadAeroTable(airfoilSelectionObj.Value,...
    clFitLims,clFitOrder,cdFitLims,cdFitOrder,OE,AR,useFit);

clearvars maskObj airfoilSelectionObj clFitLims ...
    clFitOrder cdFitLims cdFitOrder AR OE...
    useFit