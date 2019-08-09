hiLvlCtrl = CTR.controller;
HILVLCONTROLLER = 'ilcPathOpt';

hiLvlCtrl.add('GainNames',...
    {...
    'pathVarLowerLim',...
    'pathVarUpperLim',...
    'numInitLaps',...
    'distPenaltyWght',...
    'initBasisParams',...
    'learningGain',...
    'forgettingFactor',...
    'trustRegion',...
    'excitationAmp',...
    'filtTimeConst'},...
    'GainUnits',...
    {...
    '',...%pathVarLowerLim no units
    '',...%pathVarUpperLim no units
    '',...%numInitLaps no units 
    'W/deg',...%distPenaltyWght 
    '[]',...%initBasisParams various units
    '[]',... %learningGain various units (basis param units) per gradient units
    '',...%forgettingFactor no units
    '[]',...%trustRegion same units as basis parameters
    '[]',...%excitationAmp same units as basis parameter
    's',...%filtTimeConst seconds
	});%

% Set the limits the trigger the update
% To trigger update, path variable must fall below lower limit, then go
% above upper limit.
hiLvlCtrl.pathVarLowerLim.Description = 'ILC trigger lower path variable limit, ILC triggers when path var falls below low lim then goes above upper lim.';
hiLvlCtrl.pathVarLowerLim.setValue(0.01,'');
hiLvlCtrl.pathVarUpperLim.Description = 'ILC trigger upper path variable limit, ILC triggers when path var falls below low lim then goes above upper lim.';
hiLvlCtrl.pathVarUpperLim.setValue(0.03,'');
% ILC doesn't start until the system completes this number of laps:
hiLvlCtrl.numInitLaps.Description = 'Number of laps before we start running ILC, in order to let transients die out.';
hiLvlCtrl.numInitLaps.setValue(5,'');
% Weighting on path tracking in the performance index:
hiLvlCtrl.distPenaltyWght.Description = 'Weight on path tracking penalty (interior angle) in the ILC performance index.';
hiLvlCtrl.distPenaltyWght.setValue(10000,'W/deg');
% Initial basis parameters
hiLvlCtrl.initBasisParams.Description = 'Initial basis parameters for the figure 8 path.';
% Learning gain in the ILC update law
hiLvlCtrl.learningGain.Description = 'Learning gain of the ILC update law.  Multiplies the gradient';
hiLvlCtrl.learningGain.setValue(1,'[]');
% Forgetting factor of RLS estimator
hiLvlCtrl.forgettingFactor.Description = 'Forgetting factor of RLS estimator in ILC update';
hiLvlCtrl.forgettingFactor.setValue(0.99,'');
% Trust region of ILC update 
hiLvlCtrl.trustRegion.Description = 'Trust region of ILC update.';
hiLvlCtrl.trustRegion.setValue([],'[]');
% Persistent excitation
hiLvlCtrl.excitationAmp.Description = 'Amplitude of persistent excitation (uniform white noise) in the ILC update.';
hiLvlCtrl.excitationAmp.setValue([],'[]');
% Output filter time constant
hiLvlCtrl.filtTimeConst.Description = 'Time constant of filter on output of ILC update.';
hiLvlCtrl.filtTimeConst.setValue(0.05,'s');


%% save file in its respective directory
saveBuildFile('hiLvlCtrl',mfilename,'variant','HILVLCONTROLLER');
