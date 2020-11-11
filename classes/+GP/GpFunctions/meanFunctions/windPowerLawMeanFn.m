function val = windPowerLawMeanFn(altitude,meanFnParams)
if nargin == 1 || isempty(meanFnParams)
    val = 3.77*altitude.^0.14;
else
    if length(meanFnParams) ~= 2
        error('May have enter incorrect mean function parameters');
    end
    val = meanFnParams(1)*altitude.^meanFnParams(2);
end

end

