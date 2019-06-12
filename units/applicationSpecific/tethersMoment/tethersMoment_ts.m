close all
clear
clc

frc1 = [1 0 0];
frc2 = [1 0 0];
frc3 = [-1 0 0];

rotMat = eye(3);

arms(1).arm = [0 1 0];
arms(2).arm = [0 1 0];
arms(3).arm = [0 1 0];

createSingleBus

sim('tethersMoment_th')

