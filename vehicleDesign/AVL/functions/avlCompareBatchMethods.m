close all;clear;clc
% create sample design
dsgn_test = avlDesignGeometryClass;
dsgn_test.input_file_name        = 'dsgn1.avl'; % File name for .avl file
dsgn_test.run_file_name          = 'dsgn1.run';
dsgn_test.design_name            = 'dsgn1Name'; % String at top of input file defining the name
dsgn_test.result_file_name       = 'dsgn1Results';
dsgn_test.lookup_table_file_name = 'dsgn1Lookup';
dsgn_test.exe_file_name          = 'dsgn1Exe';


dsgn_test.writeInputFile

% alphas = [-10];
% 
% for ii = 1:length(alphas)
%     alpha = alphas(ii);
%     beta = 0;
%     flap = 0;
%     aileron = 0;
%     elevator = 0;
%     rudder = 0;
%     avlCreateRunFile(dsgn_test,alpha,beta,flap,aileron,elevator,rudder,...
%         'WriteMode','a','RunCaseNum',ii)
% end
% tic
% avlRunCase(dsgn_test)
% toc

alphas = -10:10:10;

for ii = 1:length(alphas)
    alpha = alphas(ii);
    beta = 0;
    flap = 0;
    aileron = 0;
    elevator = 0;
    rudder = 0;
    avlCreateRunFile(dsgn_test,alpha,beta,flap,aileron,elevator,rudder,...
        'WriteMode','a','RunCaseNum',ii)
end
tic
avlRunCase(dsgn_test)
toc
