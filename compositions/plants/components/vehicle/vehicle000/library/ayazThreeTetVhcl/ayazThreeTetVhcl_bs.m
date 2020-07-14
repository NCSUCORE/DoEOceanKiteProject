clear
clc
format compact

% this is the build script for creating a vechile using class definition
% 'vehicle' for a three tethered system that is being used by ayaz

% the script saves the variable 'vhcl' and 'vhcl_variant' to a mat file

%% lifiting body
%% variant
VEHICLE               = "vehicle000";
SIXDOFDYNAMICS        = "sixDoFDynamicsEuler";

%% build
vhcl = OCT.vehicle;

vhcl.setFluidDensity(1000,'kg/m^3')
vhcl.setNumTethers(3,'');
vhcl.setNumTurbines(2,'');
vhcl.setBuoyFactor(1.1,'');

vhcl.setTurbDiam(0.45,'m')

% entering parameters for scaled model
Lscale = 0.015;
xCM_LE = 12.032e-3;
rCM_LE = [12.032;0;1.439]*1e-3;
rCB_LE = [7.38;0;1.023]*1e-3;

% % % volume and inertias
vhcl.setVolume(10238.171*1e-9*(1/Lscale^3),'m^3');
MiCoeff = 1;
vhcl.setIxx(MiCoeff*8.308*1e-6*(1/Lscale^5),'kg*m^2');
vhcl.setIyy(MiCoeff*9.474*1e-6*(1/Lscale^5),'kg*m^2');
vhcl.setIzz(MiCoeff*18.738*1e-6*(1/Lscale^5),'kg*m^2');
vhcl.setIxy(0,'kg*m^2');
vhcl.setIxz(MiCoeff*0.402*1e-6*(1/Lscale^5),'kg*m^2');
vhcl.setIyz(0,'kg*m^2');
vhcl.setCentOfBuoy((rCB_LE-rCM_LE)*(1/Lscale),'m');
vhcl.setRbridle_cm([0;0;0],'m');
vhcl.setAddedMISwitch(true,'');

% % % wing
Clmax = 2;

% vhcl.

vhcl.setRwingLE_cm(-rCM_LE*(1/Lscale),'m');
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
fuseChord = 11*Lscale;
fuseAirfoil = 0.06;
thFunc = @(x,t) 5*t*(0.2969*x.^0.5 - 0.126*x - 0.3516*x.^2 + 0.2843*x.^3 ...
    - 0.1036*x.^4);

vhcl.setFuseDiameter(2*mean(thFunc(0:0.01:1,fuseAirfoil)*fuseChord)*(1/Lscale),'m')
vhcl.setFuseEndDragCoeff(0.6,'')
vhcl.setFuseSideDragCoeff(1,'')
vhcl.setFuseRNose_LE(-([45;0;0]*1e-3)*(1/Lscale),'m')

% % % data file name
vhcl.setFluidCoeffsFileName('ScaledModelCoeffAtFS8','');

% % % load/generate fluid dynamic data
vhcl.calcFluidDynamicCoefffs
vhcl.calcAddedMass
vhcl.addedInertia.setValue(0*[0.2;0.2;0.2].*vhcl.addedInertia.Value,'kg*m^2');

% calc added mass
addedMassCoeff = 1;
ratioYbyX = vhcl.addedMass.Value(2,2)/vhcl.addedMass.Value(1,1);
ratioZbyX = vhcl.addedMass.Value(3,3)/vhcl.addedMass.Value(1,1);

vhcl.addedMass.setValue(addedMassCoeff.*vhcl.addedMass.Value,'kg')

% % % artificially reduce lift
% reductionFactor = 1.0;
% incrementFactor = 1.0;
%
% vhcl.portWing.CL.setValue(reductionFactor*vhcl.portWing.CL.Value,'')
% vhcl.stbdWing.CL.setValue(reductionFactor*vhcl.stbdWing.CL.Value,'')
% vhcl.hStab.CL.setValue(reductionFactor*vhcl.hStab.CL.Value,'')
% vhcl.vStab.CL.setValue(reductionFactor*vhcl.vStab.CL.Value,'')
%
% vhcl.portWing.CD.setValue(incrementFactor*vhcl.portWing.CD.Value,'')
% vhcl.stbdWing.CD.setValue(incrementFactor*vhcl.stbdWing.CD.Value,'')
% vhcl.hStab.CD.setValue(incrementFactor*vhcl.hStab.CD.Value,'')
% vhcl.vStab.CD.setValue(incrementFactor*vhcl.vStab.CD.Value,'')

%% use xfoil data
load('xfoilData.mat')
spanEffFactor = 0.7;    % its 0.73 for a cessna 310. refer secondaryRef folder
CLWing = spanEffFactor*CL2412.*(0.5*vhcl.wingAR.Value*(vhcl.wingChord.Value^2)...
    /vhcl.portWing.refArea.Value);
CDWing = (CD2412 + (CLWing.^2)./(pi*vhcl.wingAR.Value*spanEffFactor))*...
    (0.5*vhcl.wingAR.Value*(vhcl.wingChord.Value^2)...
    /vhcl.portWing.refArea.Value);

CLhStab = spanEffFactor*CL0015.*(vhcl.hsAR.Value*(vhcl.hsChord.Value^2)...
    /vhcl.portWing.refArea.Value);
CDhStab = (CD0015 + (CLhStab.^2)./(pi*vhcl.hsAR.Value*spanEffFactor))*...
    (vhcl.hsAR.Value*(vhcl.hsChord.Value^2)/vhcl.portWing.refArea.Value);

CLvStab = spanEffFactor*CL0015.*(vhcl.vsChord.Value*vhcl.vsSpan.Value...
    /vhcl.portWing.refArea.Value);
CDvStab = (CD0015 + ...
    (CLvStab.^2)./(pi*(vhcl.vsSpan.Value/vhcl.vsChord.Value)*spanEffFactor))*...
    (vhcl.vsChord.Value*vhcl.vsSpan.Value...
    /vhcl.portWing.refArea.Value);

vhcl.portWing.CL.setValue(CLWing,'')
vhcl.stbdWing.CL.setValue(CLWing,'')
vhcl.hStab.CL.setValue(CLhStab,'')
vhcl.vStab.CL.setValue(CLvStab,'')

vhcl.portWing.CD.setValue(CDWing,'')
vhcl.stbdWing.CD.setValue(CDWing,'')
vhcl.hStab.CD.setValue(CDhStab,'')
vhcl.vStab.CD.setValue(CDvStab,'')

vhcl.portWing.alpha.setValue(AoA2412,'deg')
vhcl.stbdWing.alpha.setValue(AoA2412,'deg')
vhcl.hStab.alpha.setValue(AoA0015,'deg')
vhcl.vStab.alpha.setValue(AoA0015,'deg')

% % % scale it back down to lab scale before saving
vhcl.scale(Lscale,1);

%% save file in its respective directory
saveBuildFile('vhcl',mfilename,'variant',["VEHICLE","SIXDOFDYNAMICS"]);



