function out = avlStallCorrectionPart_v2(obj,in)
% This function should do the stall correction that we discussed
% store batch results in variable batch_res
batch_res = in;
n_cases = length(batch_res);


w_chord = obj.wingRootChord.Value;
w_TR = obj.wingTR.Value;
w_span = 2 * obj.portWing.halfSpan.Value;
w_cl_min = obj.wingClMin.Value;
w_cl_max = obj.wingClMax.Value;

hs_chord = obj.hStab.rootChord.Value;
hs_TR = obj.hStab.TR.Value;
hs_span = 2 * obj.hStab.halfSpan.Value;
hs_cl_min = obj.hStab.ClMin.Value;
hs_cl_max = obj.hStab.ClMax.Value;

vs_chord = obj.vStab.rootChord.Value;
vs_TR = obj.vStab.TR.Value;
vs_span = obj.vStab.halfSpan.Value;
vs_cl_min = obj.vStab.ClMin.Value;
vs_cl_max = obj.vStab.ClMax.Value;

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
        
        w_cl_cat(w_aboveRange) = max(2*w_cl_max - w_cl_cat(w_aboveRange),0);
        w_cl_cat(w_belowRange) = min(2*w_cl_min - w_cl_cat(w_belowRange),0);
        
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
        
        hs_cl_cat(hs_aboveRange) = max(2*hs_cl_max - hs_cl_cat(hs_aboveRange),0);
        hs_cl_cat(hs_belowRange) = min(2*hs_cl_min - hs_cl_cat(hs_belowRange),0);
        
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
        
        vs_cl_cat(vs_aboveRange) = max(2*vs_cl_max - vs_cl_cat(vs_aboveRange),0);
        vs_cl_cat(vs_belowRange) = min(2*vs_cl_min - vs_cl_cat(vs_belowRange),0);
        
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