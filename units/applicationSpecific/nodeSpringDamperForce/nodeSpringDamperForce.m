function nodeForceVecs = nodeSpringDamperForce(nodePositions,nodeVelocities,unstretchedLength,mass,zeta,diameter,youngsMod) %#codegen

% Number of nodes
N = size(nodePositions,2);

% Deal with variable length links, if present
if numel(unstretchedLength) > 1 %implies fairedNNode tether - variable link lengths
    totUnstretchedLength = sum(unstretchedLength);
    unstretchedLinkLength = unstretchedLength;
else
    totUnstretchedLength = unstretchedLength;
    unstretchedLinkLength   = unstretchedLength/(N-1);
end

totalSpringConst = youngsMod*(pi/4)*(diameter^2)/totUnstretchedLength;

% total damping coefficient
totalDampCoeff = zeta*2*sqrt(totalSpringConst*mass);

% Spring constant and damping coefficient for each link
linkSpringConst  = totalSpringConst*(N-1);
linkDampingCoeff = totalDampCoeff*(N-1);

% Vector from one node to another
linkVecs  = diff(nodePositions,1,2);

% Length of each link
linkLength = sqrt(sum(linkVecs.^2));

% Link direction unit vectors
linkUnitVecs = linkVecs./repmat(sqrt(sum(linkVecs.^2,1)),[3 1]);

% Rate of change of vector from one node to another
linkLengthDeriv = dot(nodeVelocities(:,2:end)-nodeVelocities(:,1:end-1),linkUnitVecs);


% Magnitude of spring force on each link
springForces = zeros(size(linkLength));
% springForces(linkLength>unstretchedLinkLength) = linkSpringConst*(linkLength(linkLength>unstretchedLinkLength)-unstretchedLinkLength);
springForces = linkSpringConst*(linkLength-unstretchedLinkLength);
springForces = springForces.*(linkLength>unstretchedLinkLength);
% Magnitude of damping force on each link
damperForces  = zeros(size(linkLengthDeriv));
damperForces(linkLength>unstretchedLinkLength) = linkDampingCoeff*linkLengthDeriv(linkLength>unstretchedLinkLength);

% Total force in each link
totalLinkForceVec = repmat(springForces+damperForces,[3 1]).*linkUnitVecs;

% Force on each node
nodeForceVecs = [totalLinkForceVec(:,1) diff(totalLinkForceVec,1,2) -totalLinkForceVec(:,end)];

end
