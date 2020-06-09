%% Ground station controller
% initiate controller creation
gndCtrl = CTR.controller;
% create surge, sway, and heave controller
gndCtrl.add('FPIDNames',{'surge','sway','heave'},...
    'FPIDErrorUnits',{'m','m','m'},...
    'FPIDOutputUnits',{'m/s','m/s','m/s'});
% create control allocation matrix
gndCtrl.add('GainNames',{'thrAllocationMat'},...
    'GainUnits',{'1/s'});
% create set points for each controller
gndCtrl.add('SetpointNames',{'surgeSP','swaySP','heaveSP'},...
    'SetpointUnits',{'m','m','m'});
% add output saturation
gndCtrl.add('SaturationNames',{'outputSat'});

gndCtrl.surge.kp.setValue(.05,'(m/s)/(m)');                        % proportional gain
gndCtrl.surge.kd.setValue(12*gndCtrl.surge.kp.Value,'(m/s)/(m/s)');   % derivative gain
gndCtrl.surge.tau.setValue(.1,'s');                                % time constant

gndCtrl.sway.kp.setValue(.05,'(m/s)/(m)');                         % proportional gain
gndCtrl.sway.kd.setValue(12*gndCtrl.sway.kp.Value,'(m/s)/(m/s)');     % derivative gain
gndCtrl.sway.tau.setValue(.1,'s');                                 % time constant

gndCtrl.heave.kp.setValue(.15,'(m/s)/(m)');                        % proportional gain
gndCtrl.heave.kd.setValue(12*gndCtrl.heave.kp.Value,'(m/s)/(m/s)');   % derivative gain
gndCtrl.heave.tau.setValue(.1,'s');                                % time constant

% tether control allocation matrix
% use zero vectors to turn individual controllers on and off (or set
% proportional gain to zero)
surgeVec = [0 -.5 .5]';                             % symmetric tether 2 and 3
surgeVec = surgeVec/norm(surgeVec);                 % normalize
dist = 100;
swayNum = -dist + sqrt(dist^2+1-2*dist*cosd(60));   % geometric analysis for sway
swayVec = [-1 -swayNum -swayNum]';                  % symmetric tether 1 and tethers 2&3
swayVec = swayVec/norm(swayVec);                    % normalize
% swayVec = [0 0 0]';
heaveVec = [1 1 1]';                                % all tethers move together
heaveVec = heaveVec/norm(heaveVec);                 % normalize
% heaveVec = [0 0 0]';

% create matrix using vectors above
gndCtrl.thrAllocationMat.setValue([surgeVec,swayVec,heaveVec],'1/s')

gndCtrl.outputSat.upperLimit.setValue(1,'');
gndCtrl.outputSat.lowerLimit.setValue(-1,'');


% Save the variable
save(fullfile(fileparts(which(mfilename)),strrep(mfilename,'_bs','')),'gndCtrl')
clearvars gndCtrl ans surgeVec swayNum heaveVec dist swayVec