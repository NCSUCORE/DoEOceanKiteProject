function plotMags(obj,varargin)
%PLOTMAGS F
mags   = squeeze(sqrt(sum(obj.flowVecTSeries.Value.Data.^2,1)));
mags(mags>5) = 5;
times = repmat(obj.flowVecTSeries.Value.Time(:),[1 numel(obj.depths.Value)]);
depths = repmat(obj.depths.Value(:)',[numel(obj.flowVecTSeries.Value.Time) 1]);
h.surf = contourf(times,depths,mags',[0:1:5]);
xlabel('Time [s]')
ylabel('Dist from sea floor [m]')
h.colorbar = colorbar;
h.colorbar.Label.String = 'Flow speed [m/s]';
h.colorbar.FontSize = 18;
set(gca,'FontSize',18)
end

