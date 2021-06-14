function nodeForceVecs = tetherNodeDragForce(nodePositions,nodeVelocities, flowVel, NumberNodesActive, numNodes, dragCoeff, thrDiam, flowDensity)

% % % %flowDensity = 1025;
% % % %dragCoeff = .5;
% % % %thrDiam = .0144;
% % % %thrDiam = diameter;

TotalNodes = numNodes;%size(nodePositions,2);
No = TotalNodes;
Na = NumberNodesActive;

% Velocity and center of links 3xN-1
linkVelocities = (nodeVelocities(:,1:end-1) + nodeVelocities(:,2:end))/2;

% Apparent flow at center of links 3xN-1
linkAppFlow = flowVel - linkVelocities; 

% Link center apparent flow magnitude 3xN-1
linkAppFlowMag = sqrt(sum(linkAppFlow.^2)); % Sum over columns

% Normalize columns to get unit vector 3xN-1
dragDirUnitVec = linkAppFlow./repmat(linkAppFlowMag,[3 1]);
dragDirUnitVec(isnan(dragDirUnitVec)) = 0;

% Dynamic pressures at link centers 1xN-1
dynPress = 0.5*flowDensity*linkAppFlowMag.^2;

%Vector Between All Nodes
linkVecs  = diff(nodePositions,1,2);

% Link lengths, diff over columns 1xN-1
linkLengths = sqrt(sum(diff(nodePositions,1,2).^2));

% Unit vectors in the direction of the link 3xN-1
linkUnitVecs = zeros(3,TotalNodes-1);
linkUnitVecs(1:3,(end-NumberNodesActive+2):end) = linkVecs(1:3,(end-NumberNodesActive+2):end)./repmat(sqrt(sum((linkVecs(1:3,(end-NumberNodesActive+2):end).^2),1)),[3 1]);

%Check for reeled in Nodes prevent divide by zero
linkUnitVecs(isnan(linkUnitVecs))=0;

% Projected areas of each link
projArea = thrDiam*linkLengths.*sqrt(sum(cross(linkUnitVecs,dragDirUnitVec).^2,1));

% Drag force on links
linkForceVecs = repmat(dragCoeff.*dynPress.*projArea,[3 1]).*dragDirUnitVec;

% Drag force on nodes
nodeForceVecs = zeros(3,TotalNodes);
nodeForceVecs(:,(No-Na+1):end) = [linkForceVecs(:,(No-Na+1)), (linkForceVecs(:,((No-Na+1)):end-1)+linkForceVecs(:,((No-Na+2)):end)) linkForceVecs(:,end)]/2;

% Moves Reeled in bottom Node to Ground Node
if NumberNodesActive<TotalNodes
    nodeForceVecs(:,1) = nodeForceVecs(:,No-Na+1);
    nodeForceVecs(:,No-Na+1) = [0;0;0];
end


