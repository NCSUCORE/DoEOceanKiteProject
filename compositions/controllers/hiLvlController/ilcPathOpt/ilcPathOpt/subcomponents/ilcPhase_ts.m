close all
clear
sim('ilcPhase_th')

subplot(2,1,1)
simout1.plot
grid on
hold on
simout.plot

subplot(2,1,2)
iterNum.plot
grid on 