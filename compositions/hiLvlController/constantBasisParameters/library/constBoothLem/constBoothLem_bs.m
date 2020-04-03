hiLvlCtrl = CTR.controller;
HILVLCONTROLLER = 'constantBasisParameters';
PATHGEOMETRY = 'lemOfBooth';

hiLvlCtrl.add('GainNames',...
    {'basisParams'},...
    'GainUnits',...
    {'[rad rad rad rad m]'});

hiLvlCtrl.basisParams.setValue([.73,.6,.36,0,125],'[rad rad rad rad m]');


%% save file in its respective directory
saveFile = saveBuildFile('hiLvlCtrl',mfilename,'variant','HILVLCONTROLLER');
 save(saveFile,'PATHGEOMETRY','-append')