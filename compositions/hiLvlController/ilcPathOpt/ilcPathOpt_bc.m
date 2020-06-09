function ilcPathOpt_bc()
% Creates output bus used by allActuatorCtrl_cl

try
    basisParamsDims = evalin('base','size(hiLvlCtrl.basisParams.Value);');
catch
    basisParamsDims = evalin('base','size(hiLvlCtrl.initBasisParams.Value);');
end

elems(1) = Simulink.BusElement;
elems(1).Name = 'basisParams';
elems(1).Dimensions = basisParamsDims;
elems(1).DimensionsMode = 'Fixed';
elems(1).DataType = 'double';
elems(1).SampleTime = -1;
elems(1).Complexity = 'real';
elems(1).Unit = '';


elems(2) = Simulink.BusElement;
elems(2).Name = 'ilcTrigger';
elems(2).Dimensions = 1;
elems(2).DimensionsMode = 'Fixed';
elems(2).DataType = 'boolean';
elems(2).SampleTime = -1;
elems(2).Complexity = 'real';
elems(2).Unit = '';

CONTROL = Simulink.Bus;
CONTROL.Elements = elems;
CONTROL.Description = 'Bus containing signals produced by the ILC path optimization high level controller';

assignin('base','hiLvlCtrlBus',CONTROL)

end