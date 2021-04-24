%% Line Angle Sensor Build Script

las = SNS.lineAngleSensor;

las.setMass(0.55,'kg');
las.setCD(1.3,'');
las.setDiameter(0.012,'m');
las.setLength(0.47,'m');
las.setVolume(95755e-9,'m^3');
las.setL_CB(norm([0.000115 0.002479 -0.117688]),'m');
las.setL_CM(norm([0.000157 0.006502 -0.071464]),'m');
las.setIxx(2.72154e-04,'kg*m^2');
las.setIyy(0.01587,'kg*m^2');
las.setIzz(0.01587,'kg*m^2');
las.setR_RP(-[0.0717 0 0.06785],'m');
saveBuildFile('las',mfilename);
