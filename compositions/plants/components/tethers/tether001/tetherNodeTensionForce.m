function [nodeForceVecs,Scope]  = tetherNodeTensionForce(ReeledOutLength, nodePos, nodeVel, ActiveLengths, ...
    NumberNodesActive, numNodes, thrDiam, youngsMod, dampingRatio, mass,minSoftLength)


No = numNodes;          %Total Nodes
Na = NumberNodesActive; %Nodes that arent reeled-in

unstretchedLength = ReeledOutLength; %Total Reeled out length
totalSpringConst = youngsMod*(pi/4)*(thrDiam^2)/unstretchedLength;

%Finds Spring Constant
SpringConsts = zeros(1,numNodes-1);
if Na>2
    SpringConsts(:,(No-Na+2):end) = youngsMod*(pi/4)*(thrDiam^2)./ActiveLengths(1,(end-NumberNodesActive+3):end);
    if ActiveLengths(1,(end-NumberNodesActive+2))>minSoftLength
        SpringConsts(:,(No-Na+1)) = youngsMod*(pi/4)*(thrDiam^2)./ActiveLengths(1,(end-NumberNodesActive+2));
    else %If below spring softening limit
        SpringConsts(:,(No-Na+1)) = youngsMod*(pi/4)*(thrDiam^2)./minSoftLength;
    end
else %If on last link
    SpringConsts(end) = totalSpringConst;
end

%finds damping coe
DampCoeffs = dampingRatio*2*sqrt(SpringConsts.*mass);

%finds vectors between nodes
linkVecs  = diff(nodePos,1,2);
linkLength = sqrt(sum(linkVecs.^2));

%Finds unit vectors between nodes
linkUnitVecs = zeros(3,numNodes-1);
linkUnitVecs(1:3,(No-Na+1):end) = linkVecs(1:3,(No-Na+1):end)./repmat(sqrt(sum((linkVecs(1:3,(No-Na+1):end).^2),1)),[3 1]);

%prevent divide by zero if reeled in 
linkUnitVecs(isnan(linkUnitVecs))=0;

%Rate of change of all links
linkLengthDeriv = dot(nodeVel(:,2:end)-nodeVel(:,1:end-1),linkUnitVecs);

%Finds spring and damping total (Corrected below)
springForces = SpringConsts.*(linkLength-ActiveLengths);
damperForces = DampCoeffs.*linkLengthDeriv;


%Finds locations where there in no tension
mask = (linkLength-ActiveLengths) < 0;

%No compressive force in tether
springForces(mask) = (tanh(springForces(mask)));

%No damping in slack tether
damperForces(mask) = 0;%(tanh(damperForces(mask)));

%Finds force along each link
totalLinkForceVec = repmat(springForces+damperForces,[3 1]).*linkUnitVecs;
%totalLinkForceVec = repmat(springForces,[3 1]).*linkUnitVecs;

%Finds force on each node
nodeForceVecs = zeros(3,No);
nodeForceVecs(:,(No-Na+1):end) = [totalLinkForceVec(:,(No-Na+1)) diff(totalLinkForceVec(:,(No-Na+1):end),1,2) -totalLinkForceVec(:,end)];
%nodeForceVecs= [totalLinkForceVec(:,1) diff(totalLinkForceVec,1,2) -totalLinkForceVec(:,end)];

%Moves Reeled in bottom  node force to Ground Node
if SpringConsts(1) == 0
    nodeForceVecs(:,1) = nodeForceVecs(:,No-Na+1);
    nodeForceVecs(:,No-Na+1) = [0;0;0];
end

Scope = [damperForces linkLengthDeriv];
