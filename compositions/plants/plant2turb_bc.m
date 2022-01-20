function plant2turb_bc
sz = getBusDims;

elems(1) = Simulink.BusElement;
elems(1).Name = 'positionVec';
elems(1).Dimensions = [3 1];
elems(1).DimensionsMode = 'Fixed';
elems(1).DataType = 'double';
elems(1).SampleTime = -1;
elems(1).Complexity = 'real';
elems(1).Unit = 'm';

elems(2) = Simulink.BusElement;
elems(2).Name = 'velocityVec';
elems(2).Dimensions = [3 1];
elems(2).DimensionsMode = 'Fixed';
elems(2).DataType = 'double';
elems(2).SampleTime = -1;
elems(2).Complexity = 'real';
elems(2).Unit = 'm/s';

elems(3) = Simulink.BusElement;
elems(3).Name = 'eulerAngles';
elems(3).Dimensions = [3 1];
elems(3).DimensionsMode = 'Fixed';
elems(3).DataType = 'double';
elems(3).SampleTime = -1;
elems(3).Complexity = 'real';
elems(3).Unit = 'rad';

elems(4) = Simulink.BusElement;
elems(4).Name = 'angularVel';
elems(4).Dimensions = [3 1];
elems(4).DimensionsMode = 'Fixed';
elems(4).DataType = 'double';
elems(4).SampleTime = -1;
elems(4).Complexity = 'real';
elems(4).Unit = 'rad/s';

elems(5) = Simulink.BusElement;
elems(5).Name = 'winchPower';
elems(5).Dimensions = 1;
elems(5).DimensionsMode = 'Fixed';
elems(5).DataType = 'double';
elems(5).SampleTime = -1;
elems(5).Complexity = 'real';
elems(5).Unit = 'W';

elems(6) = Simulink.BusElement;
elems(6).Name = 'gndStnPositionVec';
elems(6).Dimensions = [3 1];
elems(6).DimensionsMode = 'Fixed';
elems(6).DataType = 'double';
elems(6).SampleTime = -1;
elems(6).Complexity = 'real';
elems(6).Unit = 'm';

elems(7) = Simulink.BusElement;
elems(7).Name = 'gndStnVelocityVec';
elems(7).Dimensions = [3 1];
elems(7).DimensionsMode = 'Fixed';
elems(7).DataType = 'double';
elems(7).SampleTime = -1;
elems(7).Complexity = 'real';
elems(7).Unit = 'm/s';

elems(8) = Simulink.BusElement;
elems(8).Name = 'gndStnEulerAngles';
elems(8).Dimensions = [3 1];
elems(8).DimensionsMode = 'Fixed';
elems(8).DataType = 'double';
elems(8).SampleTime = -1;
elems(8).Complexity = 'real';
elems(8).Unit = 'rad';

elems(9) = Simulink.BusElement;
elems(9).Name = 'gndStnAngularVel';
elems(9).Dimensions = [3 1];
elems(9).DimensionsMode = 'Fixed';
elems(9).DataType = 'double';
elems(9).SampleTime = -1;
elems(9).Complexity = 'real';
elems(9).Unit = 'rad/s';

elems(10) = Simulink.BusElement;
elems(10).Name = 'thrFlowPollPos';
elems(10).Dimensions = sz.thrLinkFlowVecsSize;
elems(10).DimensionsMode = 'Fixed';
elems(10).DataType = 'double';
elems(10).SampleTime = -1;
elems(10).Complexity = 'real';

elems(11) = Simulink.BusElement;
elems(11).Name = 'vhclFlowPollPos';
elems(11).Dimensions = sz.fluidPollPos; %Note this assumes 5 fluid dynamic surfaces + fuselage + 2 turbines + 6 gradient points
elems(11).DimensionsMode = 'Fixed';
elems(11).DataType = 'double';
elems(11).SampleTime = -1;
elems(11).Complexity = 'real';
elems(11).Unit = 'm';

elems(12) = Simulink.BusElement;
elems(12).Name = 'avgTetherLength';
elems(12).Dimensions = [1 1]; 
elems(12).DimensionsMode = 'Fixed';
elems(12).DataType = 'double';
elems(12).SampleTime = -1;
elems(12).Complexity = 'real';
elems(12).Unit = 'm';

