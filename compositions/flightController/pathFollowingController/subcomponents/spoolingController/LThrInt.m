function thrLenSP = LThrInt(s,sigmaVec,vOut,vIn,L0,deltaVec)

sc = sigmaVec(1);
sw = sigmaVec(2);
thrLenSP = zeros(size(s));
% de = deOut*ones(size(thrLenSP));

% Region 1:     0           to sc-sw
% Region 2:     sc-sw       to sc+sw
% Region 3:     sc+sw       to 0.5+sc-sw
% Region 4:     0.5+sc-sw   to 0.5+sc+sw
% Region 5:     0.5+sc+sw   to 1

% Integrate v_spool(s(t)) over the path to get the following piecewise
% function

r1 = and(s>=0           ,s< sc-sw);
r2 = and(s>=sc-sw       ,s< sc+sw);
r3 = and(s>=sc+sw       ,s< 0.5+sc-sw);
r4 = and(s>=0.5+sc-sw   ,s< 0.5+sc+sw);
r5 = and(s>=0.5+sc+sw   ,s<=1);

% Set the elevator deflection
% de(or(r2,r4)) = deIn;

% Region 1
thrLenSP(r1) = L0+...
    vOut.*((s(r1))       -   (0)         )./deltaVec(1);

% Region 2
thrLenSP(r2) = L0+...
    vOut.*((sc-sw)       -   (0)         )./deltaVec(1)+...
    vIn .*((s(r2))       -   (sc-sw)     )./deltaVec(2);

% Region 3
thrLenSP(r3) = L0+...
    vOut.*((sc-sw)       -   (0)         )./deltaVec(1)+...
    vIn .*((sc+sw)       -   (sc-sw)     )./deltaVec(2)+...
    vOut.*((s(r3))       -   (sc+sw)     )./deltaVec(3);

% Region 4
thrLenSP(r4) = L0+...
    vOut.*((sc-sw)       -   (0)         )./deltaVec(1)+...
    vIn .*((sc+sw)       -   (sc-sw)     )./deltaVec(2)+...
    vOut.*((0.5+sc-sw)   -   (sc+sw)     )./deltaVec(3)+...
    vIn .*((s(r4))       -   (0.5+sc-sw) )./deltaVec(4);

% Region 5
thrLenSP(r5) = L0+...
    vOut.*((sc-sw)       -   (0)         )./deltaVec(1)+...
    vIn .*((sc+sw)       -   (sc-sw)     )./deltaVec(2)+...
    vOut.*((0.5+sc-sw)   -   (sc+sw)     )./deltaVec(3)+...
    vIn .*((0.5+sc+sw)   -   (0.5+sc-sw) )./deltaVec(4)+...
    vOut.*((s(r5))       -   (0.5+sc+sw) )./deltaVec(5);
end