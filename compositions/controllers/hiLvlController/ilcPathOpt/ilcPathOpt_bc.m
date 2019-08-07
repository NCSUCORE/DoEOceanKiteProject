function ilcPathOpt_bc()
% Creates output bus used by allActuatorCtrl_cl

elems(1) = Simulink.BusElement;
elems(1).Name = 'basisParams';
% elems(1).Dimensions = -1;
elems(1).DimensionsMode = 'Fixed';
elems(1).DataType = 'double';
elems(1).SampleTime = -1;
elems(1).Complexity = 'real';
elems(1).Unit = '';

CONTROL = Simulink.Bus;
CONTROL.Elements = elems;
CONTROL.Description = 'Bus containing signals produced by the ILC path optimization high level controller';

assignin('base','hiLvlCtrlBus',CONTROL)

end