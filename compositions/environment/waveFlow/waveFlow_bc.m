function createWaveFlowEnvironmentBus()

elems(1) = Simulink.BusElement;
elems(1).Name = 'flowVelocityVec';
elems(1).Dimensions = [3 1];
elems(1).DimensionsMode = 'Fixed';
elems(1).DataType = 'double';
elems(1).SampleTime = -1;
elems(1).Complexity = 'real';
elems(1).Description = 'Flow velocity vector applied to tethers';
elems(1).Unit = 'm/s';

elems(2) = Simulink.BusElement;
elems(2).Name = 'psudoPlatformFlowVec';
elems(2).Dimensions = [3 1];
elems(2).DimensionsMode = 'Fixed';
elems(2).DataType = 'double';
elems(2).SampleTime = -1;
elems(2).Complexity = 'real';
elems(2).Description = 'See image in waveFlow_ul.slx';
elems(2).Unit = 'kg/(m*s)';

elems(3) = Simulink.BusElement;
elems(3).Name = 'oceanDepth';
elems(3).Dimensions = 1;
elems(3).DimensionsMode = 'Fixed';
elems(3).DataType = 'double';
elems(3).SampleTime = -1;
elems(3).Complexity = 'real';
elems(3).Description = 'See variable name';
elems(3).Unit = 'm';


ENV = Simulink.Bus;
ENV.Elements = elems;
ENV.Description = 'Bus containing signals produced by the environment subsystem.';

assignin('base','envBus',ENV)

end