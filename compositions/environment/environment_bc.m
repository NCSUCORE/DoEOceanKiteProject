function  environment_bc

sz = getBusDims;


%% First, create sub-busses
% Create sub-bus for vehicle flow vecs
% 1) no sub-bus defined

% 2) Create sub-bus for tether flow vecs
% elems(1) = Simulink.BusElement;
% elems(1).Name = 'linkFlowVecs';
% elems(1).DimensionsMode = 'Fixed';
% elems(1).Dimensions = [3 numNodes-1];
% elems(1).DataType = 'double';
% elems(1).SampleTime = -1;
% elems(1).Complexity = 'real';
% elems(1).Unit = 'm/s';
% elems(1).Description = 'Flow velocity vector in the ground coordinate system at each of the tether link centers.';
% 
% linkFlowVecsBus = Simulink.Bus;
% linkFlowVecsBus.Elements = elems;
% linkFlowVecsBus.Description = 'Bus containing flow vector at all links of a single tether.';
% 
% assignin('base','linkFlowVecsBus',linkFlowVecsBus)
% clearvars elems

% 3) Create sub-bus for anchor tether flow vecs
% elems(1) = Simulink.BusElement;
% elems(1).Name = 'linkFlowVecs';
% elems(1).DimensionsMode = 'Fixed';
% elems(1).Dimensions = [3 numNodesAnchor-1];
% elems(1).DataType = 'double';
% elems(1).SampleTime = -1;
% elems(1).Complexity = 'real';
% elems(1).Unit = 'm/s';
% elems(1).Description = 'Flow velocity vector in the ground coordinate system at each of the tether link centers for the anchor tether.';
% 
% linkFlowVecsAnchorBus = Simulink.Bus;
% linkFlowVecsAnchorBus.Elements = elems;
% linkFlowVecsAnchorBus.Description = 'Bus containing flow vector at all links of a single tether.';
% 
% assignin('base','linkFlowVecsAnchorBus',linkFlowVecsAnchorBus)
% clearvars elems

% Create bus for the entire environment
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
elems(2).Name = 'thrLinkFlowVecs';
elems(2).Dimensions = sz.thrLinkFlowVecsSize;
elems(2).DimensionsMode = 'Fixed';
elems(2).DataType = 'double';
elems(2).SampleTime = -1;
elems(2).Complexity = 'real';
elems(2).Description = 'Flow velocity vector in the ground coordinate system at the center of each link on the platform to kite tether.';

%%
elems(3) = Simulink.BusElement;
elems(3).Name = 'anchThrLinkFlowVecs';
elems(3).Dimensions = sz.anchThrLinkFlowVecsSize;
elems(3).DimensionsMode = 'Fixed';
elems(3).DataType = 'double';
elems(3).SampleTime = -1;
elems(3).Complexity = 'real';
elems(3).Description = 'Flow velocity vector in the ground coordinate system at the center of each link on the platform to inertial frame (anchor) tether.';


% Create environment bus
elems(4) = Simulink.BusElement;
elems(4).Name = 'gndStnFlowVecs';
elems(4).Dimensions = sz.gndStnLmpMasPosSize; 
elems(4).DimensionsMode = 'Fixed';
elems(4).DataType = 'double';
elems(4).SampleTime = -1;
elems(4).Complexity = 'real';
elems(4).Unit = 'm/s';
elems(4).Description = 'Flow velocity vector in the ground coordinate system at each of the aerodynamic centers of the fluid dynamic surfaces on the ground station.';

envBus = Simulink.Bus;
envBus.Elements = elems;
envBus.Description = 'Bus containing signals produced by the environment';

assignin('base','envBus',envBus)

end