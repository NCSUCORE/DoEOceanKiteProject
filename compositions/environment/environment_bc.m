function  environment_bc

% Create linkFlowVecsBus
numNodes    = evalin('base','thr.numNodes.Value');   % Get the number of nodes
numTethers  = evalin('base','thr.numTethers.Value'); % Get the number of tethers

numNodesAnchor    = evalin('base','gndStn.anchThrs.numNodes.Value');   % Get the number of nodes
numTethersAnchor  = evalin('base','gndStn.anchThrs.numTethers.Value'); % Get the number of tethers

elems(1) = Simulink.BusElement;
elems(1).Name = 'linkFlowVecs';
elems(1).DimensionsMode = 'Fixed';
elems(1).Dimensions = [3 numNodes-1];
elems(1).DataType = 'double';
elems(1).SampleTime = -1;
elems(1).Complexity = 'real';
elems(1).Unit = 'm/s';
elems(1).Description = 'Flow velocity vector in the ground coordinate system at each of the tether link centers.';

linkFlowVecsBus = Simulink.Bus;
linkFlowVecsBus.Elements = elems;
linkFlowVecsBus.Description = 'Bus containing flow vector at all links of a single tether.';

assignin('base','linkFlowVecsBus',linkFlowVecsBus)
%%
elems(1) = Simulink.BusElement;
elems(1).Name = 'linkFlowVecsAnchor';
elems(1).DimensionsMode = 'Fixed';
elems(1).Dimensions = [3 numNodesAnchor-1];
elems(1).DataType = 'double';
elems(1).SampleTime = -1;
elems(1).Complexity = 'real';
elems(1).Unit = 'm/s';
elems(1).Description = 'Flow velocity vector in the ground coordinate system at each of the tether link centers for the anchor tether.';

linkFlowVecsAnchorBus = Simulink.Bus;
linkFlowVecsAnchorBus.Elements = elems;
linkFlowVecsAnchorBus.Description = 'Bus containing flow vector at all links of a single tether.';

assignin('base','linkFlowVecsAnchorBus',linkFlowVecsAnchorBus)

% Create environment bus
elems(1) = Simulink.BusElement;
elems(1).Name = 'vhclFlowVecs';
elems(1).Dimensions = [3 5]; % Assumes 5 fluid dynamic surfaces (4 + fuselage)
elems(1).DimensionsMode = 'Fixed';
elems(1).DataType = 'double';
elems(1).SampleTime = -1;
elems(1).Complexity = 'real';
elems(1).Unit = 'm/s';
elems(1).Description = 'Flow velocity vector in the ground coordinate system at each of the aerodynamic centers of the fluid dynamic surfaces.';

elems(2) = Simulink.BusElement;
elems(2).Name = 'linkFlowVecsBusArry';
elems(2).Dimensions = numTethers;
elems(2).DimensionsMode = 'Fixed';
elems(2).DataType = 'Bus: linkFlowVecsBus';
elems(2).SampleTime = -1;
elems(2).Complexity = 'real';
elems(2).Description = 'Flow velocity vector in the ground coordinate system at each of the aerodynamic centers of the fluid dynamic surfaces.';

%%
elems(3) = Simulink.BusElement;
elems(3).Name = 'linkFlowVecsBusArryAnchor';
elems(3).Dimensions = numTethersAnchor;
elems(3).DimensionsMode = 'Fixed';
elems(3).DataType = 'Bus: linkFlowVecsAnchorBus';
elems(3).SampleTime = -1;
elems(3).Complexity = 'real';
elems(3).Description = 'Flow velocity vector in the ground coordinate system at each of the aerodynamic centers of the fluid dynamic surfaces.';


envBus = Simulink.Bus;
envBus.Elements = elems;
envBus.Description = 'Bus containing signals produced by the environment';

assignin('base','envBus',envBus)

end