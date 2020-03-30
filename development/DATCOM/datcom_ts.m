fclose all
aero = datcomClass;

% Set FLTCONS
aero.machNumbers.setValue([0.1 0.2],'');
aero.altitudes.setValue([5000.0,8000.0],'m');
aero.alphas.setValue([-2 0 2 4 8],'deg');
aero.loop.setValue(2,'');

% Set OPTINS
aero.refArea.setValue(225.8,'m^2');
aero.longRefLength.setValue(5.75,'m');
aero.latRefLength.setValue(41.15,'m');

% Set SYNTHS
aero.xCG.setValue(7.08,'m');
aero.zCG.setValue(0,'m');
aero.xWing.setValue(6.1,'m');
aero.zWing.setValue(-1.4,'m');
aero.incAngWing.setValue(1.1,'deg');
aero.xHTail.setValue(20.2,'m');
aero.zHTail.setValue(0.4,'m');
aero.incAngHTail.setValue(0,'deg');
aero.xVTail.setValue(21.3,'m');
aero.zVTail.setValue(0,'m');

% Set BODY
aero.fuselageXPositions.setValue([-4.9,0.0,3.0,6.1,9.1,13.3,20.2,23.5,25.9],'m');
aero.fuselageRadii.setValue([0.0,1.0,1.75,2.6,2.6,2.6,2.0,1.0,0.0],'m');

% Set WNGPLNF
aero.wngTpChrd.setValue(4,'m');
aero.wngRtChrd.setValue(7.2,'m');
aero.wngSwpAng.setValue(0,'deg');
aero.wngTwst.setValue(-1.1,'deg');
aero.wngDhdrl.setValue(3,'deg');
aero.wngHlfSpn.setValue(20.6,'m');
aero.wngExpHlfSpn.setValue(18.7,'m');
aero.wngRefChrStn.setValue(0.25,'');
aero.wngNACA.setValue('64a412','');

% Set HTPLNF
aero.hTlTpChrd.setValue(2.3,'m');
aero.hTlRtChrd.setValue(0.25,'m');
aero.hTlSwpAng.setValue(11,'deg');
aero.hTlTwst.setValue(0,'deg');
aero.hTlDhdrl.setValue(0,'deg');
aero.hTlHlfSpn.setValue(6.625,'m');
aero.hTlExpHlfSpn.setValue(5.7,'m');
aero.hTlNACA.setValue('0012','');

% Set VTPLNF
aero.vTlTpChrd.setValue(4,'m');
aero.vTlRtChrd.setValue(7.2,'m');
aero.vTlSwpAng.setValue(0,'deg');
aero.vTlTwst.setValue(-1.1,'deg');
aero.vTlDhdrl.setValue(3,'deg');
aero.vTlHlfSpn.setValue(20.6,'m');
aero.vTlExpHlfSpn.setValue(18.7,'m');
aero.vTlNACA.setValue('0012','');

aero.run
