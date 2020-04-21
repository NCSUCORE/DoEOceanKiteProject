function x = getdatasamplesholdlast(obj,indx)
%% Returns same as getdatasample but holds last known point
x = obj.getdatasamples(min([indx,numel(obj.Time)]));
end
