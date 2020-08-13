% % User is notified automatically that this file is run
% Change anything with "Interpreter" in the name to use Latex formatting
props = get(groot, 'factory');
fnames = fieldnames(props);
fnames = fnames(contains(fnames,'interpreter','IgnoreCase',true));
for ii = 1:length(fnames)
    propName = strrep(fnames{ii},'factory','default');
    set(groot,propName,'latex')
end

% Change figure backgrounds to white
set(groot,'defaultfigurecolor','w')

if strcmpi(getenv('username'),'mcobb') % User is Mitchell
    % Change the default line style order
    set(groot,'defaultAxesLineStyleOrder','-|--|:')
    % Normalize default figure units
    set(0, 'defaultFigureUnits', 'normalized')
    % Set the default figure to full screen on the left monitor
    if strcmpi(getenv('computername'),'VERMILLIONLAB1')
        set(0, 'defaultFigurePosition', [1.0000    0.0370    1.0000    0.8917])
    end
end

% Refresh simulink customizations
sl_refresh_customizations

% Clear the variables created by this script
clearvars props fnames ii propName
format compact;
fprintf('Done\n')
