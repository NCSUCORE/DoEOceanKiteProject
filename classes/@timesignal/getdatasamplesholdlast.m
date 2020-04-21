% Function that returns gets a sample but holds value at the last
% known value if polled after last known value
function x = getdatasamplesholdlast(obj,indx)
x = obj.getdatasamples(min([indx,numel(obj.Time)]));
end
