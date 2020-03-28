% clear
% clc
% format compact

VEHICLE               = "vehicleLE";
SIXDOFDYNAMICS        = "sixDoFDynamicsCoupled";

%% Essential Values
vhcl = OCT.vehicle;

vhcl.setFluidDensity(1000,'kg/m^3')
vhcl.setNumTethers(3,'');
vhcl.setBuoyFactor(1.1,'');
vhcl.oldFluidMomentArms.setValue(1,'');
vhcl.setFluidCoeffsFileName('ScaledModelCoeffAtFS8','');

%% Turbines
vhcl.setNumTurbines(2,'');
vhcl.setTurbDiam(.45,'m');
%% Scaling Parameters
Lscale = 0.015;
xCM_LE = 12.032e-3;
rCM_LE = [12.032;0;1.439]*1e-3;
rCB_LE = [7.38;0;1.023]*1e-3;

%% Volumes and Inertia
vhcl.setVolume(10238.171*1e-9*(1/Lscale^3),'m^3');
MiCoeff = 1;
Ixx=MiCoeff*8.308*1e-6*(1/Lscale^5);
Iyy=MiCoeff*9.474*1e-6*(1/Lscale^5);
Izz=MiCoeff*18.738*1e-6*(1/Lscale^5);
Ixy=0;
Ixz=MiCoeff*0.402*1e-6*(1/Lscale^5);
Iyz=0;
vhcl.setInertia_CM([Ixx -Ixy -Ixz;...
                    -Ixy Iyy -Iyz;...
                    -Ixz -Iyz Izz],'kg*m^2')

%% Added Mass/Damping (defaults to zeros)
% vhcl.setMa6x6_B([],'');
% vhcl.setD6x6_B([],'');

%% Control Surfaces
vhcl.setAllMaxCtrlDef(30,'deg');
vhcl.setAllMinCtrlDef(-30,'deg');
vhcl.setAllMaxCtrlDefSpeed(60,'deg/s');

%% Important Points
vhcl.setRB_LE(rCM_LE*(1/Lscale),'m');
vhcl.setRCM_LE(rCM_LE*(1/Lscale),'m');
vhcl.setRBridle_LE(rCM_LE*(1/Lscale),'m');
vhcl.setRCentOfBuoy_LE(rCB_LE*(1/Lscale),'m');

%% Wing
Clmax = 2;
% vhcl.setRwingLE_cm([-.47064 0 0],'m');
vhcl.setWingRootChord(15e-3*(1/Lscale),'m');
vhcl.setWingAR(10,'');
vhcl.setWingTR(0.8,'');
vhcl.setWingSweep(2.3,'deg');
vhcl.setWingDihedral(-4,'deg');
vhcl.setWingIncidence(0,'deg');
vhcl.setWingNACA('2412','');
vhcl.setWingClMin(-Clmax,'');
vhcl.setWingClMax(Clmax,'');

%% H-stab and V-stab
vhcl.hStab.setRSurfLE_WingLEBdy([67.5e-3;0;0]*(1/Lscale),'m');
vhcl.hStab.setNumTraps(2,'');
vhcl.hStab.setRootChord(7.5e-3*(1/Lscale),'m');
vhcl.hStab.setSpanOrAR('AR',8,'');
vhcl.hStab.setTR(.8,'');
vhcl.hStab.setSweep(2.8624,'deg');
vhcl.hStab.setIncidence(0,'deg');
vhcl.hStab.setNACA('0015','');
vhcl.hStab.setClMin(-Clmax,'');
vhcl.hStab.setClMax(Clmax,'');

vhcl.vStab.setRSurfLE_WingLEBdy([65.25e-3;0;0]*(1/Lscale),'m');
vhcl.vStab.setRootChord(9.75e-3*(1/Lscale),'m');
vhcl.vStab.setSpanOrAR('Span',36.5625e-3*(1/Lscale),'m');
vhcl.vStab.setTR(.8,'');
vhcl.vStab.setSweep(3.44,'deg');
vhcl.vStab.setNACA('0015','');
vhcl.vStab.setClMin(-Clmax,'');
vhcl.vStab.setClMax(Clmax,'');

%% Fuselage (could use more realistic numbers)
fuseChord = 11*Lscale;
fuseAirfoil = 0.06;
thFunc = @(x,t) 5*t*(0.2969*x.^0.5 - 0.126*x - 0.3516*x.^2 + 0.2843*x.^3 ...
    - 0.1036*x.^4);

vhcl.fuse.setDiameter(2*mean(thFunc(0:0.01:1,fuseAirfoil)*fuseChord)*(1/Lscale),'m');
vhcl.fuse.setEndDragCoeff(.6,'');
vhcl.fuse.setSideDragCoeff(1,'');
vhcl.fuse.setRNose_LE(-([45;0;0]*1e-3)*(1/Lscale),'m');
vhcl.fuse.setREnd_LE([max(vhcl.hStab.rSurfLE_WingLEBdy.Value(1),vhcl.vStab.rSurfLE_WingLEBdy.Value(1));0;0],'m');
    
%% load/generate fluid dynamic datan
vhcl.calcFluidDynamicCoefffs

%% Use Xfoil
load('xfoilData.mat')
spanEffFactor = 0.7;    % its 0.73 for a cessna 310. refer secondaryRef folder
CLWing = spanEffFactor*CL2412.*(0.5*vhcl.wingAR.Value*(vhcl.wingRootChord.Value^2)...
    /vhcl.fluidRefArea.Value);
CDWing = (CD2412 + (CLWing.^2)./(pi*vhcl.wingAR.Value*spanEffFactor))*...
    (0.5*vhcl.wingAR.Value*(vhcl.wingRootChord.Value^2)...
    /vhcl.fluidRefArea.Value);

CLhStab = spanEffFactor*CL0015.*(vhcl.hStab.AR.Value*(vhcl.hStab.rootChord.Value^2)...
    /vhcl.fluidRefArea.Value);
CDhStab = (CD0015 + (CLhStab.^2)./(pi*vhcl.hStab.AR.Value*spanEffFactor))*...
    (vhcl.hStab.AR.Value*(vhcl.hStab.rootChord.Value^2)...
    /vhcl.fluidRefArea.Value);

CLvStab = spanEffFactor*CL0015.*(vhcl.vStab.rootChord.Value*vhcl.vStab.span.Value...
    /vhcl.fluidRefArea.Value);
CDvStab = (CD0015 + ...
    (CLvStab.^2)./(pi*(vhcl.vStab.span.Value/vhcl.vStab.rootChord.Value)*spanEffFactor))*...
    (vhcl.vStab.rootChord.Value*vhcl.vStab.span.Value...
    /vhcl.fluidRefArea.Value);

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



