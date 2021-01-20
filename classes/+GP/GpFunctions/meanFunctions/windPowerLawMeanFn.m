function val = windPowerLawMeanFn(altitude,a,b)
if nargin == 1
%     val = 3.77*altitude.^0.14;
    val = 3.77*altitude.^0.14;
else
    val = a*altitude.^b;
end
end

