function vectorPlotter(time,data,plotProperties,...
    legends,yAxisLabel,figTitle)

pp = plotProperties;

if strcmp(pp{1},'blk')
    colors = 1/255*zeros(8,3);
    
else
    colors = 1/255*[228,26,28
        55,126,184
        77,175,74
        152,78,163
        255,127,0
        255,255,51];
end

lwd = 1;

sdata = squeeze(data);
sz = size(sdata);

if any(sz==1)
    sz(1) = 1;
    sdata = reshape(sdata,1,[]);
end

for ii = 1:sz(1)
    subplot(sz(1),1,ii)
    plot(time,sdata(ii,:),pp{2},'linewidth',lwd,'color',colors(ii,:),...
        'DisplayName',legends{ii})
    if ii == 1
        subplot(sz(1),1,1)
        title(figTitle);
    end
    hold on
    grid on
    xlabel('Time (s)');
    ylabel(yAxisLabel);
    legend('off')
    legend('show')
    
end

linkaxes(findall(gcf,'Type','axes'),'x')


end

