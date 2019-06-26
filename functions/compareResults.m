function compareResults(varargin)
close all
basePath = fullfile(fileparts(which('OCTModel.slx')),'output');


for ii = 1:length(varargin)
    files{ii} = dir(fullfile(basePath,varargin{ii},'fig','*.fig'));
end

fileNames = union({files{1}.name},{files{2}.name});

for ii = 1:length(fileNames)
    open(fullfile(basePath,varargin{1},'fig',fileNames{ii}))
    fig1 = gcf;
    fig1.Position = [1          41        1920         963];
    fig1.Units = 'pixels';
    
    open(fullfile(basePath,varargin{2},'fig',fileNames{ii}))
    fig2 = gcf;
    fig1.Units = 'pixels';
    
    fig1ax = findall(fig1,'type','axes');
    fig2ax = findall(fig2,'type','axes');
    
    set(fig1ax,'NextPlot','add')
    set(fig2ax,'NextPlot','add')
    
    for jj = 1:length(fig2ax)
        % Get all lines on this ax of fig 1
        fig1lines = findall(fig1ax(jj),'Type','line');
        % Set all the display names and styles of each line
        for kk = 1:numel(fig1lines)
            fig1lines(kk).DisplayName = varargin{1};
            fig1lines(kk).LineStyle = '-';
        end
        % Get all the lines on this ax of fig 2
        fig2lines = findall(fig2ax(jj),'Type','line');
        % Set display names and line styles, then copy to ax on fig 1
        for kk = 1:length(fig2lines)
            fig2lines(kk).DisplayName = varargin{2};
            fig2lines(kk).LineStyle = '--';
            copyobj(fig2lines(kk),fig1ax(jj))
        end
        legend(fig1ax(jj),'Interpreter','none');
    end
    close(fig2);
end



end