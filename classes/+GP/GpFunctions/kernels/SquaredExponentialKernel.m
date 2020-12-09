function val = SquaredExponentialKernel(p1,p2,hyperParams)
%SQUAREDEXPONENTIALKERNEL Calculate covariance using squared exponential kernel
%   Inputs :
%       p1 - point 1
%       p2 - point 2
%       hyperParams - hyper parameters,
%       hyperParams(1) = covariance amplitude
%       hyperParams(2:end) = length Scales

val = hyperParams(1)*exp(-0.5*sum((p1(:)-p2(:)).^2./hyperParams(2:end).^2));

end

