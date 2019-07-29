function createPlantBus
% Creates output bus used by allActuatorCtrl_cl

elems(1) = Simulink.BusElement;
elems(1).Name = 'positionVec';
elems(1).Dimensions = [3 1];
elems(1).DimensionsMode = 'Fixed';
elems(1).DataType = 'double';
elems(1).SampleTime = -1;
elems(1).Complexity = 'real';
elems(1).Unit = 'm';

elems(2) = Simulink.BusElement;
elems(2).Name = 'velocityVec';
elems(2).Dimensions = [3 1];
elems(2).DimensionsMode = 'Fixed';
elems(2).DataType = 'double';
elems(2).SampleTime = -1;
elems(2).Complexity = 'real';
elems(2).Unit = 'm/s';

elems(3) = Simulink.BusElement;
elems(3).Name = 'eulerAngles';
elems(3).Dimensions = [3 1];
elems(3).DimensionsMode = 'Fixed';
elems(3).DataType = 'double';
elems(3).SampleTime = -1;
elems(3).Complexity = 'real';
elems(3).Unit = 'rad';

elems(4) = Simulink.BusElement;
elems(4).Name = 'angularVel';
elems(4).Dimensions = [3 1];
elems(4).DimensionsMode = 'Fixed';
elems(4).DataType = 'double';
elems(4).SampleTime = -1;
elems(4).Complexity = 'real';
elems(4).Unit = 'rad/s';

elems(5) = Simulink.BusElement;
elems(5).Name = 'winchPower';
elems(5).Dimensions = 1;
elems(5).DimensionsMode = 'Fixed';
elems(5).DataType = 'double';
elems(5).SampleTime = -1;
elems(5).Complexity = 'real';
elems(5).Unit = 'W';


CONTROL = Simulink.Bus;
CONTROL.Elements = elems;
CONTROL.Description = 'Bus containing signals produced by the all actuator controller';

assignin('base','plantBus',CONTROL)

end