elems(13) = Simulink.BusElement;
elems(13).Name = 'anchThrPollPos';
elems(13).Dimensions = sz.anchThrLinkFlowVecsSize;
elems(13).DimensionsMode = 'Fixed';
elems(13).DataType = 'double';
elems(13).SampleTime = -1;
elems(13).Complexity = 'real';

elems(14) = Simulink.BusElement;
elems(14).Name = 'tetherReleaseSpeeds';
elems(14).DimensionsMode = 'Fixed';
elems(14).Dimensions = [sz.numTethers 1];
elems(14).DataType = 'double';
elems(14).SampleTime = -1;
elems(14).Complexity = 'real';
elems(14).Unit = 'm/s';

elems(15) = Simulink.BusElement;
elems(15).Name = 'gndTenVecs';
elems(15).Dimensions = sz.nodeTenVecSize;
elems(15).DimensionsMode = 'Fixed';
elems(15).DataType = 'double';
elems(15).SampleTime = -1;
elems(15).Complexity = 'real';
elems(15).Unit = 'N';


elems(16) = Simulink.BusElement;
elems(16).Name = 'gndStnFlowPollPos';
elems(16).Dimensions = sz.gndStnLmpMasPosSize;
elems(16).DimensionsMode = 'Fixed';
elems(16).DataType = 'double';
elems(16).SampleTime = -1;
elems(16).Complexity = 'real';
elems(16).Unit = 'm';

elems(17) = Simulink.BusElement;
elems(17).Name = 'accelerometer';
elems(17).Dimensions = [3 1];
elems(17).DimensionsMode = 'Fixed';
elems(17).DataType = 'double';
elems(17).SampleTime = -1;
elems(17).Complexity = 'real';
elems(17).Unit = 'm/s^2';

elems(18) = Simulink.BusElement;
elems(18).Name = 'thrAttchPtGndPos';
elems(18).Dimensions = [3 1];
elems(18).DimensionsMode = 'Fixed';
elems(18).DataType = 'double';
elems(18).SampleTime = -1;
elems(18).Complexity = 'real';
elems(18).Unit = 'm';

elems(19) = Simulink.BusElement;
elems(19).Name = 'thrAttchPtGndVel';
elems(19).Dimensions = [3 1];
elems(19).DimensionsMode = 'Fixed';
elems(19).DataType = 'double';
elems(19).SampleTime = -1;
elems(19).Complexity = 'real';
elems(19).Unit = 'm/s';

elems(20) = Simulink.BusElement;
elems(20).Name = 'thrAttchPtAirPos';
elems(20).Dimensions = [3 1];
elems(20).DimensionsMode = 'Fixed';
elems(20).DataType = 'double';
elems(20).SampleTime = -1;
elems(20).Complexity = 'real';
elems(20).Unit = 'm';

elems(21) = Simulink.BusElement;
elems(21).Name = 'thrAttchPtAirVel';
elems(21).Dimensions = [3 1];
elems(21).DimensionsMode = 'Fixed';
elems(21).DataType = 'double';
elems(21).SampleTime = -1;
elems(21).Complexity = 'real';
elems(21).Unit = 'm/s';

elems(22) = Simulink.BusElement;
elems(22).Name = 'airTenVecs';
elems(22).Dimensions = sz.nodeTenVecSize;
elems(22).DimensionsMode = 'Fixed';
elems(22).DataType = 'double';
elems(22).SampleTime = -1;
elems(22).Complexity = 'real';
elems(22).Unit = 'N';

elems(23) = Simulink.BusElement;
elems(23).Name = 'rotorRPM';
elems(23).Dimensions = [2 1];
elems(23).DimensionsMode = 'Fixed';
elems(23).DataType = 'double';
elems(23).SampleTime = -1;
elems(23).Complexity = 'real';
elems(23).Unit = 'RPM';

CONTROL = Simulink.Bus;
CONTROL.Elements = elems;
CONTROL.Description = 'Bus containing signals produced by the plant model';

assignin('base','plantBus',CONTROL)

end