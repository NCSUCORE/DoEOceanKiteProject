function savePlot(handle,folder,name)

% If the specified folder does not exist, then create it
if ~(7==exist(folder,'dir'))
    mkdir(folder)
else
    if ~(7==exist(fullfile(folder,'png'),'dir'))
        mkdir(fullfile(folder,'png'))
    end
    if ~(7==exist(fullfile(folder,'eps'),'dir'))
        mkdir(fullfile(folder,'eps'))
    end
    if ~(7==exist(fullfile(folder,'fig'),'dir'))
        mkdir(fullfile(folder,'fig'))
    end
end

saveas(handle,fullfile(fullfile(folder,'png'),sprintf('%s.png',name)));
saveas(handle,fullfile(fullfile(folder,'eps'),sprintf('%s.eps',name)),'epsc');
saveas(handle,fullfile(fullfile(folder,'fig'),sprintf('%s.fig',name)));

end