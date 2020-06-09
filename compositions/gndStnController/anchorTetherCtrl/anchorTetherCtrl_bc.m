function anchorTetherCtrl_bc()
% Creates output bus used by anchorTetherCtrl

elems(1) = Simulink.BusElement;
elems(1).Name = 'winchSpeeds';
elems(1).Dimensions = 3;
elems(1).DimensionsMode = 'Fixed';
elems(1).DataType = 'double';
elems(1).SampleTime = -1;
elems(1).Complexity = 'real';
elems(1).Unit = 'm/s';

CONTROL = Simulink.Bus;
CONTROL.Elements = elems;
CONTROL.Description = 'Bus containing signals produced by the anchor tether controller';

assignin('base','gndStnCtrlBus',CONTROL)

end