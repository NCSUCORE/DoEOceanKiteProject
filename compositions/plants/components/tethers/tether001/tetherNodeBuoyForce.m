function nodeForceVecs = tetherNodeBuoyForce(ActiveLengths, NumberNodesActive, numNodes, thrDiam, tetherDensity, gravity, fluidDensity)


%tetherDensity = 952;
%fluidDensity = 1025;
%thrDiam = .0144;
%gravity = 9.81;

% In this notation, N is the number of nodes
Na = NumberNodesActive;
No = numNodes;%size(nodePositions,2);

% Actual Length of each link 1xN-1
% linkLengths = sqrt(sum(diff(nodePositions,1,2).^2));

% Number of links, scalar
numLinks = numNodes-1;

% Volume of each link, 1xN-1
Volumes  = ActiveLengths(:)'.*(pi/4)*thrDiam^2;

% Mass of each link, 1xN-1
linkMasses = tetherDensity*Volumes;

% Net force on the links (Buoyancy - Weight) on each link, 3xN-1
linkNetForceVecs = zeros(3,numNodes-1);
linkNetForceVecs(end,:) = -gravity*linkMasses + gravity*fluidDensity*Volumes;

% Net force on the nodes, 3xN
nodeForceVecs = [linkNetForceVecs(:,1) linkNetForceVecs(:,1:numLinks-1)+linkNetForceVecs(:,2:numLinks) linkNetForceVecs(:,numLinks)]/2;

% Moves bottome node force to ground force
if linkMasses(1) == 0
    nodeForceVecs(:,1) = nodeForceVecs(:,No-Na+1);
    nodeForceVecs(:,No-Na+1) = [0;0;0];
end


