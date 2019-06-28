close all;clear;clc

vhcl = OCT.vehicle;
vhcl.setNumSurfaces(5,'')
vhcl.setNumTethers(1,'')
vhcl.numTethers.setValue(1,'');
vhcl.numTurbines.setValue(1,'');

vhcl.build('SurfaceNames',{'prtWing','stbWing','prtHStab','stbHStab','vertStab'});

vhcl.prtWing.setMeanChord(0.8,'m');
vhcl.prtWing.setIncidenceAngle(0,'deg');
vhcl.prtWing.setSweepAngle(15,'deg');
vhcl.prtWing.setDihedralAngle(2,'deg');
vhcl.prtWing.setSpanUnitVec([0 1 0],'');
vhcl.prtWing.setSpan(5,'m');
vhcl.prtWing.setChordUnitVec([1 0 0],'');
vhcl.prtWing.setCornerPoint([0 0 0],'m');
vhcl.prtWing.setAeroRefPoint([0 0 0],'m');
vhcl.prtWing.setMaxCtrlDeflDn(30,'deg');
vhcl.prtWing.setMaxCtrlDeflUp(30,'deg');
vhcl.prtWing.setClMin(-1,'');
vhcl.prtWing.setClMax(1.25,'');
vhcl.prtWing.setAirfoil('2412');
vhcl.prtWing.setAlpha(linspace(-20,20,31),'deg')

vhcl.stbWing.setMeanChord(0.8,'m');
vhcl.stbWing.setIncidenceAngle(0,'deg');
vhcl.stbWing.setSweepAngle(15,'deg');
vhcl.stbWing.setDihedralAngle(2,'deg');
vhcl.stbWing.setSpanUnitVec([0 1 0],'');
vhcl.stbWing.setSpan(5,'m');
vhcl.stbWing.setChordUnitVec([1 0 0],'');
vhcl.stbWing.setCornerPoint([0 0 0],'m');
vhcl.stbWing.setAeroRefPoint([0 0 0],'m');
vhcl.stbWing.setMaxCtrlDeflDn(30,'deg');
vhcl.stbWing.setMaxCtrlDeflUp(30,'deg');
vhcl.stbWing.setClMin(-1,'');
vhcl.stbWing.setClMax(1.25,'');
vhcl.stbWing.setAirfoil('2412');
vhcl.stbWing.setAlpha(linspace(-20,20,31),'deg')

vhcl.prtHStab.setMeanChord(0.375,'m');
vhcl.prtHStab.setIncidenceAngle(0,'deg');
vhcl.prtHStab.setSweepAngle(10,'deg');
vhcl.prtHStab.setDihedralAngle(0,'deg');
vhcl.prtHStab.setSpanUnitVec([0 1 0],'');
vhcl.prtHStab.setSpan(2,'m');
vhcl.prtHStab.setChordUnitVec([1 0 0],'');
vhcl.prtHStab.setCornerPoint([6 0 0],'m');
vhcl.prtHStab.setAeroRefPoint([0 0 0],'m');
vhcl.prtHStab.setMaxCtrlDeflDn(30,'deg');
vhcl.prtHStab.setMaxCtrlDeflUp(30,'deg');
vhcl.prtHStab.setClMin(-1.25,'');
vhcl.prtHStab.setClMax(1.25,'');
vhcl.prtHStab.setAirfoil('0015');
vhcl.prtHStab.setAlpha(linspace(-20,20,31),'deg')

vhcl.stbHStab.setMeanChord(0.375,'m');
vhcl.stbHStab.setIncidenceAngle(0,'deg');
vhcl.stbHStab.setSweepAngle(10,'deg');
vhcl.stbHStab.setDihedralAngle(0,'deg');
vhcl.stbHStab.setSpanUnitVec([0 1 0],'');
vhcl.stbHStab.setSpan(2,'m');
vhcl.stbHStab.setChordUnitVec([1 0 0],'');
vhcl.stbHStab.setCornerPoint([6 0 0],'m');
vhcl.stbHStab.setAeroRefPoint([0 0 0],'m');
vhcl.stbHStab.setMaxCtrlDeflDn(30,'deg');
vhcl.stbHStab.setMaxCtrlDeflUp(30,'deg');
vhcl.stbHStab.setClMin(-1.25,'');
vhcl.stbHStab.setClMax(1.25,'');
vhcl.stbHStab.setAirfoil('0015');
vhcl.stbHStab.setAlpha(linspace(-20,20,31),'deg')

vhcl.vertStab.setMeanChord(0.375,'m');
vhcl.vertStab.setIncidenceAngle(0,'deg');
vhcl.vertStab.setSweepAngle(15,'deg');
vhcl.vertStab.setDihedralAngle(0,'deg');
vhcl.vertStab.setSpanUnitVec([0 0 1],'');
vhcl.vertStab.setSpan(2,'m');
vhcl.vertStab.setChordUnitVec([1 0 0],'');
vhcl.vertStab.setCornerPoint([6 0 0],'m');
vhcl.vertStab.setAeroRefPoint([0 0 0],'m');
vhcl.vertStab.setMaxCtrlDeflDn(30,'deg');
vhcl.vertStab.setMaxCtrlDeflUp(30,'deg');
vhcl.vertStab.setClMin(-1.25,'');
vhcl.vertStab.setClMax(1.25,'');
vhcl.vertStab.setAirfoil('0015');
vhcl.vertStab.setAlpha(linspace(-20,20,31),'deg')

vhcl.turbine1.diameter.setValue(0,'m');
vhcl.turbine1.axisUnitVec.setValue([1 0 0]','');
vhcl.turbine1.attachPtVec.setValue([-1.25 -5 0]','m');
vhcl.turbine1.powerCoeff.setValue(0.5,'');
vhcl.turbine1.dragCoeff.setValue(0.8,'');

vhcl.Ixx.setValue(34924.16,'kg*m^2');
vhcl.Iyy.setValue(30487.96,'kg*m^2');
vhcl.Izz.setValue(64378.94,'kg*m^2');
vhcl.Ixy.setValue(0,'kg*m^2');
vhcl.Ixz.setValue(731.66,'kg*m^2');
vhcl.Iyz.setValue(0,'kg*m^2');
vhcl.volume.setValue(7.40,'m^3');
vhcl.mass.setValue(0.95*7404.24,'kg');

vhcl.centOfBuoy.setValue([0 0 0]','m');

vhcl.thrAttch1.posVec.setValue([0 0 0]','m');

vhcl.setICs('InitPos',[0 0 200],'InitEulAng',[0 7 0]*pi/180);

vhcl.plotGeometry
vhcl.AVL('SaveFileName','TestVehicle1')
vhcl.plotPolars
vhcl.struct('OCT.aeroSurf')


