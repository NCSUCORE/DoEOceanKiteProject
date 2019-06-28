function out = avlStallCorrectionPart(obj,in)
% This function should do the stall correction that we discussed
% store batch results in variable batch_res
batch_res = in;
n_cases = length(batch_res);


w_chord = obj.rootChord.Value;
w_TR = obj.taperRatio.Value;
w_span = obj.span.Value;
w_cl_min = obj.ClMin.Value;
w_cl_max = obj.ClMax.Value;

for ii = 1:n_cases
    
    Sref = batch_res(ii).FT.Sref;
    
    
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
    
    % overwrite lookup table CL value
    batch_res(ii).FT.CLtot = CL;
    
    
end

out = batch_res;


end