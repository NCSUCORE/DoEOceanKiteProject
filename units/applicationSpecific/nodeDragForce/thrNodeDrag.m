function nodeForceVecs = thrNodeDrag(nodePositions,nodeVelocities,thrDiam, flowDensity,flowVel,dragCoeff)
% In the notation here, N is the number of nodes, therefore you have N-1
% links between the nodes.
[~,m] = size(nodePositions);
if m < 3
    % Velocity at kite node
    linkVelocities = nodeVelocities(:,2);
    
    % Apparent flow at center of links 3xN-1
    linkAppFlow = flowVel - linkVelocities; 
    
    % Link apparent flow magnitude
    linkAppFlowMag = sqrt(sum(linkAppFlow.^2)); % Sum over columns
    dragDirUnitVec = linkAppFlow./linkAppFlowMag;
else
    % New Link Velocity Method
%     flowVelMag = sqrt(sum(flowVel.^2));
%     v0Mag = sqrt(sum((flowVel-nodeVelocities(:,1:end-1)).^2));
%     vFMag = sqrt(sum((flowVel-nodeVelocities(:,2:end)).^2));
%     deltaVMag = vFMag-v0Mag;
%     linkAppFlowMag = sqrt(v0Mag.^2-v0Mag.*deltaVMag+deltaVMag.^2/3);
    
    % Link velocities
    linkVelocities = (nodeVelocities(:,1:end-1) + nodeVelocities(:,2:end))/2;
    linkAppFlow = flowVel - linkVelocities;
    % Link center apparent flow magnitude 3xN-1
    linkAppFlowMag = sqrt(sum(linkAppFlow.^2)); % Sum over columns
    % Drag Direction Unit Vector
    dragDirUnitVec = linkAppFlow./repmat(linkAppFlowMag,[3 1]);
end

% Dynamic pressures at link centers 1xN-1
dynPress = 0.5*flowDensity*linkAppFlowMag.^2;

% Link lengths, diff over columns 1xN-1
linkLengths = sqrt(sum(diff(nodePositions,1,2).^2));

% Unit vectors in the direction of the link 3xN-1
linkUnitVecs = diff(nodePositions,1,2)./repmat(linkLengths,[3 1]);

% Projected areas of each link
projArea = thrDiam*linkLengths.*sqrt(sum(cross(linkUnitVecs,dragDirUnitVec).^2,1));
if m < 3
    % Drag force acts on the kite assuming 1/4 tether area
    linkForceVecs = dragCoeff.*dynPress.*projArea/4.*dragDirUnitVec;
    % Drag acts entirely on the kite. No drag exerted at ground station
    nodeForceVecs = [zeros(3,1) linkForceVecs];
    
else
    % Multi-node drag force calculation
    linkForceVecs = repmat(dragCoeff.*dynPress.*projArea,[3 1]).*dragDirUnitVec;
    
    % Drag force on nodes
    nodeForceVecs = [linkForceVecs(:,1) (linkForceVecs(:,1:end-1)+linkForceVecs(:,2:end)) linkForceVecs(:,end)]/2;
end
end
