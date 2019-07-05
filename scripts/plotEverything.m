close all
basePath = fileparts(which('OCTModel'));
basePath = fullfile(basePath,'scripts','plotScripts','*.m');
files = dir(basePath);

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

for ii = 1:length(files)
    try
        % Try catch to keep moving through broken plot scripts
        eval(strrep(files(ii).name,'.m',''))
    catch 
         warning('Failed: %s',files(ii).name)
         close
    end
end

linkAllTimeAxes