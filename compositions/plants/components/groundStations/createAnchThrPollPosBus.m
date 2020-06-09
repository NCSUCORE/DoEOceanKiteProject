function createAnchThrPollPosBus(numNodes)

elems(1) = Simulink.BusElement;
elems(1).Name = 'linkCentPositions';
elems(1).Dimensions = [3 numNodes-1];
elems(1).DimensionsMode = 'Fixed';
elems(1).DataType = 'double';
elems(1).SampleTime = -1;
elems(1).Complexity = 'real';
elems(1).Description = 'Link positions used to poll the flow speed calculation in the environment';
elems(1).Unit = 'm';

bs = Simulink.Bus;
bs.Elements = elems;
bs.Description = 'Link positions used to poll the flow speed calculation in the environment.';

assignin('base','anchThrPollPosBus',bs)

end