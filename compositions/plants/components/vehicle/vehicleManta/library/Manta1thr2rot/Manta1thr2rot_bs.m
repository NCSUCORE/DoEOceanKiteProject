% clear
clc
% format compact

VEHICLE               = "vehicleManta";
SIXDOFDYNAMICS        = "sixDoFDynamicsCoupled";

%% Essential Values
vhcl = OCT.vehicle;

vhcl.setFluidDensity(1000,'kg/m^3')
vhcl.setNumTethers(1,'');
vhcl.setBuoyFactor(1.0,''); %Should this be slightly positively buoyant?
vhcl.setFluidCoeffsFileName('fullScale1thrCoeffsQ4','');

%% Volumes and Inertia
vhcl.setVolume(2.85698,'m^3') %From CAD
Ixx=1.094057613168724e+04;
Iyy=1.247604938271605e+04;
Izz=2.467555555555556e+04;
Ixy=0;
Ixz=5.293827160493829e+02;
Iyz=0;

vhcl.setInertia_CM([Ixx -Ixy -Ixz;...
                    -Ixy Iyy -Iyz;...
                    -Ixz -Iyz Izz],'kg*m^2')
                
%% Important Points
vhcl.setRCM_LE([0 0 0],'m')
% vhcl.setRCM_LE([.47064 0 0],'m');
vhcl.setRB_LE(vhcl.rCM_LE.Value,'m');
vhcl.setRBridle_LE(vhcl.rCM_LE.Value + [0;0;0],'m');
vhcl.setRCentOfBuoy_LE(vhcl.rCM_LE.Value + [0.02136;0;0.0682],'m');% [.492,0,.0682] from CAD

%% Added Mass/Damping (defaults to zeros)
vhcl.setMa6x6_LE([134         0           0           0          14           0;...
                   0      1591           0        -986           0        5166;...
                   0         0        9265           0       -8202           0;...
                   0      -986           0       67412           0       -4608;...
                  14         0       -8202           0       20209           0;...
                   0      5166           0       -4608           0       23320;],'');
% vhcl.setD6x6_B([],'');

%% Control Surfaces
vhcl.setAllMaxCtrlDef(30,'deg');
vhcl.setAllMinCtrlDef(-30,'deg');
vhcl.setAllMaxCtrlDefSpeed(60,'deg/s');



%% Wing
vhcl.setWingRootChord(1,'m');
vhcl.setWingAR(100/9,''); %Span 10, hspan 5
vhcl.setWingTR(0.8,'');
vhcl.setWingSweep(2.3,'deg');
vhcl.setWingDihedral(2,'deg');
vhcl.setWingIncidence(0,'deg');
vhcl.setWingNACA('2412','');
vhcl.setWingClMin(-1.7,'');
vhcl.setWingClMax(1.7,'');

%% H-stab and V-stab
vhcl.hStab.setRSurfLE_WingLEBdy([5.5;0;0],'m');
vhcl.hStab.setNumTraps(2,'');
vhcl.hStab.setRootChord(.5,'m');
vhcl.hStab.setTR(.8,'');
vhcl.hStab.setHalfSpanGivenAR(4/.45,''); %Span 4, hspan 2
vhcl.hStab.setSweep(2.8624,'deg');
vhcl.hStab.setIncidence(-1.5,'deg');
vhcl.hStab.setNACA('0015','');
vhcl.hStab.setClMin(-1.7,'');
vhcl.hStab.setClMax(1.7,'');

vhcl.vStab.setRSurfLE_WingLEBdy([5.35;0;0],'m');
vhcl.vStab.setRootChord(.65,'m');
vhcl.vStab.setHalfSpan(2.4375,'m');
vhcl.vStab.setTR(.8,'');
vhcl.vStab.setSweep(3.44,'deg');
vhcl.vStab.setNACA('0015','');
vhcl.vStab.setClMin(-1.7,'');
vhcl.vStab.setClMax(1.7,'');

%% Fuselage (could use more realistic numbers)
vhcl.fuse.setDiameter(0.4445,'m');
vhcl.fuse.setEndDragCoeff(.1,'');
vhcl.fuse.setSideDragCoeff(1,'');
vhcl.fuse.setRNose_LE([-2;0;0],'m');
vhcl.fuse.setREnd_LE([max(vhcl.hStab.rSurfLE_WingLEBdy.Value(1),vhcl.vStab.rSurfLE_WingLEBdy.Value(1));0;0],'m');
    
%% Turbines
vhcl.setNumTurbines(2,'');
vhcl.build('TurbClass','turb');
% port rotor
vhcl.turb1.setMass(6,'kg')
vhcl.turb1.setDiameter(.56,'m')
vhcl.turb1.setAxisUnitVec([1;0;0],'')
vhcl.turb1.setAttachPtVec(vhcl.portWing.outlinePtsBdy.Value(:,2),'m')
vhcl.turb1.setPowerCoeff(.5,'')
vhcl.turb1.setAxalInductionFactor(1.5,'')
vhcl.turb1.setTipSpeedRatio(6,'')
% starboard rotor
vhcl.turb2.setMass(6,'kg')
vhcl.turb2.setDiameter(.56,'m')
vhcl.turb2.setAxisUnitVec([1;0;0],'')
vhcl.turb2.setAttachPtVec(vhcl.portWing.outlinePtsBdy.Value(:,2),'m')
vhcl.turb2.setPowerCoeff(.5,'')
vhcl.turb2.setAxalInductionFactor(1.5,'')
vhcl.turb2.setTipSpeedRatio(6,'')

%% load/generate fluid dynamic datan
vhcl.calcFluidDynamicCoefffs

%% save file in its respective directory
saveBuildFile('vhcl',mfilename,'variant',["VEHICLE","SIXDOFDYNAMICS"]);



