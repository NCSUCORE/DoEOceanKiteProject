function val = getPathCoords(aBooth,bBooth,meanElevation,radius,s)

val = [radius.*cos(meanElevation-(aBooth.^2.*1.0./bBooth.^2.*cos(s).*sin(s))./(aBooth.^2.*1.0./bBooth.^2.*cos(s).^2+1.0)).*cos((aBooth.*sin(s))./(aBooth.^2.*1.0./bBooth.^2.*cos(s).^2+1.0));
    -radius.*cos(meanElevation-(aBooth.^2.*1.0./bBooth.^2.*cos(s).*sin(s))./(aBooth.^2.*1.0./bBooth.^2.*cos(s).^2+1.0)).*sin((aBooth.*sin(s))./(aBooth.^2.*1.0./bBooth.^2.*cos(s).^2+1.0));
    radius.*sin(meanElevation-(aBooth.^2.*1.0./bBooth.^2.*cos(s).*sin(s))./(aBooth.^2.*1.0./bBooth.^2.*cos(s).^2+1.0))];
end