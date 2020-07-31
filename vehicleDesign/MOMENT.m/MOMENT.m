function M = MOMENT(polygon,m,n)

M = 0;
N = length(polygon.x);
x = polygon.x;
y = polygon.y;
A = 0;
for i = 1:1:N
    j = i+1;
    if i == N
        j = 1;
    end
    dx = x(j)-x(i);
    dy = y(j)-y(i);
    sum2 = 0;
    for j = 0:1:m
        sum1 = 0;
        for k = 0:1:n+1
            sum1 = sum1+nchoosek(n+1,k)*y(i)^(n+1-k)*dy^k/(k+j+1);
        end
        sum2 = sum2+nchoosek(m,j)*x(i)^(m-j)*dx^(j+1)*sum1;
    end
    di = sum2/(n+1);
    M = M+di;
    A = A+dx*(y(i)+dy/2);
end
M = M*sign(A);
end