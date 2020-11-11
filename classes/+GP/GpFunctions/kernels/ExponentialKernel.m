function val = ExponentialKernel(p1,p2,hyperParams)
%EXPONENTIALKERNEL Calculate covariance using exponential kernel
%   Inputs :
%       p1 - point 1
%       p2 - point 2
%       hyperParams - hyper parameters,
%       hyperParams(1) = covariance amplitude
%       hyperParams(2:end) = length Scales

val = hyperParams(1)*exp(-sum(abs(p1(:)-p2(:))./hyperParams(2:end)));

end

