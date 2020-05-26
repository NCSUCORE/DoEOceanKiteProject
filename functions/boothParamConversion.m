function [a,b] = boothParamConversion(w,h)
% Function to calculate a and b based on w and h
a = w/2;
b = (1/(2*sqrt(2)))*sqrt(-w^2+sqrt((h^2*(4+h^2)*w^4))/(h^2));

end