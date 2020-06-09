clear;clc

eulAng = 2*(rand(3,1)-0.5)*90
% eulAng = [45 45 0]
sim('quatConversion_th')
simout.Data'
simout1.Data