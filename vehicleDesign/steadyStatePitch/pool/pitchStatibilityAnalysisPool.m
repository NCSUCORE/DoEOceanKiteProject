function [val,PITCHOUT,OUT] = pitchStatibilityAnalysisPool(flowSpeed,kiteSpeedInX,...
                centerOfBuoyXLoc,centerOfBuoyZLoc,wingAeroCenterXLoc,wingAeroCenterZLoc,hstabAeroCenterXLoc,hstabAeroCenterZLoc,...
                bridleXLoc,centerOfMassXLoc,centerOfMassZLoc,elevation,azimuth,pitch,heading,...
                mass,gravAcc,density,buoyFactor,wing,hstab,...
                elevatorDeflection,pitchVector,flwSpdVector,turbineXLoc,turbineYLoc)

% Frames
% G - Ground/inertial frame
% T - Tangent frame
% B - body frame

%% local variables
wingArea  = wing.span^2/wing.aspectRatio;
HstabArea = hstab.span^2/hstab.aspectRatio;

%% assumptions/defintions
% flow velocity vector in ground frame
G_vFlow   = [flowSpeed;0;0];

%% vectors from tether attachment to force application
% kite velocity vector in the intermediate tangent frame (b/c tether)
B1_vKite  = [kiteSpeedInX;0;0];
% center of buoyancy in body frame
B_rCB     = [centerOfBuoyXLoc;0;centerOfBuoyZLoc];
% wing aerodynamic center in body frame
B_rWing   = [wingAeroCenterXLoc;0;wingAeroCenterZLoc];
% H-stab aerodynamic center in body frame
B_rHstab  = [hstabAeroCenterXLoc;0;hstabAeroCenterZLoc];
% tether attachment point in body frame
B_rBridle = bridleXLoc*[1;0;0];
% Center of mass in the body frame
B_rCM     = [centerOfMassXLoc;0;centerOfMassZLoc];

%% Forces in Ground Frame
% Get aero coeffs
syms pitch_Symbolic
[CdWing,ClWing,CdHstab,ClHstab] = getAeroCoeffsSymbolic(pitch_Symbolic,...
                                  elevatorDeflection,wing,hstab);

% % buoyancy force in ground frame
% G_fBuoy   = -buoyFactor*mass*gravAcc;
% % weight force   in ground frame
% G_fWeight = mass*gravAcc;
% % drag on wing   in ground frame
% G_dWing   = 0.5*CdWing *density*wingArea *norm(G_vFlow)^2;
% % lift on wing   in ground frame
% G_lWing   = 0.5*ClWing *density*wingArea *norm(G_vFlow)^2;
% % drag on H-stab in ground frame
% G_dHstab  = 0.5*CdHstab*density*HstabArea*norm(G_vFlow)^2;
% % lift on H-stab in ground frame
% G_lHstab  = 0.5*ClHstab*density*HstabArea*norm(G_vFlow)^2;

InitPitch = 0;
[ClWing_m,ClWing_b,ClHstab_m,ClHstab_b,CdWing_M,CdWing_B,CdHstab_M,CdHstab_B] = getAeroCoeffsNumeric(elevatorDeflection,wing,hstab);
PITCH = fsolve(@(P) ...
...%Forces in cross(X,Y) (H-stab lift, Wing lift, Weight, Boyancy )
      - hstabAeroCenterXLoc*((0.5*(ClHstab_m*P+ClHstab_b)*density*HstabArea*norm(G_vFlow)^2)*cos(P))...
      -  wingAeroCenterXLoc*((0.5*(ClWing_m*P +ClWing_b )*density*wingArea *norm(G_vFlow)^2)*cos(P))...
      +    centerOfMassXLoc*(mass*gravAcc)*cos(P)            ...
      -    centerOfBuoyXLoc*(buoyFactor*mass*gravAcc)*cos(P) ...  
...%Forces in cross(Y,X) (H-stab drag, Wing drag, Weight, Boyancy )
      + hstabAeroCenterZLoc*(0.5*(CdHstab_M*(ClHstab_m*P+ClHstab_b)^2+CdHstab_B)*density*HstabArea*norm(G_vFlow)^2)*sin(P) ...
      +  wingAeroCenterZLoc*(0.5*(CdWing_M *(ClWing_m *P+ClWing_b )^2+CdWing_B )*density*wingArea *norm(G_vFlow)^2)*sin(P) ...
      +    centerOfMassZLoc*(mass*gravAcc)*sin(P)            ...
      -    centerOfBuoyZLoc*(buoyFactor*mass*gravAcc)*sin(P) ...
      , InitPitch,optimoptions('fsolve','Display','off'));
  
