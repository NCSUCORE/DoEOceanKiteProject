% clear
clear
clc

% dsgn.buildLookupTable;


% create sample design
dsgn_test = avlDesignGeometryClass;
dsgn_test.input_file_name = 'desTest1';
dsgn_test.result_file_name = 'resTest1';

% plot it
dsgn_test.plot;

% create design avl input file
dsgn_test.writeInputFile;

% operating conditions
singleCase.alpha = 0;
singleCase.beta = 0;
singleCase.flap = 0;
singleCase.aileron = 0;
singleCase.rudder = 0;

dsgn_test.singleCase = singleCase;

% run avl and generate results
dsgn_test.runCase;





% save('saveFile','dsgn')