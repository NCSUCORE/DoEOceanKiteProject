clear
clc
saveFile = 'testLookupTableResults';
inputFileName = 'test';
resultsFileName = 'res_ft';

alphas = [-20 20];
betas = [-20 20];
flaps = [-10 10];
ailerons = [-10 10];
elevators = [-10 10];
rudders = [-10 10];

tic
buildAVLLookupTable(saveFile,inputFileName,resultsFileName,...
    alphas,betas,flaps,ailerons,elevators,rudders)
toc