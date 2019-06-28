close all
a = OCT.aeroSurf;
a.setMeanChord(0.375,'m');
a.setIncidenceAngle(0,'deg');
a.setSweepAngle(15,'deg');
a.setDihedralAngle(0,'deg');
a.setSpanUnitVec([0 0 1],'');
a.setSpan(2,'m');
a.setChordUnitVec([1 0 0],'');
a.setCornerPoint([6 0 0],'m');
a.setAeroRefPoint([0 0 0],'m');
a.setMaxCtrlDeflDn(30,'deg');
a.setMaxCtrlDeflUp(30,'deg');
a.setNumChordwise(5,'');
a.setNumSpanwise(20,'');
a.setClMin(-0.65,'');
a.setClMax(0.65,'');
a.setAirfoil('0015');
a.setAlpha(linspace(-20,20,31),'deg')

a.plotGeometry
a.AVL
a.plotPolars

