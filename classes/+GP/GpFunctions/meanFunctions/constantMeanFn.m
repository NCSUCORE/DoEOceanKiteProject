function val = constantMeanFn(x,meanFnParams)

if nargin == 1 || isempty(meanFnParams)
    val = zeros(1,size(x,2));
else
    if length(meanFnParams) ~= 1
        error('May have enter incorrect mean function parameters');
    end
    val = zeros(1,size(x,2)) + meanFnParams(1);
end

end