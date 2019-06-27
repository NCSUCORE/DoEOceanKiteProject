close all
a = OCT.aeroSurf;
a.setRootChord(2,'m')
a.setTipChord(1,'m')
a.setSpan(10,'m')
a.setLeadingEdgeX(1,'m')
a.setSpanUnitVec([0 1 0],'');
a.setChordUnitVec([1 0 0],'');
a.setDihedralAngle(10,'deg');
a.setSweepAngle(5,'deg');
a.setIncidenceAngle(10,'deg');

a.plot;
grid on
axis equal
% axis square
