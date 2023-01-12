hiLvlCtrl = CTR.ilcController;
HILVLCONTROLLER = 'ilcPathOptThrTen';
PATHGEOMETRY = 'lemBoothNew';

hiLvlCtrl.numInitLaps.setValue(5,'');
hiLvlCtrl.switching.setValue(1,'');
hiLvlCtrl.forgettingFactor.setValue(.995,'')

pathLrn = 0.0005;
pathTrust = 0.1;
persist = 0.01;

% Set up Path Parameters
width = 80;
lrn = pathLrn;
trust = pathTrust;
amp = persist;
upperLim = 1.2*width;
lowerLim = 30;
name = 'width';
width = CTR.ilcParamSpace(lrn,trust,amp,width,upperLim,lowerLim,name);

% Set up Path Parameters
height = 20;
lrn = pathLrn;
trust = pathTrust;
amp = persist;
upperLim = 1.2*height;
lowerLim = 5;
name = 'height';
height = CTR.ilcParamSpace(lrn,trust,amp,height,upperLim,lowerLim,name);

% Set up Path Parameters
path = [80 20];
lrn = pathLrn;
trust = pathTrust;
amp = persist;
upperLim = 1.2*path;
lowerLim = [30 5];
name = 'width';
path = CTR.ilcParamSpace(lrn,trust,amp,path,upperLim,lowerLim,name);

%Set up TSR
basis = 2.88*ones(1,10);
lrn = pathLrn;
trust = pathTrust*ones(1,numel(basis));
amp = persist*ones(1,numel(basis));
upperLim = 4*ones(1,numel(basis));
lowerLim = 0*ones(1,numel(basis));
name = 'TSR';

tsr = CTR.ilcParamSpace(lrn,trust,amp,basis,upperLim,lowerLim,name);

% basis = 15*ones(1,10);
% lrn = .05;
% trust = 0.1*ones(1,numel(basis));
% amp = persist*ones(1,numel(basis));
% upperLim = 18*ones(1,numel(basis));
% lowerLim = 12*ones(1,numel(basis));
% name = 'AoA';
% 
% aoa = CTR.ilcParamSpace(lrn,trust,amp,basis,upperLim,lowerLim,name);

% % Build full parameter space
% hiLvlCtrl.addParameterSpace(width);
% hiLvlCtrl.addParameterSpace(height);
% hiLvlCtrl.addParameterSpace(path);
hiLvlCtrl.addParameterSpace(tsr);
% hiLvlCtrl.addParameterSpace(aoa);
%% save file in its respective directory
saveFile = saveBuildFile('hiLvlCtrl',mfilename,'variant','HILVLCONTROLLER');
save(saveFile,'PATHGEOMETRY','-append')
