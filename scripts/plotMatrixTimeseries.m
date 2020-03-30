function h = plotMatrixTimeseries(ts)
h.fig = figure;
if ~isempty(ts.Name)
    h.fig.Name = ts.Name;
end

sz = size(ts.Data(:,:,1));
cnt = 1;
for ii = 1:sz(1) % Loop over rows
    for jj = 1:sz(2) % Loop over columns
        subplot(sz(1),sz(2),cnt) % Create subplot
        h.plot(ii,jj) = plot(ts.Time,squeeze(ts.Data(ii,jj,:)),...
            'LineWidth',1.5,'Color','k'); % Plot the data
        xlabel('Time, [s]')
        ylabel(sprintf('(%d,%d)',ii,jj));
        cnt = cnt+1;
    end
end

end