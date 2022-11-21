
VEHICLE               = "vhcl4turb";
PLANT                 = "plant2turb";
SIXDOFDYNAMICS        = "sixDoFDynamicsCoupledFossen";
LIBRARY               = "ultDoeKite";

%% Essential Values
vhcl = OCT.vehicleM;

vhcl.convEfficiency.setValue(.75,'');
vhcl.setFluidDensity(1000,'kg/m^3')
vhcl.setNumTethers(1,'');
vhcl.setBuoyFactor(1.0,''); %Should this be slightly positively buoyant?
vhcl.setFluidCoeffsFileName('fullScale1thrCoeffsQ42','');
vhcl.genKt.setValue(1,'');
vhcl.genR.setValue(0,'');
vhcl.gearBoxLoss.setValue(0,'');
vhcl.gearBoxRatio.setValue(1,'');   

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
vhcl.setWingAirfoil('NACA2412','');
vhcl.setWingClMin(-1.7,'');
vhcl.setWingClMax(1.7,'');

%% H-stab and V-stab
vhcl.hStab.setRSurfLE_WingLEBdy([5.5;0;0],'m');
vhcl.hStab.setNumTraps(2,'');
vhcl.hStab.setRootChord(.5,'m');
vhcl.hStab.setTR(.8,'');
vhcl.hStab.setHalfSpanGivenAR(4/.45,''); %Span 4, hspan 2
vhcl.hStab.setSweep(2.8624,'deg');
vhcl.hStab.setIncidence(-13.5,'deg');
vhcl.hStab.setAirfoil('NACA0015','');
vhcl.hStab.setClMin(-1.7,'');
vhcl.hStab.setClMax(1.7,'');

vhcl.vStab.setRSurfLE_WingLEBdy([5.35;0;0],'m');
vhcl.vStab.setRootChord(.65,'m');
vhcl.vStab.setHalfSpan(2.4375,'m');
vhcl.vStab.setTR(.8,'');
vhcl.vStab.setSweep(3.44,'deg');
vhcl.vStab.setAirfoil('NACA0015','');
vhcl.vStab.setClMin(-1.7,'');
vhcl.vStab.setClMax(1.7,'');

%% Fuselage (could use more realistic numbers)
vhcl.fuse.setDiameter(0.4445,'m');
vhcl.fuse.setEndDragCoeff(.1,'');
vhcl.fuse.setSideDragCoeff(1,'');
vhcl.fuse.setRNose_LE([-2;0;0],'m');
vhcl.fuse.setREnd_LE([max(vhcl.hStab.rSurfLE_WingLEBdy.Value(1),vhcl.vStab.rSurfLE_WingLEBdy.Value(1));0;0],'m');

%% Turbines
%% Turbines
vhcl.setNumTurbines(4,'');
vhcl.build('TurbClass','turb');

T1 = readtable('Andrew_04m_CT_05-13-2022.txt'); T1 = table2array(T1);
T2 = readtable('Andrew_04m_CP_05-13-2022.txt'); T2 = table2array(T2);
% port rotor
vhcl.turb1.turbMassStated.setValue(10,'kg')
vhcl.turb1.turbInertiaStated.setValue(.9,'kg*m^2')
vhcl.turb4.turbMassStated.setValue(10,'kg')
vhcl.turb4.turbInertiaStated.setValue(.9,'kg*m^2')
vhcl.turb3.turbMassStated.setValue(10,'kg')
vhcl.turb3.turbInertiaStated.setValue(.9,'kg*m^2')
vhcl.turb2.turbMassStated.setValue(10,'kg')
vhcl.turb2.turbInertiaStated.setValue(.9,'kg*m^2')
vhcl.turb1.numBlades.setValue(3,'')
vhcl.turb1.torqueLim.setValue(500,'(N*m)')
vhcl.turb1.setHubMass(1,'kg')
vhcl.turb1.setBladeMass(1,'kg')
vhcl.turb1.setDiameter(0.9,'m')
vhcl.turb1.hubDiameter.setValue(.075,'m')
vhcl.turb1.setAxisUnitVec([.9397;0;.3420],'')
vhcl.turb1.setAttachPtVec(vhcl.portWing.outlinePtsBdy.Value(:,2)*1/3+[0;0;0.8],'m')
vhcl.turb1.setPowerCoeff(.4,'')
vhcl.turb1.setDragCoef(.9,'')
vhcl.turb1.setAxalInductionFactor(1.5,'')
vhcl.turb1.setTipSpeedRatio(3,'')
vhcl.turb1.setStaticArea(0.08,'m^2')
vhcl.turb1.setStaticCD(1.5,'')
vhcl.turb1.CpLookup.setValue(T2(:,2),'')
vhcl.turb1.CtLookup.setValue(T1(:,2),'')
vhcl.turb1.RPMref.setValue(T1(:,1),'')

