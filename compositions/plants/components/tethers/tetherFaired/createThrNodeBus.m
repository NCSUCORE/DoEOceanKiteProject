function createThrNodeBus(numNodes)
% Create output bus for tether_ul block.  This function is
% automatically called by the mask initialization,
% tether_init whenever the tether_ul block is
% used in a model

elems(1) = Simulink.BusElement;
elems(1).Name = 'nodePositions';
elems(1).Dimensions = [3 numNodes];
elems(1).DimensionsMode = 'Fixed';
elems(1).DataType = 'double';
elems(1).SampleTime = -1;
elems(1).Complexity = 'real';
elems(1).Description = 'Vertically concatenated 3 element node positions in ground/inertial frame';
elems(1).Unit = 'm';

elems(2) = Simulink.BusElement;
elems(2).Name = 'nodeVelocities';
elems(2).Dimensions = [3 numNodes];
elems(2).DimensionsMode = 'Fixed';
elems(2).DataType = 'double';
elems(2).SampleTime = -1;
elems(2).Complexity = 'real';
elems(2).Description = 'Vertically concatenated 3 element node velocities in ground/inertial frame';
elems(1).Unit = 'm';

bs = Simulink.Bus;
bs.Elements = elems;
bs.Description = 'Node positions and velocities in ground/inertial frame.';

assignin('base','thrNodeBus',bs)

end