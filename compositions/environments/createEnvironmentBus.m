function createEnvironmentBus()

elems(1) = Simulink.BusElement;
elems(1).Name = 'windSpeed_mPs';
elems(1).Dimensions = 1;
elems(1).DimensionsMode = 'Fixed';
elems(1).DataType = 'double';
elems(1).SampleTime = -1;
elems(1).Complexity = 'real';
elems(1).Description = 'Wind speed in meters per sec';

elems(2) = Simulink.BusElement;
elems(2).Name = 'windDir_rad';
elems(2).Dimensions = 1;
elems(2).DimensionsMode = 'Fixed';
elems(2).DataType = 'double';
elems(2).SampleTime = -1;
elems(2).Complexity = 'real';
elems(2).Description = 'Wind direction in radians';

ENV = Simulink.Bus;
ENV.Elements = elems;
ENV.Description = 'Bus containing signals produced by the environment subsystem.';

assignin('base','envBus',ENV)

end