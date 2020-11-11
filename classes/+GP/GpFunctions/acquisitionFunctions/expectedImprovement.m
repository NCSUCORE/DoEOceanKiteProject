function val = expectedImprovement(predMean,postVar,other)
% local variable
fBest = other.fBest;
% calculate standard deviation
stdDev = postVar.^0.5;
% make standard normal distribution
stdNormDis = gmdistribution(0,1);
% calculate z
Z(stdDev>0,1) = (predMean(stdDev>0) - fBest)./stdDev(stdDev>0);
Z(stdDev<=0,1) = 0;
% calculate expected improvement
val = (predMean - fBest).*cdf(stdNormDis,Z) + stdDev.*pdf(stdNormDis,Z);
val(stdDev<=0) = 0;

end