hiLvlCtrl = CTR.controller;
HILVLCONTROLLER = 'constantBasisParameters';

hiLvlCtrl.add('GainNames',...
    {'basisParams'},...
    'GainUnits',...
    {''});

hiLvlCtrl.basisParams.setValue([.73,.6,.36,0,125],'');


%% save file in its respective directory
saveBuildFile('hiLvlCtrl',mfilename,'variant','HILVLCONTROLLER');
