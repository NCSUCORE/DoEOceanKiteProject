% clear
clear
clc
close all

% create sample design
dsgn_test = avlDesignGeometryClass;
dsgn_test.input_file_name = 'desTest1';
dsgn_test.result_file_name = 'resTest1';

% plot it
% dsgn_test.plot;

% create design avl input file
dsgn_test.writeInputFile;

t_alp = -15:1:15;

for ii = 1:length(t_alp)

% operating conditions
singleCase.alpha = t_alp(ii);
singleCase.beta = 0;
singleCase.flap = 0;
singleCase.aileron = 0;
singleCase.elevator = 0;
singleCase.rudder = 0;

dsgn_test.singleCase = singleCase;

% run avl and generate results
dsgn_test.runCase;

results = avlLoadResults(dsgn_test.result_file_name);


CL(ii) = results.CLtot;
CD(ii) = results.CDtot;

end


