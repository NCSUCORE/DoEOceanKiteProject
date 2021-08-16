function createThrTenVecBus
% Create output bus for tether_ul block.  This function is
% automatically called by the mask initialization,
% tether_init whenever the tether_ul block is
% used in a model

elems(1) = Simulink.BusElement;
elems(1).Name = 'tenVec';
elems(1).Dimensions = [3 1];
elems(1).DimensionsMode = 'Fixed';
elems(1).DataType = 'double';
elems(1).SampleTime = -1;
elems(1).Complexity = 'real';
elems(1).Description = '3 element vector of tension force in the ground/inertial frame.';
elems(1).Unit = 'N';

bs = Simulink.Bus;
bs.Elements = elems;
bs.Description = 'Bus tension force at an end node of one tether.';

assignin('base','thrTenVecBus',bs)

end