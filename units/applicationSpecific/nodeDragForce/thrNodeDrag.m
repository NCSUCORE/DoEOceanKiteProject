function nodeForceVecs = thrNodeDrag(nodePositions,nodeVelocities,thrDiam, flowDensity,flowVel,dragCoeff)
% In the notation here, N is the number of nodes, therefore you have N-1
% links between the nodes.
[n,m] = size(nodePositions);
if n < 3
    % Old Link Velocity Method
    % Velocity and center of links 3xN-1
    linkVelocities = nodeVelocities(:,2);
    
    % Apparent flow at center of links 3xN-1
    linkAppFlow = flowVel - linkVelocities; %repmat(flowVel(:),[1 size(linkVelocities,2)]) - linkVelocities;
    % linkAppFlow(3,:) = 0; % Origional model zeroed z component
    
    % Link center apparent flow magnitude 3xN-1
    linkAppFlowMag = sqrt(sum(linkAppFlow.^2)); % Sum over columns
else
    % New Link Velocity Method
    flowVelMag = sqrt(sum(flowVel.^2));
    v0Mag = sqrt(sum((flowVel-nodeVelocities(:,1:end-1)).^2));
    vFMag = sqrt(sum((flowVel-nodeVelocities(:,2:end)).^2));
    deltaVMag = vFMag-v0Mag;
    linkAppFlowMag = sqrt(v0Mag.^2-v0Mag.*deltaVMag+deltaVMag.^2/3);
    
    %drag Direction
    linkVelocities = (nodeVelocities(:,1:end-1) + nodeVelocities(:,2:end))/2;
    linkAppFlow = flowVel - linkVelocities; %repmat(flowVel(:),[1 size(linkVelocities,2)]) - linkVelocities;
    % Link center apparent flow magnitude 3xN-1
    %     linkAppFlowMag = sqrt(sum(linkAppFlow.^2)); % Sum over columns
end
% Normalize columns to get unit vector 3xN-1
dragDirUnitVec = linkAppFlow./repmat(linkAppFlowMag,[3 1]);

% If linkAppFlowMag is zero, dragDirUnitVec will have nans, patch to fix
% that with zeros
% dragDirUnitVec(:,linkAppFlowMag==0) = zeros(3,numel(linkAppFlowMag==0));

% Dynamic pressures at link centers 1xN-1
dynPress = 0.5*flowDensity*linkAppFlowMag.^2;

% Link lengths, diff over columns 1xN-1
linkLengths = sqrt(sum(diff(nodePositions,1,2).^2));

% Unit vectors in the direction of the link 3xN-1
linkUnitVecs = diff(nodePositions,1,2)./repmat(linkLengths,[3 1]);

% Projected areas of each link
projArea = thrDiam*linkLengths.*sqrt(sum(cross(linkUnitVecs,dragDirUnitVec).^2,1));

if n < 3
    % Drag force acts on the kite assuming 1/4 tether area
    linkForceVecs = dragCoeff.*dynPress.*projArea/4.*dragDirUnitVect;
    % Drag acts entirely on the kite. No drag exerted at ground station
    nodeForceVecs = [0 linkForceVecs];
    
else
    % Multi-node drag force calculation
    linkForceVecs = repmat(dragCoeff.*dynPress.*projArea,[3 1]).*dragDirUnitVec;
    
    % Drag force on nodes
    nodeForceVecs = [linkForceVecs(:,1) (linkForceVecs(:,1:end-1)+linkForceVecs(:,2:end)) linkForceVecs(:,end)]/2;
end
end
