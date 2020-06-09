function k_CS_gain = calculate_2D_gains2(obj,nominal_alpha,nominal_beta)

% run nominal case
obj.sweepCase.alpha = nominal_alpha;
obj.sweepCase.beta = nominal_beta;
obj.sweepCase.flap = linspace(-2,2,5);
obj.sweepCase.aileron = 0;
obj.sweepCase.elevator = 0;
obj.sweepCase.rudder = 0;

k_CS_gain = NaN(5,4,3);

avlProcess(obj,'sweep','Parallel',false);
res_temp = load(obj.result_file_name);
results = res_temp.results;

C_dat = NaN(length(results{1}),5);

for ii = 1:length(results{1})
    C_dat(ii,:) = [results{1}(ii).FT.CLtot results{1}(ii).FT.CDtot results{1}(ii).FT.Cltot ...
        results{1}(ii).FT.Cmtot results{1}(ii).FT.Cntot]';
end

for jj = 1:5
    for kk = 1:3
        
        p_df = polyfit(obj.sweepCase.flap',C_dat(:,jj),2);
        k_CS_gain(jj,1,kk) = p_df(kk);
        
    end
end

%% run with deflection in aileron
obj.sweepCase.flap = 0;
obj.sweepCase.aileron = linspace(-2,2,5);
obj.sweepCase.elevator = 0;
obj.sweepCase.rudder = 0;

avlProcess(obj,'sweep','Parallel',false);
res_temp = load(obj.result_file_name);
results = res_temp.results;

C_dat = NaN(length(results{1}),5);

for ii = 1:length(results{1})
    C_dat(ii,:) = [results{1}(ii).FT.CLtot results{1}(ii).FT.CDtot results{1}(ii).FT.Cltot ...
        results{1}(ii).FT.Cmtot results{1}(ii).FT.Cntot]';
end

for jj = 1:5
    for kk = 1:3
        
        p_df = polyfit(obj.sweepCase.aileron',C_dat(:,jj),2);
        k_CS_gain(jj,2,kk) = p_df(kk);
        
    end
end

%% run with deflection in elevator
obj.sweepCase.flap = 0;
obj.sweepCase.aileron = 0;
obj.sweepCase.elevator = linspace(-2,2,5);
obj.sweepCase.rudder = 0;

avlProcess(obj,'sweep','Parallel',false);
res_temp = load(obj.result_file_name);
results = res_temp.results;

C_dat = NaN(length(results{1}),5);

for ii = 1:length(results{1})
    C_dat(ii,:) = [results{1}(ii).FT.CLtot results{1}(ii).FT.CDtot results{1}(ii).FT.Cltot ...
        results{1}(ii).FT.Cmtot results{1}(ii).FT.Cntot]';
end

for jj = 1:5
    for kk = 1:3
        
        p_df = polyfit(obj.sweepCase.elevator',C_dat(:,jj),2);
        k_CS_gain(jj,3,kk) = p_df(kk);
        
    end
end

%% run with deflection in rudder
obj.sweepCase.flap = 0;
obj.sweepCase.aileron = 0;
obj.sweepCase.elevator = 0;
obj.sweepCase.rudder = linspace(-2,2,5);

avlProcess(obj,'sweep','Parallel',false);
res_temp = load(obj.result_file_name);
results = res_temp.results;

C_dat = NaN(length(results{1}),5);

for ii = 1:length(results{1})
    C_dat(ii,:) = [results{1}(ii).FT.CLtot results{1}(ii).FT.CDtot results{1}(ii).FT.Cltot ...
        results{1}(ii).FT.Cmtot results{1}(ii).FT.Cntot]';
end

for jj = 1:5
    for kk = 1:3
        
        p_df = polyfit(obj.sweepCase.rudder',C_dat(:,jj),2);
        k_CS_gain(jj,4,kk) = p_df(kk);
        
    end
end

k_CS_gain(:,:,end) = [];


end
