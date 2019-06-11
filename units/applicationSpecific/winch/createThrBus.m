function createThrBus(numNodes)

elems(1) = Simulink.BusElement;
elems(1).Name = 'gndTenVec';
elems(1).Dimensions = [3 1];
elems(1).DimensionsMode = 'Fixed';
elems(1).DataType = 'double';
elems(1).SampleTime = -1;
elems(1).Complexity = 'real';
elems(1).Description = '3 element vector of position, x, y and z in meters';
elems(1).Unit = 'm';

elems(2) = Simulink.BusElement;
elems(2).Name = 'airTenVec';
elems(2).Dimensions = [3 1];
elems(2).DimensionsMode = 'Fixed';
elems(2).DataType = 'double';
elems(2).SampleTime = -1;
elems(2).Complexity = 'real';
elems(2).Description = '3 element vector of position, x, y and z in meters';
elems(2).Unit = 'm';

elems(3) = Simulink.BusElement;
elems(3).Name = 'nodePositions';
elems(3).Dimensions = [numNodes*3 1];
elems(3).DimensionsMode = 'Fixed';
elems(3).DataType = 'double';
elems(3).SampleTime = -1;
elems(3).Complexity = 'real';
elems(3).Description = '3 element vector of position, x, y and z in meters';
elems(3).Unit = 'm';

elems(4) = Simulink.BusElement;
elems(4).Name = 'nodeVelocities';
elems(4).Dimensions = [numNodes*3 1];
elems(4).DimensionsMode = 'Fixed';
elems(4).DataType = 'double';
elems(4).SampleTime = -1;
elems(4).Complexity = 'real';
elems(4).Description = '3 element vector of position, x, y and z in meters';
elems(4).Unit = 'm';

bs = Simulink.Bus;
bs.Elements = elems;
bs.Description = 'Bus containing signals produced by the all actuator plant.';

assignin('base','thrBus',bs)

end