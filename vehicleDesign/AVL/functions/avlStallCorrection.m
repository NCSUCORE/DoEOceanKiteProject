function out = avlStallCorrection(obj,in)
% This function should do the stall correction that we discussed
% store batch results in variable batch_res
batch_res = in;
n_cases = length(batch_res);


w_chord = obj.wing_chord;
w_TR = obj.wing_TR;
w_span = obj.wing_span;
w_cl_min = obj.wing_airfoil_ClLimits(1);
w_cl_max = obj.wing_airfoil_ClLimits(2);


hs_chord = obj.h_stab_chord;
hs_TR = obj.h_stab_TR;
hs_span = obj.h_stab_span;
hs_cl_min = obj.h_stab_airfoil_ClLimits(1);
hs_cl_max = obj.h_stab_airfoil_ClLimits(2);


for ii = 1:n_cases
    
    Sref = batch_res(ii).FT.Sref;
    
    % wing CL
    CLtot = batch_res(ii).FT.CLtot;
    
    % get right wing and left wing data and process it
    right_w_yle = [batch_res(ii).ST.Wing.tabular.Yle; w_span/2];
    right_w_chord = [batch_res(ii).ST.Wing.tabular.Chord; w_chord*w_TR];
    right_w_cl = [batch_res(ii).ST.Wing.tabular.cl; 0];
    
    left_w_yle = [-w_span/2; flipud(batch_res(ii).ST.WingYDUP.tabular.Yle)];
    left_w_chord = [w_chord*w_TR; flipud(batch_res(ii).ST.WingYDUP.tabular.Chord)];
    left_w_cl = [0; flipud(batch_res(ii).ST.WingYDUP.tabular.cl)];
    
    % concatenate
    w_yle_cat = [left_w_yle; right_w_yle];
    w_chord_cat = [left_w_chord; right_w_chord];
    w_cl_cat = [left_w_cl; right_w_cl];
    
    % compare with Cl limits and remove elemts outside of range
    w_belowRange = (w_cl_cat < w_cl_min);
    w_aboveRange = (w_cl_cat > w_cl_max);
    
    iRemove = or(w_belowRange,w_aboveRange);
    w_cl_cat(iRemove) = 0;
    
    % calculate chord*Cl and CLtot
    w_cCl = w_chord_cat.*w_cl_cat;
    w_CL = trapz(w_yle_cat,w_cCl)/Sref;
    
    % get right HS and left HS data and process it
    right_hs_yle = [batch_res(ii).ST.H_stab.tabular.Yle; hs_span/2];
    right_hs_chord = [batch_res(ii).ST.H_stab.tabular.Chord; hs_chord*hs_TR];
    right_hs_cl = [batch_res(ii).ST.H_stab.tabular.cl; 0];
    
    left_hs_yle = [-hs_span/2; flipud(batch_res(ii).ST.H_stabYDUP.tabular.Yle)];
    left_hs_chord = [hs_chord*hs_TR; flipud(batch_res(ii).ST.H_stabYDUP.tabular.Chord)];
    left_hs_cl = [0; flipud(batch_res(ii).ST.H_stabYDUP.tabular.cl)];
    
    % concatenate
    hs_yle_cat = [left_hs_yle; right_hs_yle];
    hs_chord_cat = [left_hs_chord; right_hs_chord];
    hs_cl_cat = [left_hs_cl; right_hs_cl];
    
    % compare with Cl limits and remove elemts outside of range
    hs_belowRange = (hs_cl_cat < hs_cl_min);
    hs_aboveRange = (hs_cl_cat > hs_cl_max);
    
    iRemove = or(hs_belowRange,hs_aboveRange);
    hs_cl_cat(iRemove) = 0;
    
    % calculate chord*Cl and CLtot
    hs_cCl = hs_chord_cat.*hs_cl_cat;

    hs_CL = trapz(hs_yle_cat,hs_cCl)/Sref;
    
    % total lift
    CL = w_CL + hs_CL;
    
    % overwrite lookup table CL value
    batch_res(ii).FT.CLtot = CL;
    
    % keyboard
    
    
end

out = batch_res;


end