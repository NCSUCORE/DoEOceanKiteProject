function Ik = calculateIndicatorMat(altitude,discreteAltitudes)
% local variables
xM = discreteAltitudes(:);
xLoc = altitude;
% preallocate
Ik = zeros(1,length(xM));
% find the first point below xLoc
firstBelow = find(xLoc>=xM,1,'last');
% find the first point above xLoc
firstAbove = find(xLoc<=xM,1,'first');
% distance between the two locations
distBetween = norm(xM(firstBelow) - xM(firstAbove));
if firstBelow ~= firstAbove
    % weighted average
    Ik(firstBelow) = norm(xM(firstAbove) - xLoc)/distBetween;
    Ik(firstAbove) = norm(xM(firstBelow) - xLoc)/distBetween;
else
    Ik(firstBelow) = 1;
end

end