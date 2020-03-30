function diffs = difftrap(timevec)
    %diffs(1) = timevec(1)/2
    %diffs(end) = timevec(end)/2
    %diffs(n) = (timevec(n-1)+timevec(n))/2
    diffvec = diff(timevec(:)');
    diffs = .5*([0 diffvec]+[diffvec 0]);
    if size(timevec,1)>size(timevec,2)
        diffs = diffs';
    end
end