PITCHOUT = rem(PITCH*(180/pi),360);

if PITCHOUT > 180
    PITCHOUT = -PITCHOUT+180;
elseif PITCHOUT < -180
    PITCHOUT = -PITCHOUT-180;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Refrence frames could be wrong!
%%%
%% Rotation Matricies
pitchRad = PITCHOUT*(pi/180);
L = (0.5*(ClWing_m*pitchRad+ClWing_b                         )*density*wingArea*norm(G_vFlow)^2);
D = (0.5*(CdWing_M*(ClWing_m *pitchRad+ClWing_b )^2+CdWing_B )*density*wingArea*norm(G_vFlow)^2);
elevation = tan(L/D);

% rotation matrix from ground to tangent frame
TcG = Ry(-elevation-pi/2)*Rz(azimuth); %Done Done
% inetermediate frame between tangent and body frame
% velocity is defined in this frame, ie, B1
B1cT = Rz(heading+pi);
% rotation from intermediate frame to body frame
BcB1 = Ry(-(pitchRad+pi/2)-elevation);
% rotation matrix from tangent to body frame
BcT = BcB1*B1cT;
TcB = transpose(BcT);
% rotation from ground to body frame
BcG = BcT*TcG;
GcB = BcG';

%% Refrecne Frame PLOT CHECK
ORIG = [1;0;0];AAA = BcG*ORIG;quiver3(0,0,0,ORIG(1),ORIG(2),ORIG(3),'r');hold on;quiver3(0,0,0,AAA(1),AAA(2),AAA(3),'g');hold off;%xlim([-1,1]);ylim([-1,1]);zlim([-1,1]);set ( gca, 'ydir', 'reverse' );set ( gca, 'zdir', 'reverse' )
hold on
ORIG = [0;1;0];AAA = BcG*ORIG;quiver3(0,0,0,ORIG(1),ORIG(2),ORIG(3),'r');hold on;quiver3(0,0,0,AAA(1),AAA(2),AAA(3),'b');hold off;%xlim([-1,1]);ylim([-1,1]);zlim([-1,1]);set ( gca, 'ydir', 'reverse' );set ( gca, 'zdir', 'reverse' )
hold on
ORIG = [0;0;1];AAA = BcG*ORIG;quiver3(0,0,0,ORIG(1),ORIG(2),ORIG(3),'r');hold on;quiver3(0,0,0,AAA(1),AAA(2),AAA(3),'b');hold off;%xlim([-1,1]);ylim([-1,1]);zlim([-1,1]);set ( gca, 'ydir', 'reverse' );set ( gca, 'zdir', 'reverse' )
xlabel('X')
ylabel('Y')
zlabel('Z')


%% Forces and Moments
% buoyancy force in ground frame
G_fBuoy = buoyFactor*mass*gravAcc*[0;0;-1];
% rotate to body frame
B_fBuoy = BcG*G_fBuoy;
% buoyancy moment in body frame
B_mBuoy = cross(B_rCB,B_fBuoy);

% weight force in ground frame
G_fWeight = mass*gravAcc*[0;0;1];
% rotate to body frame
B_fWeight = BcG*G_fWeight;
% weight moment in body frame
B_mWeight = cross(B_rCM,B_fWeight);

% apparent velocity in the body frame
B_vApp = BcG*G_vFlow - BcB1*B1_vKite;
% angle of attack
AoA = pitch;%atan2(B_vApp(3),B_vApp(1));
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

% monk moment from lookup table
load('MunkMoments')
pitchIndex = find(round(pitch*180/pi,0)==pitchVector);
flowIndex = find(flowSpeed==flwSpdVector);
B_mMunk = [0;0;0];%squeeze(Munk.M(flowIndex,pitchIndex,:));

%% solve euation to find kite pitch

% % solve for tether force
% tetForce = -dot(TcB*(B_fBuoy + B_fWeight + B_dWing + B_lWing + B_dHstab +...
%     B_lHstab),[0;0;1]);
% % tether force in body frame
% B_fTether = BcT*[0;0;tetForce];
% % moment due to tether in body frame
% B_mTether = cross(B_rBridle,B_fTether);

