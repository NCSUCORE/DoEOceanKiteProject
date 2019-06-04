function yk = tustins_integration(x_axis,y_axis)

y = y_axis;
t = x_axis;
n = length(x_axis);

dyk = zeros(n,1);
yk = zeros(n,1);

for i = 2:n
    
    dyk(i) = (1/2)*(t(i) - t(i-1))*(y(i) + y(i-1));
    yk(i) = yk(i-1) + dyk(i);
    
end

yk = yk(end);

end

