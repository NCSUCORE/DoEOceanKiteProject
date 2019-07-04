nodePositions = eye(3);
unstretchedLength = 1;
tetherDensity = 1;
fluidDensity = 1;
diameter = 1;
gravity = 1;

% In this notation, N is the number of nodes

% Length of each link 1xN-1
linkLengths = sqrt(sum(diff(nodePositions,1,2).^2));

% Total length of all links, assuming they're straight lines, scalar
numericalTotalLength = sum(linkLengths);

% Number of links, scalar
numLinks = size(linkLengths,2);

% Total volume based on unspooled length, scalar
analyticalTotalVol  = unstretchedLength*(pi/4)*diameter^2;

% Total mass, based on unspooled length, scalar
analyticalTotalMass = tetherDensity*analyticalTotalVol;

% Mass of each link, 1xN-1
linkMasses  = analyticalTotalMass*(linkLengths./numericalTotalLength);

% Volume of each link, 1xN-1
linkVolumes = analyticalTotalVol*(linkLengths./numericalTotalLength);

% Net force on the links (buoyancy - gravity) on each link, 3xN-1
linkNetForceVecs = [repmat([0 0]',[1 numLinks]);(-gravity*linkMasses + fluidDensity*linkVolumes)];

% Net force on the nodes, 3xN
nodeForceVecs = [linkNetForceVecs(:,1) linkNetForceVecs(:,1:end-1)+linkNetForceVecs(:,2:end) linkNetForceVecs(:,end)]/2;

% 1/mass for each node, 1xN
invNodeMasses    = 1./([linkMasses(1) linkMasses(1:end-1)+linkMasses(2:end) linkMasses(end)]/2);


