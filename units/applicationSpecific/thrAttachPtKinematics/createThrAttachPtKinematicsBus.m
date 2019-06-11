function createThrAttachPtKinematicsBus(attchPts)
elems(1) = Simulink.BusElement;
elems(1).Name = 'posVec';
elems(1).Dimensions = [3 1];
elems(1).DimensionsMode = 'Fixed';
elems(1).DataType = 'double';
elems(1).SampleTime = -1;
elems(1).Complexity = 'real';
elems(1).Description = '3 element vector of position, x, y and z in meters';
elems(1).Unit = 'm';

elems(2) = Simulink.BusElement;
elems(2).Name = 'velVec';
elems(2).Dimensions = [3 1];
elems(2).DimensionsMode = 'Fixed';
elems(2).DataType = 'double';
elems(2).SampleTime = -1;
elems(2).Complexity = 'real';
elems(2).Description = '3 element vector of position, x, y and z in meters';
elems(2).Unit = 'm';

    

% for ii = 2:length(attchPts)
%     elems(end+1) = Simulink.BusElement;
%     elems(end).Name = 'velVec';
%     elems(end).Dimensions = [3 1];
%     elems(end).DimensionsMode = 'Fixed';
%     elems(end).DataType = 'double';
%     elems(end).SampleTime = -1;
%     elems(end).Complexity = 'real';
%     elems(end).Description = '3 element vector of position, x, y and z in meters';
%     elems(end).Unit = 'm';
%     
%     elems(end+1) = Simulink.BusElement;
%     elems(end).Name = 'posVec';
%     elems(end).Dimensions = [3 1];
%     elems(end).DimensionsMode = 'Fixed';
%     elems(end).DataType = 'double';
%     elems(end).SampleTime = -1;
%     elems(end).Complexity = 'real';
%     elems(end).Description = '3 element vector of position, x, y and z in meters';
%     elems(end).Unit = 'm';
% 
% end

bs = Simulink.Bus;
bs.Elements = elems;
bs.Description = 'Bus containing signals produced by the all actuator plant.';

assignin('base','thrAttachPtKinematicsBus',bs)

end