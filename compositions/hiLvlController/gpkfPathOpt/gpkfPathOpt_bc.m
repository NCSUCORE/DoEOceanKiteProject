function gpkfPathOpt_bc()

% Creates output bus used by 
elems(1) = Simulink.BusElement;
elems(1).Name = 'basisParams';
elems(1).Dimensions = 5;
elems(1).DimensionsMode = 'Fixed';
elems(1).DataType = 'double';
elems(1).SampleTime = -1;
elems(1).Complexity = 'real';
elems(1).Unit = '';

CONTROL = Simulink.Bus;
CONTROL.Elements = elems;
CONTROL.Description = 'Bus constant basis parameters';

assignin('base','hiLvlCtrlBus',CONTROL)

end