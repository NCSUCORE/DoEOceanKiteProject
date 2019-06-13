function k_CS_gain = calculate_2D_gains(obj,nominal_alpha,nominal_beta,...
    deflection_flap,deflection_aileron,deflection_elevator,deflection_rudder)

% run nominal case
obj.singleCase.alpha = nominal_alpha;
obj.singleCase.beta = nominal_beta;
obj.singleCase.flap = 0;
obj.singleCase.aileron = 0;
obj.singleCase.elevator = 0;
obj.singleCase.rudder = 0;

avlProcess(obj,'single','Parallel',false);

res_temp = load(obj.result_file_name);
results = res_temp.results;

% nominal coeffs
C_nom = [results{1}.FT.CLtot results{1}.FT.CDtot results{1}.FT.Cltot ...
    results{1}.FT.Cmtot results{1}.FT.Cntot]';

%% run with 1 degree deflection in flap
obj.singleCase.alpha = 0;
obj.singleCase.beta = 0;
obj.singleCase.flap = deflection_flap;
obj.singleCase.aileron = 0;
obj.singleCase.elevator = 0;
obj.singleCase.rudder = 0;

avlProcess(obj,'single','Parallel',false);
load(obj.result_file_name);

% coefficients with chanage in flap
C_df = [results{1}.FT.CLtot results{1}.FT.CDtot results{1}.FT.Cltot ...
    results{1}.FT.Cmtot results{1}.FT.Cntot]';

% flap gain
k_flap = (C_df - C_nom)/deflection_flap;

%% run with 1 degree deflection in aileron
obj.singleCase.alpha = 0;
obj.singleCase.beta = 0;
obj.singleCase.flap = 0;
obj.singleCase.aileron = deflection_aileron;
obj.singleCase.elevator = 0;
obj.singleCase.rudder = 0;

avlProcess(obj,'single','Parallel',false);
load(obj.result_file_name);

% coefficients with chanage in flap
C_da  = [results{1}.FT.CLtot results{1}.FT.CDtot results{1}.FT.Cltot ...
    results{1}.FT.Cmtot results{1}.FT.Cntot]';

% flap gain
k_aileron = (C_da - C_nom)/deflection_aileron;

%% run with 1 degree deflection in elevator
obj.singleCase.alpha = 0;
obj.singleCase.beta = 0;
obj.singleCase.flap = 0;
obj.singleCase.aileron = 0;
obj.singleCase.elevator = deflection_elevator;
obj.singleCase.rudder = 0;

avlProcess(obj,'single','Parallel',false);
load(obj.result_file_name);

% coefficients with chanage in flap
C_de  = [results{1}.FT.CLtot results{1}.FT.CDtot results{1}.FT.Cltot ...
    results{1}.FT.Cmtot results{1}.FT.Cntot]';

% flap gain
k_elevator = (C_de - C_nom)/deflection_elevator;

%% run with 1 degree deflection in flap
obj.singleCase.alpha = 0;
obj.singleCase.beta = 0;
obj.singleCase.flap = 0;
obj.singleCase.aileron = 0;
obj.singleCase.elevator = 0;
obj.singleCase.rudder = deflection_rudder;

avlProcess(obj,'single','Parallel',false);
load(obj.result_file_name);

% coefficients with chanage in flap
C_dr = [results{1}.FT.CLtot results{1}.FT.CDtot results{1}.FT.Cltot ...
    results{1}.FT.Cmtot results{1}.FT.Cntot]';

% flap gain
k_rudder = (C_dr - C_nom)/deflection_rudder;

%% control surface gain matrix
k_CS_gain = [k_flap k_aileron k_elevator k_rudder];



end
