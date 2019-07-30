% surface outlines
function val = get.surfaceOutlines(obj)
% dummy variables
R_wle = obj.RwingLE_cm.Value;

w_cr = obj.wingChord.Value;
w_s = w_cr*obj.wingAR.Value;
w_ct = w_cr*obj.wingTR.Value;
w_sweep = obj.wingSweep.Value;
w_di = obj.wingDihedral.Value;

R_hsle = obj.RhsLE_wingLE.Value;
hs_cr = obj.hsChord.Value;
hs_s = hs_cr*obj.hsAR.Value;
hs_ct = hs_cr*obj.hsTR.Value;
hs_sweep = obj.hsSweep.Value;
hs_di = obj.hsDihedral.Value;

R_vsle = obj.Rvs_wingLE.Value;
vs_cr = obj.vsChord.Value;
vs_s = obj.vsSpan.Value;
vs_ct = vs_cr*obj.vsTR.Value;
vs_sweep = obj.vsSweep.Value;

port_wing =  repmat(R_wle',5,1) +  [0, 0, 0;...
    w_s*tand(w_sweep)/2, -w_s/2, tand(w_di)*w_s/2;...
    (w_s*tand(w_sweep)/2)+w_ct, -w_s/2, tand(w_di)*w_s/2;...
    w_cr, 0, 0;...
    0, 0, 0];

stbd_wing = port_wing.*[ones(5,1),-1*ones(5,1),ones(5,1)];

port_hs = repmat(R_wle',5,1) + repmat(R_hsle',5,1) + [0, 0, 0;...
    hs_s*tand(hs_sweep)/2, -hs_s/2, tand(hs_di)*hs_s/2;...
    (hs_s*tand(hs_sweep)/2)+hs_ct,   -hs_s/2, 0;...
    hs_cr, 0, 0;...
    0, 0, 0];

stbd_hs = port_hs.*[ones(5,1),-1*ones(5,1),ones(5,1)];

top_vs = repmat(R_wle',5,1) + repmat(R_vsle',5,1) + [0, 0, 0;...
    vs_s*tand(vs_sweep), 0, vs_s;...
    (vs_s*tand(vs_sweep))+vs_ct, 0, vs_s;...
    vs_cr, 0, 0;...
    0, 0, 0];

fuselage = [R_wle';(R_wle+R_vsle)'];

val.port_wing = SIM.parameter('Value',port_wing','Unit','m',...
    'Description','Port wing surface co-ordinates');

val.stbd_wing = SIM.parameter('Value',stbd_wing','Unit','m',...
    'Description','Starboard wing surface co-ordinates');

val.port_hs = SIM.parameter('Value',port_hs','Unit','m',...
    'Description','Port H-stab surface co-ordinates');

val.stbd_hs = SIM.parameter('Value',stbd_hs','Unit','m',...
    'Description','Starboard H-stab surface co-ordinates');

val.top_vs = SIM.parameter('Value',top_vs','Unit','m',...
    'Description','V-stab surface co-ordinates');

val.fuselage = SIM.parameter('Value',fuselage','Unit','m',...
    'Description','Fuselage line co-ordinates');

end