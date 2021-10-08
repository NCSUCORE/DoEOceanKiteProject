%% Line Angle Sensor Build Script

las = SNS.lineAngleSensor;

las.setMass(0.5724,'kg');
las.setCD(1.02,'');
las.setDiameter(0.012,'m');
las.setLength(0.51724,'m');
las.setVolume(.00013159,'m^3');
las.setL_CB(norm([.0001991 .1064984 .0008733]),'m');
las.setL_CM(norm([0.000165 0.07561 0.004157]),'m');
las.setIxx(.000277,'kg*m^2');
las.setIyy(0.01389,'kg*m^2');
las.setIzz(0.01389,'kg*m^2');
las.setR_RP(-[0.0717 0 0.06785]','m');
las.setR_PT([las.length.Value 0 0.030]','m');
las.lasOrient.setValue(rotz(pi),'')

load('thrAngLAS.mat');
las.thrAngLookup.setValue(thrAng,'rad');

saveBuildFile('las',mfilename);

function x = rotz(t)
    x = [cos(t) -sin(t) 0 ; sin(t) cos(t) 0 ; 0 0 1];
end