function g = spatialCovariance(z1,z2,covAmp,altScale)
% squared exponential kernel
g = covAmp*exp(-((z1-z2').^2)./altScale^2);
end