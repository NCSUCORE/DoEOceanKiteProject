function nodeForceVecs  = tetherNodeTensionForce(ReeledOutLength, nodePos, nodeVel, ActiveLengths, NumberNodesActive, numNodes, thrDiam, youngsMod, dampingRatio, mass)

% % % %mass = .05;
% % % %dampingRatio = .75;
% % % %thrDiam = .0144;
% % % %youngsMod = 5*10^10;

TotalNodes = numNodes;%size(nodePos,2);
No = TotalNodes;
Na = NumberNodesActive;

unstretchedLength = ReeledOutLength;
totalSpringConst = youngsMod*(pi/4)*(thrDiam^2)/unstretchedLength;

SpringConsts = zeros(1,TotalNodes-1);
if Na>2
    SpringConsts(:,(No-Na+1):end) = youngsMod*(pi/4)*(thrDiam^2)./ActiveLengths(1,(end-NumberNodesActive+2):end);
else
    SpringConsts(end) = totalSpringConst;
end
DampCoeffs = dampingRatio*2*sqrt(SpringConsts.*mass);

linkVecs  = diff(nodePos,1,2);
linkLength = sqrt(sum(linkVecs.^2));

linkUnitVecs = zeros(3,TotalNodes-1);
linkUnitVecs(1:3,(No-Na+1):end) = linkVecs(1:3,(No-Na+1):end)./repmat(sqrt(sum((linkVecs(1:3,(No-Na+1):end).^2),1)),[3 1]);
%prevent divide by zero if reeled in 
linkUnitVecs(isnan(linkUnitVecs)) = 0;

%Rate of change of all links
linkLengthDeriv = dot(nodeVel(:,2:end)-nodeVel(:,1:end-1),linkUnitVecs);

%Forces from spring and damping in each link
springForces = SpringConsts.*(linkLength-ActiveLengths);
damperForces = DampCoeffs.*linkLengthDeriv;

%Finds force along each link
totalLinkForceVec = repmat(springForces+damperForces,[3 1]).*linkUnitVecs;

%Finds force on each node
nodeForceVecs = [totalLinkForceVec(:,1) diff(totalLinkForceVec,1,2) -totalLinkForceVec(:,end)];

%Moves Reeled in bottom  node force to Ground Node
if SpringConsts(1) == 0
    nodeForceVecs(:,1) = nodeForceVecs(:,No-Na+1);
    nodeForceVecs(:,No-Na+1) = [0;0;0];
end


