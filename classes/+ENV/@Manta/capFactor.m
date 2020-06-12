function capFactor(obj,vRated)
data = obj.flowVecTimeseries.Value.Data;
vFlow = sqrt(sum(data.^2,4)); % Calculate flow speed from velocity vector
for ii = 1:size(vFlow,1)
    for jj = 1:size(vFlow,2)
        for kk = 2:size(vFlow,3)
            cnts = histcounts(vFlow(ii,jj,kk,1,:))
        end
    end
end
end

