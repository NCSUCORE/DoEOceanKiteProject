function TLSP = combinedTLSP(s,ctrlVec,spdVec)
%Uses 8x1 ctrlVec and 5x1 spdVec  

sc = ctrlVec(1);
sw = ctrlVec(2);
deltaVec = ctrlVec(3:7);
L0 = ctrlVec(8);

TLSP = zeros(size(s));
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
TLSP(r1) = L0+...
    spdVec(1).*((s(r1))       -   (0)         )./deltaVec(1);

% Region 2
TLSP(r2) = L0+...
    spdVec(1).*((sc-sw)       -   (0)         )./deltaVec(1)+...
    spdVec(2).*((s(r2))       -   (sc-sw)     )./deltaVec(2);

% Region 3
TLSP(r3) = L0+...
    spdVec(1).*((sc-sw)       -   (0)         )./deltaVec(1)+...
    spdVec(2).*((sc+sw)       -   (sc-sw)     )./deltaVec(2)+...
    spdVec(3).*((s(r3))       -   (sc+sw)     )./deltaVec(3);

% Region 4
TLSP(r4) = L0+...
    spdVec(1).*((sc-sw)       -   (0)         )./deltaVec(1)+...
    spdVec(2).*((sc+sw)       -   (sc-sw)     )./deltaVec(2)+...
    spdVec(3).*((0.5+sc-sw)   -   (sc+sw)     )./deltaVec(3)+...
    spdVec(4).*((s(r4))       -   (0.5+sc-sw) )./deltaVec(4);

% Region 5
TLSP(r5) = L0+...
    spdVec(1).*((sc-sw)       -   (0)         )./deltaVec(1)+...
    spdVec(2) .*((sc+sw)       -   (sc-sw)     )./deltaVec(2)+...
    spdVec(3).*((0.5+sc-sw)   -   (sc+sw)     )./deltaVec(3)+...
    spdVec(4) .*((0.5+sc+sw)   -   (0.5+sc-sw) )./deltaVec(4)+...
    spdVec(5).*((s(r5))       -   (0.5+sc+sw) )./deltaVec(5);
end