hiLvlCtrl = CTR.controller;
HILVLCONTROLLER = 'variableRadiusBasisParams';
PATHGEOMETRY = 'lemOfBooth';

hiLvlCtrl.add('GainNames',...
    {'basisParams'},...
    'GainUnits',...
    {''});

hiLvlCtrl.basisParams.setValue([.73,.6,.36,0,125],'');


%% save file in its respective directory
saveFile = saveBuildFile('hiLvlCtrl',mfilename,'variant','HILVLCONTROLLER');
save(saveFile,'PATHGEOMETRY','-append')