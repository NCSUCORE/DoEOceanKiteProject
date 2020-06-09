function yt  =  calcAirfoilTh(x,t)

yt = 5*t*(0.2969*x.^0.5 - 0.126*x - 0.3516*x.^2 + 0.2843*x.^3 - 0.1036*x.^4);

end