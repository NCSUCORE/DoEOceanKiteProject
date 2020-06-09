function posGround = boothSToGroundPos(s,aBooth,bBooth,latCurve,longCurve)
    long=@(x) aBooth*sin(x)./(1+(aBooth/bBooth)^2*cos(x).^2);
    lat=@(x) (aBooth/bBooth)^2*sin(x).*cos(x)./(1 + (aBooth/bBooth)^2*cos(x).^2);
    path = @(x)[cos(longCurve+long(x)).*cos(latCurve+lat(x));...
                sin(longCurve+long(x)).*cos(latCurve+lat(x));...
                sin(latCurve+lat(x));];
    posGround=path(s);
end