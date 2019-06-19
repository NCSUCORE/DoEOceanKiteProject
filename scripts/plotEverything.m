close all
basePath = fileparts(which('OCTModel'));
basePath = fullfile(basePath,'scripts','plotScripts','*.m');
files = dir(basePath);

for ii = 1:length(files)
    try
        % Try catch to keep moving through broken plot scripts
        eval(strrep(files(ii).name,'.m',''))
    catch 
         warning('Failed: %s',files(ii).name)
    end
end