clear
clc
saveFile = 'testLookupTableResults';
inputFileName = 'test_ip_func.avl';
resultsFileName = 'res_ft';

alphas      = [-5 5];
betas       = [-5 5];
flaps       = [-1 1];
ailerons    = [-1 1];
elevators   = [-1 1];
rudders     = [-1 1];

tic
avlBuildLookupTable(saveFile,inputFileName,resultsFileName,...
    alphas,betas,flaps,ailerons,elevators,rudders)
toc