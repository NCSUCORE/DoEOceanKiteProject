function ind = closestIndex(obj,time)
    %Gets the closest index to a given time
    [~, ind] = min(abs(obj.Time-time));
end