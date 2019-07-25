% Notify the user
fprintf('\nOpening project, running OCTProject_init.m\n')
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
    set(0, 'defaultFigurePosition', [0    0.0370    1.0000    0.8917])
end

% Refresh simulink customizations
% sl_refresh_customizations

clearvars
fprintf('Done\n')
