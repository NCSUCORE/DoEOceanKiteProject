clear
clc
format compact

% this is the build script for creating a vechile using class definition
% 'vehicle' for a three tethered system that is being used by ayaz

% the script saves the variable 'vhcl' and 'vhcl_variant' to a mat file

%% lifiting body
%% variant
VEHICLE               = 'vehicle000';

%% build
vhcl = OCT.vehicle;

vhcl.setFluidDensity(1000,'kg/m^3')
vhcl.setNumTethers(3,'');
vhcl.setNumTurbines(2,'');
vhcl.setBuoyFactor(1.19,'');

% entering parameters for scaled model
Lscale = 0.015;
xCM_LE = 7.1721e-3;
xCB_LE = 7.194e-3;

% % % volume and inertias
% vhcl.setVolume(7457.953*1e-9*(1/Lscale^3),'m^3');
vhcl.setIxx(6.635*1e-6*(1/Lscale^5),'kg*m^2');
vhcl.setIyy(8.166*1e-6*(1/Lscale^5),'kg*m^2');
vhcl.setIzz(14.518*1e-6*(1/Lscale^5),'kg*m^2');
vhcl.setIxy(0,'kg*m^2');
vhcl.setIxz(0.414*1e-6*(1/Lscale^5),'kg*m^2');
vhcl.setIyz(0,'kg*m^2');
vhcl.setCentOfBuoy([(xCB_LE-xCM_LE);0;0]*(1/Lscale),'m');
vhcl.setRbridle_cm([0;0;0],'m');
vhcl.setAddedMISwitch(true,'');

% % % wing
Clmax = 2.5;

vhcl.setRwingLE_cm([-xCM_LE;0;0]*(1/Lscale),'m');
vhcl.setWingChord(15e-3*(1/Lscale),'m');
vhcl.setWingAR(10,'');
vhcl.setWingTR(0.8,'');
vhcl.setWingSweep(2.3,'deg');
vhcl.setWingDihedral(-4,'deg');
vhcl.setWingIncidence(0,'deg');
vhcl.setWingNACA('2412','');
vhcl.setWingClMax(Clmax,'');
vhcl.setWingClMin(-Clmax,'');

% % % H-stab
vhcl.setRhsLE_wingLE([67.5e-3;0;0]*(1/Lscale),'m');
vhcl.setHsChord(7.5e-3*(1/Lscale),'m');
vhcl.setHsAR(8,'');
vhcl.setHsTR(0.8,'');
vhcl.setHsSweep(2.8624,'deg');
vhcl.setHsDihedral(0,'deg');
vhcl.setHsIncidence(0,'deg');
vhcl.setHsNACA('0015','');
vhcl.setHsClMaxl(Clmax,'');
vhcl.setHsClMin(-Clmax,'');

% % % V-stab
vhcl.setRvs_wingLE([65.25e-3;0;0]*(1/Lscale),'m');
vhcl.setVsChord(9.75e-3*(1/Lscale),'m');
vhcl.setVsSpan(36.5625e-3*(1/Lscale),'m');
vhcl.setVsTR(0.8,'');
vhcl.setVsSweep(3.44,'deg');
vhcl.setVsNACA('0015','');
vhcl.setVsClMax(Clmax,'');
vhcl.setVsClMin(-Clmax,'');

% % % Fuselage (could use more realistic numbers)
vhcl.setFuseDiameter(2.5*4.9e-3*(1/Lscale),'m')
vhcl.setFuseEndDragCoeff(0.4,'')
vhcl.setFuseSideDragCoeff(0.8,'')
vhcl.setFuseRCmToNose([-58.55e-3;0;0]*(1/Lscale),'m')

% % % data file name
vhcl.setFluidCoeffsFileName('ScaledModelCoeffAtFS3','');

% % % load/generate fluid dynamic data
vhcl.calcFluidDynamicCoefffs

% % % artificially reduce lift
reductionFactor = 0.4;
incrementFactor = 1.6;

vhcl.portWing.CL.setValue(reductionFactor*vhcl.portWing.CL.Value,'')
vhcl.stbdWing.CL.setValue(reductionFactor*vhcl.stbdWing.CL.Value,'')
vhcl.hStab.CL.setValue(reductionFactor*vhcl.hStab.CL.Value,'')
vhcl.vStab.CL.setValue(reductionFactor*vhcl.vStab.CL.Value,'')

vhcl.portWing.CD.setValue(incrementFactor*vhcl.portWing.CD.Value,'')
vhcl.stbdWing.CD.setValue(incrementFactor*vhcl.stbdWing.CD.Value,'')
vhcl.hStab.CD.setValue(incrementFactor*vhcl.hStab.CD.Value,'')
vhcl.vStab.CD.setValue(incrementFactor*vhcl.vStab.CD.Value,'')

% % % scale it back down to lab scale before saving
vhcl.scale(Lscale,1);

%% save file in its respective directory
saveBuildFile('vhcl',mfilename,'variant','VEHICLE');


