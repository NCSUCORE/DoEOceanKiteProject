function Tmax = getMaxTension(thrDiam)

Dref = [0.4, 0.5, 0.6, 0.7]*25.4;
Tref = [1480,2380,3240,3860]*4.448/1000;
Tmax = interp1(Dref,Tref,thrDiam,'linear','extrap');

end

