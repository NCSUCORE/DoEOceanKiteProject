function nodeForceVecs = nodeSpringDamperForce(nodePositions,nodeVelocities,unstretchedLength,mass,zeta,diameter,youngsMod)

% Number of nodes
N = size(nodePositions,2);

% total spring stiffness
totalSpringConst = youngsMod*(pi/4)*(diameter^2)/unstretchedLength;

% total damping coefficient
totalDampCoeff = zeta*2*sqrt(totalSpringConst*mass);

% Spring constant and damping coefficient for each link
linkSpringConst  = totalSpringConst*(N-1);
linkDampingCoeff = totalDampCoeff*(N-1);
meanLinkLength   = unstretchedLength/(N-1);

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
springForces(linkLength>meanLinkLength) = linkSpringConst*(linkLength(linkLength>meanLinkLength)-meanLinkLength);

% Magnitude of damping force on each link
damperForces  = zeros(size(linkLengthDeriv));
damperForces(linkLength>meanLinkLength) = linkDampingCoeff*linkLengthDeriv(linkLength>meanLinkLength);

% Total force in each link
totalLinkForceVec = repmat(springForces+damperForces,[3 1]).*linkUnitVecs;

% Force on each node
nodeForceVecs = [totalLinkForceVec(:,1) diff(totalLinkForceVec,1,2) -totalLinkForceVec(:,end)];

end
