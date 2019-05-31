close all;clear;clc

d = 1;
Cp = 0.5;
Cd = 0.7;
rho = 1000;
turbPosVec = [0 -1 0];

vWindBdy  = [0 0 0];
velVecBdy = [0 0 0];
angVecBdy = [0 0 -1];


sim('turbine_th')

fprintf('FDragBdy\n')
FDrag = simout.data
uDrag = FDrag./norm(FDrag);

fprintf('MBdy\n')
MBdy = simout1.data
uMBdy = MBdy./norm(MBdy);

fprintf('power\n')
simout2.data


figure('Position',[ 0    0.0370    1.0000    0.8917])

scatter3(0,0,0,'Marker','o','CData',[1 0 0])
hold on
plot3([0 turbPosVec(1)],[0 turbPosVec(2)],[0 turbPosVec(3)])
scatter3(turbPosVec(1),turbPosVec(2),turbPosVec(3),'Marker','o','CData',[0 0 1])
quiver3(turbPosVec(1),turbPosVec(2),turbPosVec(3),uDrag(1),uDrag(2),uDrag(3),...
    'MaxHeadSize',10000,'LineStyle','-','Color','g')

plot3([0 1],[0 0],[0 0],'LineStyle','-','Color','r')
plot3([0 0],[0 1],[0 0],'LineStyle','-','Color','r')
plot3([0 0],[0 0],[0 1],'LineStyle','-','Color','r')

quiver3(turbPosVec(1),turbPosVec(2),turbPosVec(3),uMBdy(1),uMBdy(2),uMBdy(3),...
    'MaxHeadSize',10000,'LineStyle','-','Color','b')


axis square