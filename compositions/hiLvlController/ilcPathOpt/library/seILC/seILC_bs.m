hiLvlCtrl = CTR.ilcController;
HILVLCONTROLLER = 'ilcPathOptThrTen';
PATHGEOMETRY = 'lemBoothNew';

hiLvlCtrl.numInitLaps.setValue(5,'');
hiLvlCtrl.switching.setValue(1,'');

%Set up Path Parameters
basis = [80 20];
lrn = 0.0005;
trust = 0.05*ones(1,numel(basis));
amp = 0.005*ones(1,numel(basis));
normVal = basis;
name = 'pathParams';

pathParams = CTR.ilcParamSpace(lrn,trust,amp,basis,normVal,name);

%Set up TSR
basis = 2.88*ones(1,10);
lrn = 0.0005;
trust = 0.05*ones(1,numel(basis));
amp = 0.005*ones(1,numel(basis));
normVal = 4*ones(1,numel(basis));
name = 'TSR';

tsr = CTR.ilcParamSpace(lrn,trust,amp,basis,normVal,name);

%Build full parameter space
hiLvlCtrl.addParameterSpace(pathParams);
hiLvlCtrl.addParameterSpace(tsr);
%% save file in its respective directory
saveFile = saveBuildFile('hiLvlCtrl',mfilename,'variant','HILVLCONTROLLER');
save(saveFile,'PATHGEOMETRY','-append')
