hiLvlCtrl = CTR.controller;
HILVLCONTROLLER = 'ilcPathOpt';
PATHGEOMETRY = 'lemOfBooth';

hiLvlCtrl.add('GainNames',...
    {...
    'pathVarLowerLim',...
    'pathVarUpperLim',...
    'numInitLaps',...
    'penaltyWeight',...
    'initBasisParams',...
    'learningGain',...
    'forgettingFactor',...
    'trustRegion',...
    'excitationAmp',...
    'filtTimeConst',...
    'optEnable',...
    },...
    'GainUnits',...
    {...
    '',...%pathVarLowerLim no units
    '',...%pathVarUpperLim no units
    '',...%numInitLaps no units 
    '',...%distPenaltyWght 
    '[]',...%initBasisParams various units
    '[]',... %learningGain various units (basis param units) per gradient units
    '',...%forgettingFactor no units
    '[]',...%trustRegion same units as basis parameters
    '[]',...%excitationAmp same units as basis parameter
    's',...%filtTimeConst seconds
	'[]',...%boolean vector describing which basis parameters to optimize
    });%

% Set the limits the trigger the update
% To trigger update, path variable must fall below lower limit, then go
% above upper limit.
hiLvlCtrl.pathVarLowerLim.Description = 'ILC trigger lower path variable limit, ILC triggers when path var falls below low lim then goes above upper lim.';
hiLvlCtrl.pathVarLowerLim.setValue(0.05,'');
hiLvlCtrl.pathVarUpperLim.Description = 'ILC trigger upper path variable limit, ILC triggers when path var falls below low lim then goes above upper lim.';
hiLvlCtrl.pathVarUpperLim.setValue(0.95,'');
% ILC doesn't start until the system completes this number of laps:
hiLvlCtrl.numInitLaps.Description = 'Number of laps before we start running ILC, in order to let transients die out.';
hiLvlCtrl.numInitLaps.setValue(5,'');
% Weighting on path tracking in the performance index:
hiLvlCtrl.penaltyWeight.setValue(750/0.0175,'');% Use this one for variable flow -MC 10/11
% Initial basis parameters
hiLvlCtrl.initBasisParams.Description = 'Initial basis parameters for the figure 8 path.';
% Learning gain in the ILC update law
hiLvlCtrl.learningGain.Description = 'Learning gain of the ILC update law.  Multiplies the gradient';
hiLvlCtrl.learningGain.setValue(2*0.2/1.9e4,'[]');
% Forgetting factor of RLS estimator
hiLvlCtrl.forgettingFactor.Description = 'Forgetting factor of RLS estimator in ILC update';
hiLvlCtrl.forgettingFactor.setValue(0.9,'');
% Trust region of ILC update 
hiLvlCtrl.trustRegion.Description = 'Trust region of ILC update.';
hiLvlCtrl.trustRegion.setValue([0.03 0.03 inf inf inf],'[]');
% Persistent excitation
hiLvlCtrl.excitationAmp.Description = 'Amplitude of persistent excitation (uniform white noise) in the ILC update.';
hiLvlCtrl.excitationAmp.setValue([0 0 0 0 0 0 0],'[]');
% Output filter time constant
hiLvlCtrl.filtTimeConst.Description = 'Time constant of filter on output of ILC update.';
hiLvlCtrl.filtTimeConst.setValue(0.05,'s');
% Optimization enable
hiLvlCtrl.optEnable.setValue([1 1 0 0 0 ],'[]');


%% save file in its respective directory
saveFile = saveBuildFile('hiLvlCtrl',mfilename,'variant','HILVLCONTROLLER');
save(saveFile,'PATHGEOMETRY','-append')