B_mSum = B_mBuoy + B_mWeight + B_mWing + B_mHstab + B_mMunk;

% output
val.sumPitchMoments   = B_mSum(2)   ;
val.buoyPitchMoment   = B_mBuoy(2)  ;
val.wingPitchMoment   = B_mWing(2)  ;
val.hstabPitchMoment  = B_mHstab(2) ;
val.munkPitchMoment   = B_mMunk(2)  ;
val.weightPitchMoment = B_mWeight(2);

OUT = atan2(norm(B_lWing),norm(B_dWing))*(180/pi);
 
end

%% local functions
function C = Rx(x)
C = [ 1 0      0       ;...
    0 cos(x) -sin(x) ;...
    0 sin(x)  cos(x) ];
end
function C = Ry(x)
C = [ cos(x)  0 sin(x) ;...
    0       1 0      ;...
    -sin(x) 0 cos(x) ];
end
function C = Rz(x)
C = [cos(x) -sin(x) 0;...
    sin(x)  cos(x) 0;...
    0       0      1];
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

function [CdWing,ClWing,CdHstab,ClHstab] = getAeroCoeffsSymbolic(angleOfAttack,...
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

function [ClWing_m,ClWing_b,ClHstab_m,ClHstab_b,CdWing_M,CdWing_B,CdHstab_M,CdHstab_B] = getAeroCoeffsNumeric(elevatorDeflection,wing,hstab)

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
ClWing_m = wingLiftSlope   ;
ClWing_b =  wingZeroAoALift;
% H-stab lift coeff
ClHstab_m = hstabLiftSlope                                  ;
ClHstab_b = + hstabZeroAoALift + elevatorDeflection*dClHstab;

% wing drag coeff
CdWing_M = 1/(pi*eWing*ARWing);
CdWing_B = wingZeroAoADrag    ;
% H-stab drag coeff
CdHstab_M = 1/(pi*eHstab*ARHstab);
CdHstab_B = hstabZeroAoADrag     ;

end

%% Extra

% RHS = - hstabAeroCenterXLoc*(G_lHstab *cos(pitch_Symbolic)+G_dHstab*sin(pitch_Symbolic)) ...
%       - hstabAeroCenterZLoc*(G_lHstab *sin(pitch_Symbolic)+G_dHstab*cos(pitch_Symbolic)) ...
%       -  wingAeroCenterXLoc*(G_lWing  *cos(pitch_Symbolic)+ G_dWing*sin(pitch_Symbolic)) ...
%       -  wingAeroCenterZLoc*(G_lWing  *sin(pitch_Symbolic)+ G_dWing*cos(pitch_Symbolic)) ...
%       +    centerOfMassXLoc* G_fWeight*cos(pitch_Symbolic)                  ...
%       +    centerOfMassZLoc* G_fWeight*sin(pitch_Symbolic)                  ...
%       +    centerOfBuoyXLoc* G_fBuoy  *cos(pitch_Symbolic)                  ...
%       +    centerOfBuoyZLoc* G_fBuoy  *sin(pitch_Symbolic)                  ;
% 
% LHS = 0;

%
% % monk moment from lookup table
% load('MunkMoments')
% pitchIndex = find(round(pitch*180/pi,0)==pitchVector);
% flowIndex = find(flowSpeed==flwSpdVector);
% B_mMunk = squeeze(Munk.M(flowIndex,pitchIndex,:));
%
%
% syms e
% p = pitch;
% h = heading;
% Xdist = bridleXLoc;
% T = tetForce;
% Moment = B_mBuoy + B_mWing + B_mHstab + B_mTether + B_mMunk;
% Xm = Moment(1);
% Ym = Moment(2);
% Zm = Moment(3);
% BcT = simplify(expand(Ry(-p-e)*Rz(h+pi)*Ry(e-pi/2)));
% ANS = solve(-[Xm;Ym;Zm]==cross([Xdist;0;0],BcT*[0;0;T]))

%
% elseif SET == 2
%
%     k     = 1;
%     Ym    = B_mBuoy(2) + B_mWing(2) + B_mHstab(2) + B_mTether(2) + B_mMunk(2);
%     p     = pitch;
%     T     = tetForce;
%     Xdist = B_rBridle(1);
%     %Elevate = (2*pi*k - acos(Ym/(T*Xdist)) - p)*(180/pi);
%     Elevate = acos(Ym/(T*Xdist)) - p + 2*pi*k;
%     val.sumPitchMoments = 0;
% end