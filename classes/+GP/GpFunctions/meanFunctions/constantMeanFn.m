function val = constantMeanFn(x,meanFnParams)

if nargin == 1 || isempty(meanFnParams)
    val = 0.*x;
else
    if length(meanFnParams) ~= 1
        error('May have enter incorrect mean function parameters');
    end
    val = 0.*x + meanFnParams(1);
end

end