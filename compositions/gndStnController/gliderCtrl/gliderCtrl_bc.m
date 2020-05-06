function gliderCtrl_bc()
% Creates output bus used by allActuatorCtrl_cl
elems(1) = Simulink.BusElement;
elems(1).Name = 'ctrlSurfDeflection';
elems(1).Dimensions = [4 1];
elems(1).DimensionsMode = 'Fixed';
elems(1).DataType = 'double';
elems(1).SampleTime = -1;
elems(1).Complexity = 'real';
elems(1).Unit = 'rad/s^2';

CONTROL = Simulink.Bus;
CONTROL.Elements = elems;
CONTROL.Description = 'Bus containing signals produced controller for the glider';

assignin('base','gndStnCtrlBus',CONTROL)

end