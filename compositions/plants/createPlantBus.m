function createPlantBus()

elems(1) = Simulink.BusElement;
elems(1).Name = 'positionVec_m';
elems(1).Dimensions = 3;
elems(1).DimensionsMode = 'Fixed';
elems(1).DataType = 'double';
elems(1).SampleTime = -1;
elems(1).Complexity = 'real';
elems(1).Description = '3 element vector of position, x, y and z in meters';

elems(2) = Simulink.BusElement;
elems(2).Name = 'eulerAnglesVec_rad';
elems(2).Dimensions = 3;
elems(2).DimensionsMode = 'Fixed';
elems(2).DataType = 'double';
elems(2).SampleTime = -1;
elems(2).Complexity = 'real';
elems(2).Description = '3 element vector of euler angles [roll pitch yaw] in rad';

PLANT = Simulink.Bus;
PLANT.Elements = elems;
PLANT.Description = 'Bus containing signals produced by the plant.';

assignin('base','plantBus',PLANT)

end