function k = kernelF(x1,x2,h)


%inputting flowspeed as a function of depth and time

%x1 is the old data
%x2 is the new data
%h is the hyper parameters

x1 = x1(:)';
x2 = x2(:)';
% lambda = [h(2),0;0,h(3)];
% 
% 
% k = h(1)*exp(-((x1-x2)*.5*(lambda^-2)*(x1-x2)'));
 
k = h(1)* exp( -.5*( ((x1-x2)^2) / (h(2)^2) ));


end

