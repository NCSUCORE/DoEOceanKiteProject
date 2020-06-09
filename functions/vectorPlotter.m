function vectorPlotter(time,data,varargin)

% rearrange the array to be a nPlots x nSamples matrix
sz = size(squeeze(data));
nS = numel(time);
nPlots = sz(sz~=nS);
data = reshape(squeeze(data),nPlots,sz(sz==nS));

% parse input
p = inputParser;
addRequired(p,'time', @(x) isnumeric(x));
addRequired(p,'data', @(x) isnumeric(x));
addParameter(p,'lineSpec','-', @(x) ischar(x));
addParameter(p,'lineWidth',1, @(x) isnumeric(x));
addParameter(p,'ColorScheme','rgb', @(x) ischar(x));
addParameter(p,'legends',repmat({''},nPlots,1), @(x) iscell(x));
addParameter(p,'xlabel','Time', @(x) ischar(x));
addParameter(p,'xUnits','(s)', @(x) ischar(x));
addParameter(p,'ylabels',repmat({''},nPlots,1), @(x) iscell(x));
addParameter(p,'yUnits','', @(x) ischar(x));
addParameter(p,'figureTitle','', @(x) ischar(x));

parse(p,time,data,varargin{:});

% set line color scheme
switch p.Results.ColorScheme
    case 'blk'
        colors = 1/255*zeros(8,3);
    case 'rgb'
        colors = 1/255*[228,26,28
            55,126,184
            77,175,74
            152,78,163
            255,127,0
            255,255,51];
    case 'red'
        colors = repmat(1/255*[228,26,28],8,1);
    case 'blue'
        colors = repmat(1/255*[55,126,184],8,1);
    otherwise
        warning('Undefined line color scheme, using RGB');
        colors = 1/255*[228,26,28
            55,126,184
            77,175,74
            152,78,163
            255,127,0
            255,255,51];
end

% make the plots
for ii = 1:nPlots
    
    subplot(nPlots,1,ii)
    
    if ~any(ismember(p.UsingDefaults,'legends'))
        plot(time,data(ii,:),p.Results.lineSpec,...
            'linewidth',p.Results.lineWidth,...
            'color',colors(ii,:),...
            'DisplayName',p.Results.legends{ii});
    else
        plot(time,data(ii,:),p.Results.lineSpec,...
            'linewidth',p.Results.lineWidth,...
            'color',colors(ii,:));
    end
    
    if ii == 1
        subplot(nPlots,1,1)
        title(p.Results.figureTitle);
    end
    hold on
    grid on
    xlabel([p.Results.xlabel,' ',p.Results.xUnits]);
    ylabel([p.Results.ylabels{ii},' ',p.Results.yUnits]);
    legend('off')
    legend('show')
    
end

% link x axes
linkaxes(findall(gcf,'Type','axes'),'x')

end