%portLower Rotor

vhcl.turb2.setAxisUnitVec([.9397;0;.3420],'')
vhcl.turb2.setAttachPtVec(vhcl.portWing.outlinePtsBdy.Value(:,2)*1/3-[0;0;0.8],'m')
vhcl.turb2.numBlades.setValue(3,'')
vhcl.turb2.torqueLim.setValue(500,'(N*m)')
vhcl.turb2.setHubMass(1,'kg')
vhcl.turb2.setBladeMass(1,'kg')
vhcl.turb2.setDiameter(0.9,'m')
vhcl.turb2.hubDiameter.setValue(.075,'m')
vhcl.turb2.setPowerCoeff(.4,'')
vhcl.turb2.setDragCoef(.9,'')
vhcl.turb2.setAxalInductionFactor(1.5,'')
vhcl.turb2.setTipSpeedRatio(3,'')
vhcl.turb2.setStaticArea(0.08,'m^2')
vhcl.turb2.setStaticCD(1.5,'')
vhcl.turb2.CpLookup.setValue(T2(:,2),'')
vhcl.turb2.CtLookup.setValue(T1(:,2),'')
vhcl.turb2.RPMref.setValue(T1(:,1),'')

vhcl.turb3.setAxisUnitVec([.9397;0;.3420],'')
vhcl.turb3.setAttachPtVec(vhcl.stbdWing.outlinePtsBdy.Value(:,2)*1/3+[0;0;0.8],'m')
vhcl.turb3.numBlades.setValue(3,'')
vhcl.turb3.torqueLim.setValue(500,'(N*m)')
vhcl.turb3.setHubMass(1,'kg')
vhcl.turb3.setBladeMass(1,'kg')
vhcl.turb3.setDiameter(0.9,'m')
vhcl.turb3.hubDiameter.setValue(.075,'m')
vhcl.turb3.setPowerCoeff(.4,'')
vhcl.turb3.setDragCoef(.9,'')
vhcl.turb3.setAxalInductionFactor(1.5,'')
vhcl.turb3.setTipSpeedRatio(3,'')
vhcl.turb3.setStaticArea(0.08,'m^2')
vhcl.turb3.setStaticCD(1.5,'')
vhcl.turb3.CpLookup.setValue(T2(:,2),'')
vhcl.turb3.CtLookup.setValue(T1(:,2),'')
vhcl.turb3.RPMref.setValue(T1(:,1),'')


vhcl.turb4.setAxisUnitVec([.9397;0;.3420],'')
vhcl.turb4.setAttachPtVec(vhcl.stbdWing.outlinePtsBdy.Value(:,2)*1/3-[0;0;0.8],'m')
vhcl.turb4.numBlades.setValue(3,'')
vhcl.turb4.torqueLim.setValue(500,'(N*m)')
vhcl.turb4.setHubMass(1,'kg')
vhcl.turb4.setBladeMass(1,'kg')
vhcl.turb4.setDiameter(0.9,'m')
vhcl.turb4.hubDiameter.setValue(.075,'m')
vhcl.turb4.setPowerCoeff(.4,'')
vhcl.turb4.setDragCoef(.9,'')
vhcl.turb4.setAxalInductionFactor(1.5,'')
vhcl.turb4.setTipSpeedRatio(3,'')
vhcl.turb4.setStaticArea(0.08,'m^2')
vhcl.turb4.setStaticCD(1.5,'')
vhcl.turb4.CpLookup.setValue(T2(:,2),'')
vhcl.turb4.CtLookup.setValue(T1(:,2),'')
vhcl.turb4.RPMref.setValue(T1(:,1),'')
    
%% load/generate fluid dynamic data
% vhcl.hydroCharacterization.setValue(0,'')
vhcl.calcFluidDynamicCoefffs

%% save file in its respective directory
saveBuildFile('vhcl',mfilename,'variant',["VEHICLE","PLANT","SIXDOFDYNAMICS","LIBRARY"]);



