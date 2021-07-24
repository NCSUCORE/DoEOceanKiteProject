function  env2turbLinearize_bc

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
elems(1).Dimensions = [3 13]; % Assumes 5 fluid dynamic surfaces (4 + fuselage) + 6 gradient poll positions
elems(1).DimensionsMode = 'Fixed';
elems(1).DataType = 'double';
elems(1).SampleTime = -1;
elems(1).Complexity = 'real';
elems(1).Unit = 'm/s';
elems(1).Description = 'Flow velocity vector in the ground coordinate system at each of the aerodynamic centers of the fluid dynamic surfaces.';


elems(2) = Simulink.BusElement;
elems(2).Name = 'oceanHeightAtVhcl';
elems(2).Dimensions = [13,1]; % Assumes 5 fluid dynamic surfaces (4 + fuselage) + 6 gradient poll positions
elems(2).DimensionsMode = 'Fixed';
elems(2).DataType = 'double';
elems(2).SampleTime = -1;
elems(2).Complexity = 'real';
elems(2).Unit = 'm/s';
elems(2).Description = 'Ocean surface height at the x location of the oceans aero centers';

elems(3) = Simulink.BusElement;
elems(3).Name = 'thrLinkFlowVecs';
elems(3).Dimensions = sz.thrLinkFlowVecsSize;
elems(3).DimensionsMode = 'Fixed';
elems(3).DataType = 'double';
elems(3).SampleTime = -1;
elems(3).Complexity = 'real';
elems(3).Description = 'Flow velocity vector in the ground coordinate system at the center of each link on the platform to kite tether.';



elems(4) = Simulink.BusElement;
elems(4).Name = 'oceanHeightAtThr';
if length(size(sz.thrLinkFlowVecsSize))==2
    elems(4).Dimensions = [1,sz.thrLinkFlowVecsSize(2)];
else
    elems(4).Dimensions = [1,max(sz.thrLinkFlowVecsSize(2),sz.thrLinkFlowVecsSize(3))];
end
elems(4).DimensionsMode = 'Fixed';
elems(4).DataType = 'double';
elems(4).SampleTime = -1;
elems(4).Complexity = 'real';
elems(4).Description = 'Ocean surface height at the x location of the tether nodes';

%%
elems(5) = Simulink.BusElement;
elems(5).Name = 'anchThrLinkFlowVecs';
elems(5).Dimensions = sz.anchThrLinkFlowVecsSize;
elems(5).DimensionsMode = 'Fixed';
elems(5).DataType = 'double';
elems(5).SampleTime = -1;
elems(5).Complexity = 'real';
elems(5).Description = 'Flow velocity vector in the ground coordinate system at the center of each link on the platform to inertial frame (anchor) tether.';

elems(6) = Simulink.BusElement;
elems(6).Name = 'oceanHeightAtAnchThr';
elems(6).Dimensions = sz.anchThrLinkFlowVecsSize(2:end);
elems(6).DimensionsMode = 'Fixed';
elems(6).DataType = 'double';
elems(6).SampleTime = -1;
elems(6).Complexity = 'real';
elems(6).Description = 'Ocean surface height at the x location of the anch tether nodes';


% Create environment bus
elems(7) = Simulink.BusElement;
elems(7).Name = 'gndStnFlowVecs';
elems(7).Dimensions = sz.gndStnLmpMasPosSize; 
elems(7).DimensionsMode = 'Fixed';
elems(7).DataType = 'double';
elems(7).SampleTime = -1;
elems(7).Complexity = 'real';
elems(7).Unit = 'm/s';
elems(7).Description = 'Flow velocity vector in the ground coordinate system at each of the aerodynamic centers of the fluid dynamic surfaces on the ground station.';


% Create environment bus
elems(8) = Simulink.BusElement;
elems(8).Name = 'oceanHeightAtGndStnLM';
elems(8).Dimensions = [sz.gndStnLmpMasPosSize(2),1]; 
elems(8).DimensionsMode = 'Fixed';
elems(8).DataType = 'double';
elems(8).SampleTime = -1;
elems(8).Complexity = 'real';
elems(8).Unit = 'm/s';
elems(8).Description = 'Ocean surface height at the x location of the gnd stn lumped masses';

elems(9) = Simulink.BusElement;
elems(9).Name = 'portPrim';
elems(9).Dimensions = [3 1]; 
elems(9).DimensionsMode = 'Fixed';
elems(9).DataType = 'double';
elems(9).SampleTime = -1;
elems(9).Complexity = 'real';
elems(9).Unit = 'm/s';
elems(9).Description = 'Velocity Primitives at each aerosurface';

elems(10) = Simulink.BusElement;
elems(10).Name = 'stbdPrim';
elems(10).Dimensions = [3 1]; 
elems(10).DimensionsMode = 'Fixed';
elems(10).DataType = 'double';
elems(10).SampleTime = -1;
elems(10).Complexity = 'real';
elems(10).Unit = 'm/s';
elems(10).Description = 'Velocity Primitives at each aerosurface';

elems(11) = Simulink.BusElement;
elems(11).Name = 'hStabPrim';
elems(11).Dimensions = [3 1]; 
elems(11).DimensionsMode = 'Fixed';
elems(11).DataType = 'double';
elems(11).SampleTime = -1;
elems(11).Complexity = 'real';
elems(11).Unit = 'm/s';
elems(11).Description = 'Velocity Primitives at each aerosurface';

elems(12) = Simulink.BusElement;
elems(12).Name = 'vStabPrim';
elems(12).Dimensions = [3 1]; 
elems(12).DimensionsMode = 'Fixed';
elems(12).DataType = 'double';
elems(12).SampleTime = -1;
elems(12).Complexity = 'real';
elems(12).Unit = 'm/s';
elems(12).Description = 'Velocity Primitives at each aerosurface';

elems(13) = Simulink.BusElement;
elems(13).Name = 'velPrim';
elems(13).Dimensions = [3 1]; 
elems(13).DimensionsMode = 'Fixed';
elems(13).DataType = 'double';
elems(13).SampleTime = -1;
elems(13).Complexity = 'real';
elems(13).Unit = 'm/s';
elems(13).Description = 'Velocity Primitives';

envBus = Simulink.Bus;
envBus.Elements = elems;
envBus.Description = 'Bus containing signals produced by the environment';

assignin('base','envBus',envBus)

end