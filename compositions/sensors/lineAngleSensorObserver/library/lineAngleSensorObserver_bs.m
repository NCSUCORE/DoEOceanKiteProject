%% Line Angle Sensor Build Script

las = SNS.lineAngleSensorObserver;

las.setMass(0.661,'kg');
las.setCD(1.3,'');
las.setDiameter(0.012,'m');
las.setLength(0.51724,'m');
las.setVolume(95755e-9,'m^3');
las.setL_CB(norm([0.000115 0.002479 -0.117688]),'m');
las.setL_CM(norm([0.00013 0.00294 -0.09241]),'m');
las.setIxx(3.317e-04,'kg*m^2');
las.setIyy(0.026855,'kg*m^2');
las.setIzz(0.026855,'kg*m^2');
las.setR_RP(-[0.0717 0 0.06785]','m');
las.setR_PT([las.length.Value 0 0.030]','m');
saveBuildFile('las',mfilename);
