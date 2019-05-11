function createAllActuatorPlantBus()

elems(1) = Simulink.BusElement;
elems(1).Name = 'posVec';
elems(1).Dimensions = 3;
elems(1).DimensionsMode = 'Fixed';
elems(1).DataType = 'double';
elems(1).SampleTime = -1;
elems(1).Complexity = 'real';
elems(1).Description = '3 element vector of position, x, y and z in meters';
elems(1).Unit = 'm';

elems(2) = Simulink.BusElement;
elems(2).Name = 'velocityVec';
elems(2).Dimensions = 3;
elems(2).DimensionsMode = 'Fixed';
elems(2).DataType = 'double';
elems(2).SampleTime = -1;
elems(2).Complexity = 'real';
elems(2).Description = '3 element vector of velocity, in meters per sec';
elems(2).SampleTime = -1;
elems(1).Unit = 'm/s';

elems(3) = Simulink.BusElement;
elems(3).Name = 'eulerAngles';
elems(3).Dimensions = 3;
elems(3).DimensionsMode = 'Fixed';
elems(3).DataType = 'double';
elems(3).SampleTime = -1;
elems(3).Complexity = 'real';
elems(3).Description = '3 element vector of Euler angles, roll, pitch, yaw in rad';
elems(3).SampleTime = -1;
elems(3).Unit = 'rad';


PLANT = Simulink.Bus;
PLANT.Elements = elems;
PLANT.Description = 'Bus containing signals produced by the all actuator plant.';

assignin('base','plantBus',PLANT)

end