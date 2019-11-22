function oneDoF_bc()
% Creates output bus used by allActuatorCtrl_cl

elems(1) = Simulink.BusElement;
elems(1).Name = 'moment';
elems(1).Dimensions = 1;
elems(1).DimensionsMode = 'Fixed';
elems(1).DataType = 'double';
elems(1).SampleTime = -1;
elems(1).Complexity = 'real';
elems(1).Unit = 'N*m';
elems(1).Description = 'Turning moment applied by a motor to rotate the ground station.';

CONTROL = Simulink.Bus;
CONTROL.Elements = elems;
CONTROL.Description = 'Bus containing signals produced by the controller for the 1 DoF gnd stn';

assignin('base','gndStnCtrlBus',CONTROL)

end