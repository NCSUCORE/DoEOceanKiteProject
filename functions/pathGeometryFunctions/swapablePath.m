function [posGround,varargout] = swapablePath(pathVariable,geomParams)
%I hate that this is what I came up with, but it should work so...ugh.
    func =  @circleOnSphere;
    posGround = func(pathVariable,geomParams);
    if nargout == 2
        [~,varargout{1}] = func(pathVariable,geomParams);
    end
        
end