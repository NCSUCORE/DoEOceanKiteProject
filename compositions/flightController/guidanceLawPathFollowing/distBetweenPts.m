function dist = distBetweenPts(rCM,s0,aBooth,bBooth,meanElevation,radius)

dist = norm(rCM - getPathCoords(aBooth,bBooth,meanElevation,radius,s0));

end