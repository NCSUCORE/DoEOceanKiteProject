
%% This is the build script for a multinode reel-in/reel-out tether with fairings 
TETHERS = 'tetherM';

%% Tethers
thr = OCT.tetherM;                     % Create the tether

%% Set tether properties (can be reset in test script)
thr.maxTetherLength.setValue(600,'m')       % Max tether that is avalible total
thr.setLinkLength      (60,'m')          % Total nodes in tether
thr.setNominalDrag     (1,'')          % Drag coeff on tether
thr.setFairingDrag     (.1,'')          % Drag coeff on tether with farrings
thr.setFairingLength   (120,'m')       % Fairing length measured from kite
thr.setDiameter        (0.018,'m')    % Total tether diameter
thr.setYoungsMod       (57e9,'Pa')     % Total tether Youngs Modulus
thr.setDampingRatio    (.1,'')          % Tether damping ratio
thr.setDensity         (1500,'kg/m^3') % Total tether density
thr.setMinLinkLength   (1,'m')         % Minimum individual link length (increasing this
                                       % value can help with stiffness seen at short link
                                       % lengths)
thr.setInitTetherLength(600,'m')       % Initial total tether length

val = thr.maxTetherLength.Value/thr.linkLength.Value+1;
if mod(val,1)~=0
    error('Total length/link length is not and integer')
elseif thr.fairingLength.Value <= thr.linkLength.Value
    error('Link length is to large')
else
    thr.numNodes.setValue(val,'')
end

%% Save file in its respective directory
saveBuildFile('thr',mfilename,'variant','TETHERS');

%% This is code which should be put into the test script to set initial conditions
% thr.setInitGndNodePos(gndStn.thrAttch1.posVec.Value(:)... % Initial ground node (glider/ground) position
%    +gndStn.posVec.Value(:),'m')  
% thr.setInitAirNodePos(vhcl.initPosVecGnd.Value(:)+...     % Initial air node (kite) position
%    rotation_sequence(vhcl.initEulAng.Value)*vhcl.thrAttchPts_B.posVec.Value,'m');
% thr.setInitGndNodeVel([0 0 0]','m/s');                    % Initial ground node (glider/ground) velocity
% thr.setInitAirNodeVel(vhcl.initVelVecBdy.Value(:),'m/s'); % Initial air node (kite) velocity
