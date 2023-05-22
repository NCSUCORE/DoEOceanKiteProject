function externalInputSensorProcessing_bc()
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
elems(5).Name = 'gndStnPositionVec';
elems(5).Dimensions = [3 1];
elems(5).DimensionsMode = 'Fixed';
elems(5).DataType = 'double';
elems(5).SampleTime = -1;
elems(5).Complexity = 'real';
elems(5).Unit = 'm';

elems(6) = Simulink.BusElement;
elems(6).Name = 'gndStnVelocityVec';
elems(6).Dimensions = [3 1];
elems(6).DimensionsMode = 'Fixed';
elems(6).DataType = 'double';
elems(6).SampleTime = -1;
elems(6).Complexity = 'real';
elems(6).Unit = 'm/s';

elems(7) = Simulink.BusElement;
elems(7).Name = 'gndStnEulerAngles';
elems(7).Dimensions = [3 1];
elems(7).DimensionsMode = 'Fixed';
elems(7).DataType = 'double';
elems(7).SampleTime = -1;
elems(7).Complexity = 'real';
elems(7).Unit = 'rad';

elems(8) = Simulink.BusElement;
elems(8).Name = 'gndStnAngularVel';
elems(8).Dimensions = [3 1];
elems(8).DimensionsMode = 'Fixed';
elems(8).DataType = 'double';
elems(8).SampleTime = -1;
elems(8).Complexity = 'real';
elems(8).Unit = 'rad/s';

elems(9) = Simulink.BusElement;
elems(9).Name = 'avgTetherLength';
elems(9).Dimensions = [1 1]; 
elems(9).DimensionsMode = 'Fixed';
elems(9).DataType = 'double';
elems(9).SampleTime = -1;
elems(9).Complexity = 'real';
elems(9).Unit = 'm';

elems(10) = Simulink.BusElement;
elems(10).Name = 'tetherReleaseSpeeds';
elems(10).DimensionsMode = 'Fixed';
elems(10).Dimensions = [sz.numTethers 1];
elems(10).DataType = 'double';
elems(10).SampleTime = -1;
elems(10).Complexity = 'real';
elems(10).Unit = 'm/s';

elems(11) = Simulink.BusElement;
elems(11).Name = 'airTenVecs';
elems(11).Dimensions = 1;
elems(11).DimensionsMode = 'Fixed';
elems(11).DataType = 'double';
elems(11).SampleTime = -1;
elems(11).Complexity = 'real';
elems(11).Unit = 'N';

elems(12) = Simulink.BusElement;
elems(12).Name = 'rotorSpeed';
elems(12).Dimensions = [2 1];
elems(12).DimensionsMode = 'Fixed';
elems(12).DataType = 'double';
elems(12).SampleTime = -1;
elems(12).Complexity = 'real';
elems(12).Unit = 'rad/s';

elems(13) = Simulink.BusElement;
elems(13).Name = 'vAppBdy';
elems(13).Dimensions = [3 1];
elems(13).DimensionsMode = 'Fixed';
elems(13).DataType = 'double';
elems(13).SampleTime = -1;
elems(13).Complexity = 'real';
elems(13).Unit = 'm/s';

elems(14) = Simulink.BusElement;
elems(14).Name = 'state';
elems(14).Dimensions = [1 1];
elems(14).DimensionsMode = 'Fixed';
elems(14).DataType = 'double';
elems(14).SampleTime = -1;
elems(14).Complexity = 'real';
elems(14).Unit = '';

elems(15) = Simulink.BusElement;
elems(15).Name = 'desAlt';
elems(15).Dimensions = [1 1];
elems(15).DimensionsMode = 'Fixed';
elems(15).DataType = 'double';
elems(15).SampleTime = -1;
elems(15).Complexity = 'real';
elems(15).Unit = 'm';

elems(16) = Simulink.BusElement;
elems(16).Name = 'masterLinKin';
elems(16).Dimensions = [3 1];
elems(16).DimensionsMode = 'Fixed';
elems(16).DataType = 'double';
elems(16).SampleTime = -1;
elems(16).Complexity = 'real';
elems(16).Unit = 'm/s';

elems(17) = Simulink.BusElement;
elems(17).Name = 'masterAngKin';
elems(17).Dimensions = [3 1];
elems(17).DimensionsMode = 'Fixed';
elems(17).DataType = 'double';
elems(17).SampleTime = -1;
elems(17).Complexity = 'real';
elems(17).Unit = 'rad/s';

elems(18) = Simulink.BusElement;
elems(18).Name = 'flowResource';
elems(18).Dimensions = [2 1];
elems(18).DimensionsMode = 'Fixed';
elems(18).DataType = 'double';
elems(18).SampleTime = -1;
elems(18).Complexity = 'real';
elems(18).Unit = 'rad/s';

BUS = Simulink.Bus;
BUS.Elements = elems;
BUS.Description = 'Bus containing signals from the sensor processing';

assignin('base','sensorsProcessingBus',BUS)

end 