function [posGround,varargout] = swapablePath(pathVariable,geomParams)
     func = @circleOnSphere;
     posGround = func(pathVariable,geomParams);
     if nargout == 2
          [~,varargout{1}] = func(pathVariable,geomParams);
     end
end