function createSubmersiblePlatformBus()

elems(1) = Simulink.BusElement;
elems(1).Name = 'buoyPosVec';
elems(1).Dimensions = 3;
elems(1).DimensionsMode = 'Fixed';
elems(1).DataType = 'double';
elems(1).SampleTime = -1;
elems(1).Complexity = 'real';
elems(1).Description = '3 element vector of buoy position, x, y and z in meters';
elems(1).Unit = 'm';

elems(2) = Simulink.BusElement;
elems(2).Name = 'buoyVelocityVec';
elems(2).Dimensions = 3;
elems(2).DimensionsMode = 'Fixed';
elems(2).DataType = 'double';
elems(2).SampleTime = -1;
elems(2).Complexity = 'real';
elems(2).Description = '3 element vector of buoy velocity, in meters per sec';
elems(2).SampleTime = -1;
elems(2).Unit = 'm/s';

elems(3) = Simulink.BusElement;
elems(3).Name = 'landPosVec';
elems(3).Dimensions = 3;
elems(3).DimensionsMode = 'Fixed';
elems(3).DataType = 'double';
elems(3).SampleTime = -1;
elems(3).Complexity = 'real';
elems(3).Description = '3 element vector of landing platform position, x, y and z in meters';
elems(3).Unit = 'm';

elems(4) = Simulink.BusElement;
elems(4).Name = 'landVelocityVec';
elems(4).Dimensions = 3;
elems(4).DimensionsMode = 'Fixed';
elems(4).DataType = 'double';
elems(4).SampleTime = -1;
elems(4).Complexity = 'real';
elems(4).Description = '3 element vector of landing platform velocity, in meters per sec';
elems(4).SampleTime = -1;
elems(4).Unit = 'm/s';


platform = Simulink.Bus;
platform.Elements = elems;
platform.Description = 'Bus containing signals produced by the submersible platform';

assignin('base','platBus',platform)
end