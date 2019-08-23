clear;clc

eulAng = 2*(rand(3,1)-0.5)*90
sim('quatConversion_th')
eulAng(:)
eulOut.Data(:)
abs(eulAng(:)-eulOut.Data(:))
