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

% get screen size and adjust figure locations based on that
ss = get(0,'ScreenSize');
ss = [ss(3) ss(4)];
fig_wid = 560;
fig_hgt = 420;
max_horz = floor(ss(1)/fig_wid);
max_vert = floor(ss(2)/fig_hgt);
locs = zeros(max_horz*max_vert,4);
kk = 1;
for jj = 1:max_vert
    for ii = 1:max_horz
        locs(kk,:) = [(ii-1)*fig_wid  ss(2)-(1.2*fig_hgt*jj) fig_wid fig_hgt ];
        kk = kk+1;
    end
end
locs = repmat(locs,5,1);

fn = 1;
