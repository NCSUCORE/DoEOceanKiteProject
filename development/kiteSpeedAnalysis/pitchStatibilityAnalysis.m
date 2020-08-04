function val = pitchStatibilityAnalysis(flowSpeed,kiteSpeedInX,...
    centerOfBuoyXLoc,wingAeroCenterXLoc,hstabAeroCenterXLoc,...
    bridleZLoc,elevation,azimuth,tangentPitch,heading,...
    mass,gravity,density,buoyFactor,wing,hstab,elevatorDeflection)

% Frames
% G - Ground/inertial frame
% T - Tangent frame
% B - body frame

%% local variables
wingArea = wing.span^2/wing.aspectRatio;
HstabArea = hstab.span^2/hstab.aspectRatio;

%% assumptions/defintions
% flow velocity vector in ground frame
G_vFlow = [flowSpeed;0;0];

% kite velocity vector in the intermediate tangent frame
B1_vKite = [-kiteSpeedInX;0;0];

% center of buoyancy in body frame
B_rCB = centerOfBuoyXLoc*[1;0;0];

% wing aerodynamic center in body frame
B_rWing = wingAeroCenterXLoc*[1;0;0];

% H-stab aerodynamic center in body frame
B_rHstab = hstabAeroCenterXLoc*[1;0;0];

% tether bridle location in body frame
B_rBridle = bridleZLoc*[0;0;1];

% rotation matrix from ground to tangent frame
TcG = Ry(pi/2 - elevation)*Rz(azimuth);

% inetermediate frame between tangent and body frame
% velocity is defined in this frame, ie, B1
B1cT = Rz(heading);

% rotation from intermediate frame to body frame
BcB1 = Ry(tangentPitch);

% rotation matrix from tangent to body frame
BcT = BcB1*B1cT;
TcB = transpose(BcT);

% rotation from ground to body frame
BcG = BcT*TcG;

% buoyancy force in ground frame
G_fBuoy = buoyFactor*mass*gravity*[0;0;1];
% rotate to body frame
B_fBuoy = BcG*G_fBuoy;

% buoyancy moment in body frame
B_mBuoy = cross(B_rCB,B_fBuoy);

% weight force in ground frame
G_fWeight = mass*gravity*[0;0;-1];

% rotate to body frame
B_fWeight = BcG*G_fWeight;

% apparent velocity in the body frame
B_vApp = BcG*G_vFlow - BcB1*B1_vKite;

% angle of attack
AoA = atan2(B_vApp(3),B_vApp(1));

% drag direction in body frame
B_uDrag = B_vApp./max(eps,norm(B_vApp));

% lift direction in body frame
B_uLift = cross(B_uDrag,[0;1;0]);

% get aero coeffs
[CdWing,ClWing,CdHstab,ClHstab] = getAeroCoeffs(AoA,...
    elevatorDeflection,wing,hstab);

% drag on wing in body frame
B_dWing = 0.5*CdWing*density*wingArea*B_uDrag*norm(B_vApp)^2;

% lift on wing in body frame
B_lWing = 0.5*ClWing*density*wingArea*B_uLift*norm(B_vApp)^2;

% wing moment in body frame
B_mWing = cross(B_rWing,(B_dWing + B_lWing));

% drag on H-stab in body frame
B_dHstab = 0.5*CdHstab*density*HstabArea*B_uDrag*norm(B_vApp)^2;

% lift on H-stab in body frame
B_lHstab = 0.5*ClHstab*density*HstabArea*B_uLift*norm(B_vApp)^2;

% H-stab moment in body frame
B_mHstab = cross(B_rHstab,(B_dHstab + B_lHstab));

% solve for tether force
tetForce = -dot(TcB*(B_fBuoy + B_fWeight + B_dWing + B_lWing + B_dHstab +...
    B_lHstab),[0;0;1]);

% tether force in body frame
B_fTether = BcT*[0;0;tetForce];

% moment due to tether in body frame
B_mTether = cross(B_rBridle,B_fTether);

% sum of moments in body frame
B_mSum = B_mBuoy + B_mWing + B_mHstab + B_mTether;

end

%% local functions
function C = Rx(x)
C = [1 0 0; 0 cos(x) sin(x); 0 -sin(x) cos(x)];
end
function C = Ry(x)
C = [cos(x) 0 -sin(x); 0 1 0; sin(x) 0 cos(x)];
end
function C = Rz(x)
C = [cos(x) sin(x) 0; -sin(x) cos(x) 0; 0 0 1];
end

function [CdWing,ClWing,CdHstab,ClHstab] = getAeroCoeffs(angleOfAttack,...
    elevatorDeflection,wing,hstab)

% local variables
eWing = wing.oswaldEff;
ARWing = wing.aspectRatio;
wingZeroAoALift = wing.ZeroAoALift;
wingZeroAoADrag = wing.ZeroAoADrag;

eHstab = hstab.oswaldEff;
ARHstab = hstab.aspectRatio;
hstabZeroAoALift = hstab.ZeroAoALift;
hstabZeroAoADrag = hstab.ZeroAoADrag;
dClHstab = hstab.dcLbydElevator;

% wing lift curve slope
wingLiftSlope = 2*pi/(1 + (2*pi/(pi*eWing*ARWing)));
% HY-stab lift curve slop
hstabLiftSlope = 2*pi/(1 + (2*pi/(pi*eHstab*ARHstab)));

% wing lift coeff
ClWing = wingLiftSlope*angleOfAttack + wingZeroAoALift;
% H-stab lift coeff
ClHstab = hstabLiftSlope*angleOfAttack + hstabZeroAoALift +...
    elevatorDeflection*dClHstab;

% wing drag coeff
CdWing = wingZeroAoADrag + ClWing^2/(pi*eWing*ARWing);
% H-stab drag coeff
CdHstab = hstabZeroAoADrag + ClHstab^2/(pi*eHstab*ARHstab);


end

