function constantUniformFlow_bc()

elems(1) = Simulink.BusElement;
elems(1).Name = 'flowVelocityVec';
elems(1).Dimensions = [3 1];
elems(1).DimensionsMode = 'Fixed';
elems(1).DataType = 'double';
elems(1).SampleTime = -1;
elems(1).Complexity = 'real';
elems(1).Description = 'Wind speed in meters per sec';
elems(1).Unit = 'm/s';


ENV = Simulink.Bus;
ENV.Elements = elems;
ENV.Description = 'Bus containing signals produced by the environment subsystem.';

assignin('base','envBus',ENV)

end