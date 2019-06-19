% disp("Running pathFollowingController_init")
pathLoc = @(s)boothSToGroundPos(s,aMask,bMask,curveLatMask,0);
centralAngle = @(s)acos(dot(initPosForInitSStar,pathLoc(s))/...
                   (norm(pathLoc(s))*norm(initPosForInitSStar)));
sVals = linspace(0,2*pi,1000);
angles = zeros(length(sVals),1);
for i=1:length(sVals)
    angles(i)=centralAngle(sVals(i));
end
[~,minIndex]=min(angles);
initS=sVals(minIndex);
