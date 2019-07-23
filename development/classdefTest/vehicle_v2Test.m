% clear it all
clear all
clear mex;
fclose all;
clear

clc
format compact
% close alls

%% common parameters
lengthScale = 1/1;
densityScale = 1/1;
numTethers = 1;
thrNumNodes = 2;
numTurbines = 2;

%% lifiting body
vhcl = OCT.vehicle_v2;

vhcl.setLengthScale(lengthScale,'');
vhcl.setDensityScale(densityScale,'');
vhcl.setNumTethers(numTethers,'');
vhcl.setNumTurbines(numTurbines,'');
vhcl.setBuoyFactor(1.00,'');

% % % volume and inertias
vhcl.setVolume(945352023.474*1e-9,'m^3');
vhcl.setIxx(6.303080401918E+09*1e-6,'kg*m^2');
vhcl.setIyy(2080666338.077*1e-6,'kg*m^2');
vhcl.setIzz(8.320369733598E+09*1e-6,'kg*m^2');
vhcl.setIxy(0,'kg*m^2');
vhcl.setIxz(81875397.942*1e-6,'kg*m^2');
vhcl.setIyz(0,'kg*m^2');
vhcl.setRcb_cm([0;0;0],'m');
vhcl.setRbridle_cm([0;0;0],'m');

% % % wing
vhcl.setRwingLE_cm([-1;0;0],'m');
vhcl.setWingChord(1,'m');
vhcl.setWingAR(10,'');
vhcl.setWingTR(0.8,'');
vhcl.setWingSweep(2,'deg');
vhcl.setWingDihedral(0,'deg');
vhcl.setWingIncidence(0,'deg');
vhcl.setWingNACA('4412','');
vhcl.setWingClMax(1.75,'');
vhcl.setWingClMin(-1.75,'');

% % % H-stab
vhcl.setRhsLE_wingLE([6;0;0],'m');
vhcl.setHsChord(0.6,'m');
vhcl.setHsAR(8,'');
vhcl.setHsTR(0.8,'');
vhcl.setHsSweep(5,'deg');
vhcl.setHsDihedral(0,'deg');
vhcl.setHsIncidence(0,'deg');
vhcl.setHsNACA('0012','');
vhcl.setHsClMaxl(1.75,'');
vhcl.setHsClMin(-1.75,'');

% % % V-stab
vhcl.setRvs_wingLE([6;0;0],'m');
vhcl.setVsChord(0.75,'m');
vhcl.setVsSpan(2.5,'m');
vhcl.setVsTR(0.8,'');
vhcl.setVsSweep(10,'deg');
vhcl.setVsNACA('0012','');
vhcl.setVsClMax(1.75,'');
vhcl.setVsClMin(-1.75,'');

% % % initial conditions
vhcl.setInitialCmPos([0;0;50],'m');
vhcl.setInitialCmVel([0;0;0],'m/s');
vhcl.setInitialEuler([0;1;0]*pi/180,'rad');
vhcl.setInitialAngVel([0;0;0],'rad/s');

% % % scale the vehicle
vhcl.scaleVehicle

% % % data file name
vhcl.setFluidCoeffsFileName('someFile4','');

% % % load/generate fluid dynamic data
vhcl.calcFluidDynamicCoefffs

% % % plot
vhcl.plot
vhcl.plotCoeffPolars