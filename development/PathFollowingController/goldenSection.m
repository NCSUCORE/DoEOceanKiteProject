function xLims = goldenSection(x0,stepSize,varargin)
% Function to implement golden section to minimize a scalar function
%
% Required Inputs
% x0       - initial guess
% stepSize - initial step size (step size may be reduced if this is too
% big)
%
% Optional Inputs
% DisplayOutput -  true/false prints output to command window
% MaxIterations - Maximum number of iterations before quitting, default =
% 1000
% FunctionConvergence - convergence criteria for function value, set to
% zero to disable, default = 0.01
% InputConvergence - convergence criteria for function input, set to zero
% to disable, default = 0.01
% StepTimeout - Max number of iterations for bounding phase step size
% reduction, default = 1000
% BoundingTimeout - Max number of iterations for bounding phase, default =
% 1000
 

% Input parsing
p = inputParser;
addRequired(p,'x0',@(x) isnumeric(x) && isscalar(x))
addRequired(p,'StepSize',@(x) isnumeric(x) && isscalar(x) && x>0)
addOptional(p,'DisplayOutput',false,@(x) islogical(x))
addOptional(p,'MaxIterations',1000,@(x) isnumeric(x) && isscalar(x) && x>0)
addOptional(p,'FunctionConvergence',0.00001,@(x) isnumeric(x) && isscalar(x) && x>=0)
addOptional(p,'InputConvergence',0.0001,@(x) isnumeric(x) && isscalar(x) && x>=0)
addOptional(p,'StepTimeout',1000,@(x) isnumeric(x) && isscalar(x))
addOptional(p,'StepSizeMultiplier',2,@(x) isnumeric(x) && isscalar(x)  && x>=1)
addOptional(p,'BoundingTimeout',1000,@(x) isnumeric(x) && isscalar(x))
addOptional(p,'FunctionHandle',@objF,@(x) isa(x,'function_handle'))
parse(p,x0,stepSize,varargin{:})

% Rename some variables to clean up code later on
fHandle  = p.Results.FunctionHandle;
stepSize = p.Results.StepSize;
x0       = p.Results.x0;

% Bounding Phase
[xl,xr] = bound(x0,stepSize,'FunctionHandle',p.Results.FunctionHandle,...
    'StepTimeout',p.Results.StepTimeout,...
    'StepSizeMultiplier',p.Results.StepSizeMultiplier,...
    'BoundingTimeout',p.Results.BoundingTimeout,...
    'FunctionHandle',p.Results.FunctionHandle);

% Begin golden section
tau = 1 - 0.38197;
initialRange = abs(xr-xl);
fl = fHandle(xl);
fr = fHandle(xr);
% Print column headers to command window for output
if p.Results.DisplayOutput
    headings = {'xl','Fl','x1','F1','x2','F2','xr','Fr','xOpt','FOpt'};
    headingString = [' '];
    for ii = 1:length(headings)
        headingString = [headingString pad(headings{ii},11)];
    end
    fprintf(['\n' headingString '\n'])
end

for ii = 1:p.Results.MaxIterations
    xTwo = (1-tau)*xl+tau*xr;
    xOne = tau*xl+(1-tau)*xr;
    fOne = fHandle(xOne);
    fTwo = fHandle(xTwo);
    fMin = min([fl fr fOne fTwo]);
    fMax = max([fl fr fOne fTwo]);
    xMin = min([xl xr xOne xTwo]);
    xMax = max([xl xr xOne xTwo]);
    if abs((fMax-fMin)/fMin)<= p.Results.FunctionConvergence || ...
            abs((xMax - xMin)/initialRange) <= p.Results.InputConvergence
        if p.Results.DisplayOutput
            fprintf('\nSolution converged.  Stopping program.\n')
        end
        break
    end
    if fOne>fTwo
        xl = xOne;
        f1 = fOne;
    else
        xr = xTwo;
        fr = fTwo;
    end
end

% xTest = linspace(-1,1,1000);
% for ii = 1:length(xTest)
%     y(ii) = fHandle(xTest(ii));
% end
% plot(xTest,y)

xLims = [xl xr];
end