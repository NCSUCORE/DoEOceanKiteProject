function out = avlStallCorrectionPart(obj,in)
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

vs_chord = obj.v_stab_chord;
vs_TR = obj.v_stab_TR;
vs_span = obj.v_stab_span;
vs_cl_min = obj.v_stab_airfoil_ClLimits(1);
vs_cl_max = obj.v_stab_airfoil_ClLimits(2);

for ii = 1:n_cases
    
    Sref = batch_res(ii).FT.Sref;
    
    % wing CL
    CLtot = batch_res(ii).FT.CLtot;
    CMxtot = batch_res(ii).FT.Cltot;
    
    if isfield(batch_res(ii).ST,'Wing')
        % get right wing and left wing data and process it
        w_yle_cat = [batch_res(ii).ST.Wing.tabular.Yle; w_span/2];
        w_chord_cat = [batch_res(ii).ST.Wing.tabular.Chord; w_chord*w_TR];
        w_cl_cat = [batch_res(ii).ST.Wing.tabular.cl; 0];
        
        % compare with Cl limits and remove elemts outside of range
        w_belowRange = (w_cl_cat < w_cl_min);
        w_aboveRange = (w_cl_cat > w_cl_max);
        
        iRemove = or(w_belowRange,w_aboveRange);
        w_cl_cat(iRemove) = 0;
        
        % calculate chord*Cl and CLtot
        w_cCl = w_chord_cat.*w_cl_cat;
        w_CL = trapz(w_yle_cat,w_cCl)/Sref;
        
        
        CL = w_CL;
        
    elseif isfield(batch_res(ii).ST,'H_stab')
        
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
        
        
        CL = hs_CL;
        
    elseif isfield(batch_res(ii).ST,'V_stab')
        % get right HS and left HS data and process it
        vs_yle_cat = [batch_res(ii).ST.V_stab.tabular.Yle; vs_span];
        vs_chord_cat = [batch_res(ii).ST.V_stab.tabular.Chord; vs_chord*vs_TR];
        vs_cl_cat = [batch_res(ii).ST.V_stab.tabular.cl; 0];
        
        % compare with Cl limits and remove elemts outside of range
        vs_belowRange = (vs_cl_cat < vs_cl_min);
        vs_aboveRange = (vs_cl_cat > vs_cl_max);
        
        iRemove = or(vs_belowRange,vs_aboveRange);
        vs_cl_cat(iRemove) = 0;
        
        % calculate chord*Cl and CLtot
        vs_cCl = vs_chord_cat.*vs_cl_cat;
        vs_CL = trapz(vs_yle_cat,vs_cCl)/Sref;
        
        CL = vs_CL;
    else
        error('The wing, HStab, and Vstab fields do not exist in the batch results')
        
    end
    
    
    % overwrite lookup table CL value
    batch_res(ii).FT.CLtot = CL;
    
    
end

out = batch_res;


end