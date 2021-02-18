function [veh] = initParam(vhcl,SFOT)

condition = exist('SFOT','var');
if condition == 1
    veh = SFOT;
end

veh.W.aero          = [vhcl.portWing.rAeroCent_SurfLE.Value(1) 0 0]';
veh.W.x             = -vhcl.fuse.rNose_LE.Value+veh.W.aero;
veh.W.b             = vhcl.portWing.halfSpan.Value*2;
veh.W.c             = vhcl.portWing.rootChord.Value;
veh.W.tr            = vhcl.portWing.TR.Value;
veh.W.A             = veh.W.b*.5*(veh.W.c+veh.W.tr*veh.W.c);
veh.W.AR            = veh.W.b^2/veh.W.A;
veh.W.airfoil_geom  = 'NACA2412_geom.dat';
veh.W.flap_loc      = 0.75;
veh.W.cd0           = 0.0093;
veh.W.oswald        = 0.87;
veh.W.Re            = 1.0e6;

veh.H.aero          = vhcl.hStab.rAeroCent_SurfLE.Value;
veh.H.x             = veh.W.x+vhcl.hStab.rSurfLE_WingLEBdy.Value+veh.H.aero;
veh.H.b             = vhcl.hStab.halfSpan.Value*2;
veh.H.c             = vhcl.hStab.rootChord.Value;
veh.H.tr            = vhcl.portWing.TR.Value;
veh.H.A             = veh.H.b*.5*(veh.H.c+veh.H.tr*veh.H.c);
veh.H.AR            = veh.H.b^2/veh.H.A;
veh.H.airfoil_geom  = 'NACA0015_geom.dat';
veh.H.flap_loc      = 0.75;
veh.H.cd0           = 0.0093;
veh.H.oswald        = 0.9;
veh.H.Re            = 0.7e6;

veh.V.aero          = vhcl.vStab.RSurf2Bdy.Value*vhcl.vStab.rAeroCent_SurfLE.Value;
veh.V.x             = veh.W.x+vhcl.hStab.rSurfLE_WingLEBdy.Value+veh.V.aero;
veh.V.b             = vhcl.vStab.halfSpan.Value;
veh.V.c             = vhcl.vStab.rootChord.Value;
veh.V.tr            = vhcl.portWing.TR.Value;
veh.V.A             = veh.V.b*.5*(veh.V.c+veh.V.tr*veh.V.c);
veh.V.AR            = veh.V.b^2/veh.V.A;
veh.V.airfoil_geom  = 'NACA0015_geom.dat';
veh.V.flap_loc      = 0.75;
veh.V.cd0           = 0.0093;
veh.V.oswald        = 0.93;
veh.V.Re            = 0.7e6;

if condition == 0
    veh.H.hStab     = xfoil_AR_func_noflap(veh.H);
    veh.V.vStab     = xfoil_AR_func_noflap(veh.V);
end


veh.F.aero          = vhcl.fuse.rAeroCent_LE.Value;
veh.F.x             = veh.W.x+veh.F.aero;
veh.F.CD            = vhcl.fuse.endDragCoeff.Value;
veh.F.CS            = vhcl.fuse.sideDragCoeff.Value;
if condition 
    veh.F.D         = SFOT.F.D;
    veh.F.L         = SFOT.F.L;
else
    veh.F.D         = vhcl.fuse.diameter.Value;
    veh.F.L         = vhcl.fuse.length.Value;
end

veh.T.x             = veh.W.x;
veh.T.d             = vhcl.turb1.diameter.Value;
veh.T.CD            = vhcl.turb1.dragCoef.Value;
veh.T.A             = pi/4*veh.T.d^2;

veh.CM          = veh.W.x+vhcl.rCM_LE.Value;
veh.CB          = veh.W.x+vhcl.rCentOfBuoy_LE.Value;
veh.BR          = veh.W.x+[vhcl.thrAttchPts_B.posVec.Value(1);0;-veh.F.D/2];

end

