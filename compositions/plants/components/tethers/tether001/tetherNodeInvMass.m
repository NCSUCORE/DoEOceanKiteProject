function invNodeMasses  = tetherNodeInvMass(Activelength,ActiveNodes, numNodes, thrDiam, tetherDensity)

%tetherDensity = 952;
%thrDiam = .0144;

Na = ActiveNodes;
No = numNodes;%length(Activelength)+1;

% Mass of each link, 1xN-1
linkMasses  = tetherDensity*(Activelength*(pi/4)*thrDiam^2);

% 1/mass for each node, 3xN (repmat so that we can multiply with force
% vectors concatenated into matrix later
invNodeMasses = zeros(3,No);
invNodeMasses(:,(No-Na+1):end) = repmat(1./([linkMasses((No-Na+1)) linkMasses((No-Na+1):end-1)+linkMasses((No-Na+2):end) linkMasses(end)]/2),[3 1]);

%Make Zero Inverse mass also equal to zero
for i = 1:size(invNodeMasses,2)
    if invNodeMasses(:,i) == Inf
        invNodeMasses(:,i) = zeros(3,1);
    end
end

%makes bottom node mass on ground node
if invNodeMasses(:,1) == 0
    invNodeMasses(:,1) = invNodeMasses(:,No-Na+1);
    invNodeMasses(:,No-Na+1) = [0;0;0];
end


