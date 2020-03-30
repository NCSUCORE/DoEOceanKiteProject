% Copyright (c) 2008-2017 MonkeyProof Solutions B.V.
% Use is subject to the LGPL license.

function setup_sl_menu()

h = waitbar(0, 'Checking for open models...');

try
    % try to obtain bdroot object
    rootObj = bdroot();
catch ME %#ok<NASGU>
    % unable to call bdroot... no Simulink?
    javax.swing.JOptionPane.showMessageDialog(...
        [], ...
        '<html><div style="width: 200px;">Unable to find Simulink. Setup aborted.', ...
        'Simulink Utils', ...
        0, ... ERROR_MESSAGE
        []);
    return;
end

if isempty(rootObj)
    % no open models found: refresh customizations
    waitbar(1/2, h, 'Loading customizations...');
    bdclose all;
    sl_refresh_customizations();
else
    % open models found: request user to close them (with or without
    % saving)
    close(h);
    javax.swing.JOptionPane.showMessageDialog(...
        [], ...
        '<html><div style="width: 200px;">Open Simulink models were found. Please close all models and try again.', ...
        'Simulink Utils', ...
        2, ... WARNING_MESSAGE
        []);
    return;
end

% completed
close(h);
javax.swing.JOptionPane.showMessageDialog(...
    [], ...
    '<html><div style="width: 200px;">Simulink Utils setup completed successfully.', ...
    'Simulink Utils', ...
    1, ... INFORMATION_MESSAGE
    []);

end
