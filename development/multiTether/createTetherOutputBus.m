function createTetherOutputBus()

elems(1) = Simulink.BusElement;
elems(1).Name = 'gndNodeForceVec';
elems(1).Dimensions = [3 1];
elems(1).DimensionsMode = 'Fixed';
elems(1).DataType = 'double';
elems(1).SampleTime = -1;
elems(1).Complexity = 'real';
elems(1).Description = '3 element vector of force in intertial frame';
elems(1).Unit = 'm';

elems(2) = Simulink.BusElement;
elems(2).Name = 'airNodeForceVec';
elems(2).Dimensions = [3 1];
elems(2).DimensionsMode = 'Fixed';
elems(2).DataType = 'double';
elems(2).SampleTime = -1;
elems(2).Complexity = 'real';
elems(2).Description = '3 element vector of force in inertial frame';
elems(2).SampleTime = -1;
elems(2).Unit = 'm/s';

TETHER = Simulink.Bus;
TETHER.Elements = elems;
% PLANT.Description = 'Bus containing signals produced by the all actuator plant.';

assignin('base','tetherOutputBus',TETHER)

end