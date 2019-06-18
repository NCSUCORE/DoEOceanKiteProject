function createModAyazFlowEnvironmentBus()
elems(1) = Simulink.BusElement;
elems(1).Name = 'flow';
elems(1).Dimensions = 3;
elems(1).DimensionsMode = 'Fixed';
elems(1).DataType = 'double';
elems(1).SampleTime = -1;
elems(1).Complexity = 'real';
elems(1).Description = 'Flow vector in m/s in ground coordinates';
elems(1).Unit = 'm/s';

elems(2) = Simulink.BusElement;
elems(2).Name = 'windSpeed';
elems(2).Dimensions = 1;
elems(2).DimensionsMode = 'Fixed';
elems(2).DataType = 'double';
elems(2).SampleTime = -1;
elems(2).Complexity = 'real';
elems(2).Description = 'Wind speed in meters per sec';
elems(2).Unit = 'm/s';

elems(3) = Simulink.BusElement;
elems(3).Name = 'windDir';
elems(3).Dimensions = 1;
elems(3).DimensionsMode = 'Fixed';
elems(3).DataType = 'double';
elems(3).SampleTime = -1;
elems(3).Complexity = 'real';
elems(3).Description = 'Wind direction in radians';
elems(3).Unit = 'rad';

ENV = Simulink.Bus;
ENV.Elements = elems;
ENV.Description = 'Bus containing signals produced by the environment subsystem with flow added.';

assignin('base','envBus',ENV)

end