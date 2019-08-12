geomParams = [30 10 0*pi/180 30*pi/180 100];

ctrl.fcnName.Value = 'lemOfGerono';
sim('fncHandles_th.slx')
simout.plot
hold on

ctrl.fcnName.Value = 'lemOfBooth';
sim('fncHandles_th.slx')
simout.plot

