function createThreeTetherThreeSurfaceCtrlBus()
% Creates output bus used by allActuatorCtrl_cl

elems(1) = Simulink.BusElement;
elems(1).Name = 'ctrlSurfDeflection';
elems(1).Dimensions = 2;
elems(1).DimensionsMode = 'Fixed';
elems(1).DataType = 'double';
elems(1).SampleTime = -1;
elems(1).Complexity = 'real';
elems(1).Unit = 'rad';

elems(2) = Simulink.BusElement;
elems(2).Name = 'winchSpeeds';
elems(2).Dimensions = 3;
elems(2).DimensionsMode = 'Fixed';
elems(2).DataType = 'double';
elems(2).SampleTime = -1;
elems(2).Complexity = 'real';
elems(2).Unit = 'm/s';

CONTROL = Simulink.Bus;
CONTROL.Elements = elems;
CONTROL.Description = 'Bus containing signals produced by the all actuator controller';

assignin('base','ctrlBus',CONTROL)

end