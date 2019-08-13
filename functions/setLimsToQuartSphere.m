function setLimsToQuartSphere(hAx,posData,varargin)
% SETLIMSTOQUARTERSPHERE function to set plot limits to the quarter sphere
% that contains the position data given inPosData.  May also set plot
% limits to hemisphere, if posData contains both positive and negative
% elevation angles
% posData should be Nx3
% hAx is the handle to the axis that you'd like to set the limits on

% Calculate azimuth and elevation
r = sqrt(sum(posData.^2,2));
az = atan2(posData(:,2),posData(:,1));
el = (pi/2)-acos(posData(:,3)./r);
rMax = max(r);
azRng = [min(az) max(az)]*180/pi;
elRng = [min(el) max(el)]*180/pi;

if azRng(1)<0
    yMin = -rMax;
else
    yMin = 0;
end
if azRng(2)>=0
    yMax = rMax;
else
    yMax = 0;
end
% Not 100% sure x limits are correct for all cases
if any(az<-90) || any(az>90)
    xMin = -rMax;
else
    xMin = 0;
end
if all(az>-90) && all(az<90)
    xMax = rMax;
else
    xMin = 0;
end

if elRng(2)>0
    zMax = rMax;
else
    zMax = 0;
end

if elRng(2)<=0
    zMin = -rMax;
else
    zMin = 0;
end
xlim(hAx,[xMin xMax])
ylim(hAx,[yMin yMax])
zlim(hAx,[zMin zMax])


end