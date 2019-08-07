hiLvlCtrl = CTR.controller;
HILVLCONTROLLER = 'constantBasisParameters';

hiLvlCtrl.add('GainNames',...
    {'basisParams'},...
    'GainUnits',...
    {'[deg deg]'});

hiLvlCtrl.basisParams.setValue([10 10],'[deg deg]');


%% save file in its respective directory
saveBuildFile('hiLvlCtrl',mfilename,'variant','HILVLCONTROLLER');
