ctrl.fcn = @mySin;
sim('fncHandles_th.slx')
simout.plot
ctrl.fcn = @myCos;
sim('fncHandles_th.slx')
grid on
hold on
simout.plot