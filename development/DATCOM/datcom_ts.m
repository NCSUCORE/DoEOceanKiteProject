fclose all
aero = datcomClass;
cd C:\Users\andre\Documents\MHK\development\DATCOM
% Set FLTCONS
aero.machNumbers.setValue(0.0018,'');
aero.Rnumbers.setValue('1.25E6','1/m');
aero.alphas.setValue([-4 -2 0 2 4 6 8],'deg');
% aero.loop.setValue(3,'');

% %Set OPTINS
% aero.refArea.setValue(225.8,'m^2');
% aero.longRefLength.setValue(5.75,'m');
% aero.latRefLength.setValue(41.15,'m');

% Set SYNTHS
aero.xCG.setValue(vhcl.rCM_LE.Value(1)-vhcl.fuse.rNose_LE.Value(1),'m');
aero.zCG.setValue(0,'m');
aero.xWing.setValue(-vhcl.fuse.rNose_LE.Value(1),'m');
aero.zWing.setValue(0,'m');
aero.incAngWing.setValue(0,'deg');
aero.xHTail.setValue(-vhcl.fuse.rNose_LE.Value(1)+vhcl.hStab.rSurfLE_WingLEBdy.Value(1),'m');
aero.zHTail.setValue(0,'m');
aero.incAngHTail.setValue(.25,'deg');
aero.xVTail.setValue(-vhcl.fuse.rNose_LE.Value(1)+vhcl.hStab.rSurfLE_WingLEBdy.Value(1),'m');
aero.zVTail.setValue(0,'m');

% Set BODY
aero.fuselageXPositions.setValue([0 1 6.6],'m');
aero.fuselageRadii.setValue([0.0,0.4,0.4],'m');

% Set WNGPLNF
aero.wngTpChrd.setValue(vhcl.wingTR.Value*vhcl.wingRootChord.Value,'m');
aero.wngRtChrd.setValue(vhcl.wingRootChord.Value,'m');
aero.wngSwpAng.setValue(vhcl.wingSweep.Value,'deg');
aero.wngTwst.setValue(0,'deg');
aero.wngDhdrl.setValue(vhcl.wingDihedral.Value,'deg');
aero.wngHlfSpn.setValue(vhcl.stbdWing.halfSpan.Value,'m');
aero.wngExpHlfSpn.setValue(vhcl.stbdWing.halfSpan.Value-vhcl.fuse.diameter.Value/2,'m');
aero.wngRefChrStn.setValue(0,'');
aero.wngNACA.setValue('2412','');

% Set HTPLNF
aero.hTlTpChrd.setValue(vhcl.hStab.rootChord.Value*vhcl.hStab.TR.Value,'m');
aero.hTlRtChrd.setValue(vhcl.hStab.rootChord.Value,'m');
aero.hTlSwpAng.setValue(vhcl.hStab.sweep.Value,'deg');
aero.hTlTwst.setValue(0,'deg');
aero.hTlDhdrl.setValue(vhcl.hStab.dihedral.Value,'deg');
aero.hTlHlfSpn.setValue(vhcl.hStab.halfSpan.Value,'m');
aero.hTlExpHlfSpn.setValue(vhcl.hStab.halfSpan.Value-vhcl.fuse.diameter.Value/2,'m');
aero.hTlNACA.setValue('0012','');

% Set VTPLNF
aero.vTlTpChrd.setValue(vhcl.vStab.rootChord.Value*vhcl.hStab.TR.Value,'m');
aero.vTlRtChrd.setValue(vhcl.vStab.rootChord.Value,'m');
aero.vTlSwpAng.setValue(vhcl.vStab.sweep.Value,'deg');
aero.vTlTwst.setValue(0,'deg');
aero.vTlDhdrl.setValue(vhcl.vStab.dihedral.Value,'deg');
aero.vTlHlfSpn.setValue(vhcl.vStab.halfSpan.Value,'m');
aero.vTlExpHlfSpn.setValue(vhcl.vStab.halfSpan.Value-vhcl.fuse.diameter.Value,'m');
aero.vTlNACA.setValue('0012','');

% Set ASYFLP
spanRatio = 0.85;
chordRatio = 0.2;
aero.alrnLeftDfln.setValue([-20:5:20],'deg');
aero.alrnRightDfln.setValue([20:-5:-20],'deg');
aero.alrnIbSpan.setValue(vhcl.stbdWing.halfSpan.Value*spanRatio,'m');
aero.alrnObSpan.setValue(vhcl.stbdWing.halfSpan.Value,'m');
aero.alrnIbChrd.setValue(vhcl.stbdWing.rootChord.Value*...
    vhcl.stbdWing.TR.Value/spanRatio*chordRatio,'m');
aero.alrnObChrd.setValue(vhcl.stbdWing.rootChord.Value*...
    vhcl.stbdWing.TR.Value*chordRatio,'m');
aero.alrnType.setValue(4,'');
y99 = 0.002+0.0007;
y90 = 0.0075+0.0197;
aero.alrnPhete.setValue(0.5*(y99+y90)/.09,'')

aero.run
