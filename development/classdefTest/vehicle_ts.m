close all
clear
clc
vhcl = OCT.vehicle;
vhcl.setNumSurfaces(5,'')
vhcl.setNumTethers(1,'')

vhcl.build('SurfaceNames',{'prtWing','stbWing','prtHStab','stbHStab','vertStab'});


vhcl.prtWing.setRootChord(1.5,'m');
vhcl.prtWing.setTipChord(1,'m');
vhcl.prtWing.setSpan(5,'m');
vhcl.prtWing.setCornerPoint([0 0 0],'m');
vhcl.prtWing.setSpanUnitVec([0 -1 0],'');
vhcl.prtWing.setChordUnitVec([1 0 0],'');
vhcl.prtWing.setDihedralAngle(10,'deg');
vhcl.prtWing.setSweepAngle(5,'deg');
vhcl.prtWing.setIncidenceAngle(10,'deg');

vhcl.stbWing.setRootChord(1.5,'m');
vhcl.stbWing.setTipChord(1,'m');
vhcl.stbWing.setSpan(5,'m');
vhcl.stbWing.setCornerPoint([0 0 0],'m');
vhcl.stbWing.setSpanUnitVec([0 1 0],'');
vhcl.stbWing.setChordUnitVec([1 0 0],'');
vhcl.stbWing.setDihedralAngle(10,'deg');
vhcl.stbWing.setSweepAngle(5,'deg');
vhcl.stbWing.setIncidenceAngle(10,'deg');

vhcl.prtHStab.setRootChord(1,'m');
vhcl.prtHStab.setTipChord(0.75,'m');
vhcl.prtHStab.setSpan(2,'m');
vhcl.prtHStab.setCornerPoint([6 0 0],'m');
vhcl.prtHStab.setSpanUnitVec([0 1 0],'');
vhcl.prtHStab.setChordUnitVec([1 0 0],'');
vhcl.prtHStab.setDihedralAngle(0,'deg');
vhcl.prtHStab.setSweepAngle(5,'deg');
vhcl.prtHStab.setIncidenceAngle(0,'deg');

vhcl.stbHStab.setRootChord(1,'m');
vhcl.stbHStab.setTipChord(0.75,'m');
vhcl.stbHStab.setSpan(2,'m');
vhcl.stbHStab.setCornerPoint([6 0 0],'m');
vhcl.stbHStab.setSpanUnitVec([0 -1 0],'');
vhcl.stbHStab.setChordUnitVec([1 0 0],'');
vhcl.stbHStab.setDihedralAngle(0,'deg');
vhcl.stbHStab.setSweepAngle(5,'deg');
vhcl.stbHStab.setIncidenceAngle(0,'deg');

vhcl.vertStab.setRootChord(1,'m');
vhcl.vertStab.setTipChord(0.75,'m');
vhcl.vertStab.setSpan(2.5,'m');
vhcl.vertStab.setCornerPoint([6 0 0],'m');
vhcl.vertStab.setSpanUnitVec([0 0 1],'');
vhcl.vertStab.setChordUnitVec([1 0 0],'');
vhcl.vertStab.setDihedralAngle(0,'deg');
vhcl.vertStab.setSweepAngle(10,'deg');
vhcl.vertStab.setIncidenceAngle(0,'deg');

vhcl.plot('Position',[0 0 200],'EulerAngles',[0 15 0]*pi/180);
