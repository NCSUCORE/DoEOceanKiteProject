clear all
clc

duration = 100;

bp = rand(duration,2);
time = 1:size(bp,1);

p = [1 0 1 0 1];

J = p(1)+...
    p(2)*bp(:,1)+...
    p(3)*bp(:,1).^2+...
    p(4)*bp(:,2)+...
    p(5)*bp(:,2).^2;



for ii = 1:numel(time)
   grad(ii,:) = [p(2)+2*p(3)*bp(ii,1) p(4)+2*p(5)*bp(ii,2)];
end

bp = timeseries(bp,time);
J  = timeseries(J,time);

sim('rlsGradientEst_th')


estBP.Data