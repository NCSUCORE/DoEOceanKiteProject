function [xLeft,xRight] = bound(x0, stepSize,varargin)

p = inputParser;

% Number of iterations before stopping attempt to tune step size
addOptional(p,'StepTimeout',1000,@(x) isnumeric(x) && isscalar(x))
% How much to increase the step size at every iteration
addOptional(p,'StepSizeMultiplier',2,@(x) isnumeric(x) && isscalar(x)  && x>=1)
% Number of iterations before quitting bounding phase
addOptional(p,'BoundingTimeout',1000,@(x) isnumeric(x) && isscalar(x))
% Handle of the function that you want to minimize
addOptional(p,'FunctionHandle',@objF,@(x) isa(x,'function_handle'))
% Initial point/guess
addRequired(p,'x0',@(x) isnumeric(x) && isvector(x))
% Step size
addRequired(p,'StepSize',@(x) isnumeric(x) && isscalar(x) && x>0)

parse(p,x0,stepSize,varargin{:})

fHandle  = p.Results.FunctionHandle;
stepSize = p.Results.StepSize;
x0       = p.Results.x0;

for tryCount = 1:p.Results.StepTimeout
    if fHandle(x0-stepSize) >= fHandle(x0) &&...
            fHandle(x0) >= fHandle(x0+stepSize)
        sign = +1;
        break
    elseif  fHandle(x0-stepSize) <= fHandle(x0) &&...
            fHandle(x0) <= fHandle(x0+stepSize)
        sign = -1;
        break
    end
    stepSize = stepSize/2^tryCount;
end

xCurrent = x0;
for ii = 0:p.Results.BoundingTimeout-1
    xRight = xCurrent + sign*stepSize*p.Results.StepSizeMultiplier^ii;
    if fHandle(xRight)>fHandle(xCurrent)
        break
    end
    xLeft = xCurrent;
    xCurrent = xRight;
end

if sign == -1
   xTemp  = sort([xLeft xRight]) ;
   xLeft  = xTemp(1);
   xRight = xTemp(2);
end

end