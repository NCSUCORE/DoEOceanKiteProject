hiLvlCtrl = CTR.controller;
HILVLCONTROLLER = 'constantBasisParameters';

hiLvlCtrl.add('GainNames',...
    {'basisParams'},...
    'GainUnits',...
    {''});

hiLvlCtrl.basisParams.setValue([1 1.4 30*pi/180 0 125],'');


%% save file in its respective directory
saveBuildFile('hiLvlCtrl',mfilename,'variant','HILVLCONTROLLER');
