function thrAttachPtKinematics_bc
% Create output bus for thrAttachPtKinematics_ul block.  This function is
% automatically called by the mask initialization,
% thrAttachPtKinematics_init whenever the thrAttachPtKinematics_ul block is
% used in a model

elems(1) = Simulink.BusElement;
elems(1).Name = 'posVec';
elems(1).Dimensions = [3 1];
elems(1).DimensionsMode = 'Fixed';
elems(1).DataType = 'double';
elems(1).SampleTime = -1;
elems(1).Complexity = 'real';
elems(1).Description = '3 element vector of position, x, y and z in the intertial/ground frame';
elems(1).Unit = 'm';

elems(2) = Simulink.BusElement;
elems(2).Name = 'velVec';
elems(2).Dimensions = [3 1];
elems(2).DimensionsMode = 'Fixed';
elems(2).DataType = 'double';
elems(2).SampleTime = -1;
elems(2).Complexity = 'real';
elems(2).Description = '3 element vector of velocity, x, y and z in the intertial/ground frame';
elems(2).Unit = 'm/s';

bs = Simulink.Bus;
bs.Elements = elems;
bs.Description = 'Bus containing signals produced by thrAttachPtKinematics_ul.';

assignin('base','thrAttachPtKinematicsBus',bs)

end