clear; clc; format compact;

%% basic functions
% rotation about x axis
Rx = @(x) [1 0 0; 0 cos(x) sin(x); 0 -sin(x) cos(x)];

% rotation about y axis
Ry = @(x) [cos(x) 0 -sin(x); 0 1 0; sin(x) 0 cos(x)];

% rotation about z axis
Rz = @(x) [cos(x) sin(x) 0; -sin(x) cos(x) 0; 0 0 1];

% calculate angular velocity given rotation matrix
calcAngVel = @(OcB,t) simplify(diag([0 0 1;1 0 0;0 1 0]*(transpose(OcB)*...
    diff(OcB,t))*[0 0 1;1 0 0;0 1 0]));

% vector norm
vecNorm = @(x) sqrt(sum(x.^2));

%% initialize symbolics
syms ph(t) th(t) R(t) vfx rho A LbyD cL BF m g chi

%% assign the symbolics to descriptive variables
% azimuth angle
azimAng = ph;
% zenith angle
zenAng = th;
% radius of sphere
spRad = R;
% flow velocity vector written in the inertial frame
vFlow_O = [vfx;0;0];
% fluid density
fDensity = rho;
% reference area
refArea = A;
% lift by drag ratio
liftByDrag = LbyD;
% lift coefficient
liftCoeff = cL;
% buoyance factor
buoyFactor = BF;
% vehicle mass
vehMass = m;
% gravitational acceleration
gravAcc = g;
% roll angle
rollAng = chi;

%% pre-requisite calculations
% rotation matrix from the spherical frame (T) to inertial frame
TcO = Ry(zenAng)*Rz(azimAng);
% rotation in the other direction
OcT = transpose(TcO);
% angular velcoity of rotational frame wrt inertial frame
OwT = calcAngVel(OcT,t);

%% calculation of derivatives
% kite position in T frame
rcm_T = [0;0;spRad];
% inertial velocity in T frame
vcm_T0 = diff(rcm_T,t) + cross(OwT,rcm_T);
% inertial acceleration in T frame
acm_T0 = diff(vcm_T0) + cross(OwT,vcm_T0);

% create new symbolics to replace the ones dependent on t
syms d_Azim d_Zen d_R dd_Azim dd_Zen azim zen rad
% replace the old ones
vcm_T = subs(vcm_T0,[th(t),R(t),diff(th(t),t),diff(ph(t),t),diff(R(t),t)],...
    [zen,rad,d_Zen,d_Azim,d_R]);
% do this to remove dependence on t
vcm_T = vcm_T(t);
% repeat for acm_T
acm_T = subs(acm_T0,[th(t),ph(t),R(t),diff(th(t),t),diff(ph(t),t),diff(R(t),t),diff(th(t),t,t),diff(ph(t),t,t),diff(R(t),t,t)],...
    [zen,azim,rad,d_Zen,d_Azim,d_R,dd_Zen,dd_Azim,0]);
acm_T = acm_T(t);
% repeat for TcO
TcO = subs(TcO,[th(t),ph(t)],[zen,azim]);
TcO = TcO(t);
% repeat for OcT
OcT = subs(OcT,[th(t),ph(t)],[zen,azim]);
OcT = OcT(t);

%% load calculations
% apparent flow in T frame
va_T = vcm_T - TcO*vFlow_O;

% unit vector in the apparent flow direction
ua_T = va_T./vecNorm(va_T);

% drag force in the T frame
fDrag_T = -(1/2)*fDensity*(liftCoeff/liftByDrag)*refArea*...
    (vecNorm(va_T)^2)*ua_T;

% unit vector normal to radial axis and apparent velocity
nBar = cross([0;0;1],ua_T);

% unit vector normal to apparent velocity and nBar
mBar = cross(ua_T,nBar);

% unit vector in the direction of lift given a roll angle
uBar = mBar + tan(rollAng)*nBar;
uBar = uBar./vecNorm(uBar);

% lift force in the T frame
fLift_T = (1/2)*fDensity*liftCoeff*refArea*(vecNorm(va_T)^2)*uBar;

% weight and buoyancy force in T frame
fzNet_T = TcO*[0;0;vehMass*gravAcc*(buoyFactor-1)];

% total force in T frame
fTotal_T = fDrag_T + fLift_T + fzNet_T;

%% solve for accleration and tension
% tether force is equal to total force in the radial directioin
tetForce = matlabFunction(vehMass*acm_T(3) - fTotal_T(3));
% solve for zenithn angle acceleration
eqnSolve = solve(fTotal_T(1:2) - vehMass*acm_T(1:2)==[0;0],...
    [dd_Azim,dd_Zen]);
%% make matlab functions
% important ones
azimuthAccl = matlabFunction(eqnSolve.dd_Azim);
zenithAccl = matlabFunction(eqnSolve.dd_Zen);
% secondary ones
OcT = matlabFunction(OcT);
TcO = matlabFunction(TcO);



%% save the three functions
save('kiteSpeedFunctions','tetForce','azimuthAccl','zenithAccl','OcT','TcO');







