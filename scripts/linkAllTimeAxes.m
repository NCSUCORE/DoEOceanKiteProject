% Function to link time axes together across all open figures
figHandles = findobj('Type', 'figure');
axList = [];
for ii = 1:length(figHandles)
    h = findall(figHandles(ii),'Type','axes');
    for jj = 1:numel(h)
        if contains(h(jj).XLabel.String,'time','IgnoreCase',true)
            axList = [axList h(jj)];
        end
    end
end
if ~isempty(axList)
    linkaxes(axList,'x');
end
clearvars figHandles axList ii jj h