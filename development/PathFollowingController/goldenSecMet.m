
function xLims = goldenSecMet(aB,bB,positionW)


centralAngle = @(s)(acos((positionW*[(cos(((aB.*sin(s))./(1 + ((aB/bB)^2).*(cos(s).^2)))).*cos(((((aB/bB)^2).*sin(s).*cos(s))./(1 + ((aB/bB)^2).*(cos(s).^2)))));
                   (sin(((aB.*sin(s))./(1 + ((aB/bB)^2).*(cos(s).^2)))).*cos(((((aB/bB)^2).*sin(s).*cos(s))./(1 + ((aB/bB)^2).*(cos(s).^2)))));
                      (sin(((((aB/bB)^2).*sin(s).*cos(s))./(1 + ((aB/bB)^2).*(cos(s).^2)))));])/(norm([(cos(((aB.*sin(s))./(1 + ((aB/bB)^2).*(cos(s).^2)))).*cos(((((aB/bB)^2).*sin(s).*cos(s))./(1 + ((aB/bB)^2).*(cos(s).^2)))));
                   (sin(((aB.*sin(s))./(1 + ((aB/bB)^2).*(cos(s).^2)))).*cos(((((aB/bB)^2).*sin(s).*cos(s))./(1 + ((aB/bB)^2).*(cos(s).^2)))));
                      (sin(((((aB/bB)^2).*sin(s).*cos(s))./(1 + ((aB/bB)^2).*(cos(s).^2)))));]') * norm(positionW))));

   
%s0 = 1; % Point to start searching from
%stepSize  = 1; % Size of the jump to use between guesses
%p = inputParser;

% Number of iterations before stopping attempt to tune step size
%addOptional(p,'StepTimeout',1000,@(x) isnumeric(x) && isscalar(x))
% How much to increase the step size at every iteration
%addOptional(p,'StepSizeMultiplier',2,@(x) isnumeric(x) && isscalar(x)  && x>=1)
% Number of iterations before quitting bounding phase
%addOptional(p,'BoundingTimeout',1000,@(x) isnumeric(x) && isscalar(x))
% Handle of the function that you want to minimize
%addOptional(p,'FunctionHandle',@objF,@(x) isa(x,'function_handle'))
% Initial point/guess
%addRequired(p,'x0',@(x) isnumeric(x) && isvector(x))
% Step size
%addRequired(p,'StepSize',@(x) isnumeric(x) && isscalar(x) && x>0)

%parse(p,x0,stepSize,varargin{:})

%fHandle  = p.Results.FunctionHandle;
%stepSize = p.Results.StepSize;
%x0       = p.Results.x0;
StepTimeout = 1000;
StepSizeMultiplier = 2;
BoundingTimeout = 1000;
x0 = .1;
stepSize = .1;
FunctionConvergence = .00001;
InputConvergence = .0001;
xLeft = 0;
sign1 = 0;

MaxIterations = 1000;
for tryCount = 1:StepTimeout
    if centralAngle(x0-stepSize) >= centralAngle(x0) &&...
            centralAngle(x0) >= centralAngle(x0+stepSize)
        sign1 = +1;
        break
    elseif  centralAngle(x0-stepSize) <= centralAngle(x0) &&...
            centralAngle(x0) <= centralAngle(x0+stepSize)
        sign1 = -1;
        break
    end
    stepSize = stepSize/2^tryCount;
end

xCurrent = x0;
for ii = 0:BoundingTimeout-1
    xRight = xCurrent + sign1*stepSize*StepSizeMultiplier^ii;
    if centralAngle(xRight)>centralAngle(xCurrent)
        break
    end
    xLeft = xCurrent;
    xCurrent = xRight;
end

if sign1 == -1
   xTemp  = sort([xLeft xRight]) ;
   xLeft  = xTemp(1);
   xRight= xTemp(2);
end

xl = xLeft;
xr = xRight;

% Begin golden section
tau = 1 - 0.38197;
initialRange = abs(xr-xl);
fl = centralAngle(xl);
fr = centralAngle(xr);

for ii = 1:MaxIterations
    xTwo = (1-tau)*xl+tau*xr;
    xOne = tau*xl+(1-tau)*xr;
    fOne = centralAngle(xOne);
    fTwo = centralAngle(xTwo);
    fMin = min([fl fr fOne fTwo]);
    fMax = max([fl fr fOne fTwo]);
    xMin = min([xl xr xOne xTwo]);
    xMax = max([xl xr xOne xTwo]);
  
    if fOne>fTwo
        xl = xOne;
        f1 = fOne;
    else
        xr = xTwo;
        fr = fTwo;
    end
end
    xLims = [xl xr];

end

