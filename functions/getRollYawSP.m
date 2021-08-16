function [pathN,rollSP,yawSP,n1] = getRollYawSP(s,roll,yaw,en,rollP,yawP,n0)

N = numel(rollP);
S = linspace(0,1,N);

if s >= S(n0)
    n1 = n0+1;
else 
    n1 = n0;
end
pathN = zeros(N,1);
rollSP = zeros(N,1);
yawSP = zeros(N,1);

if en == 1
    pathN = S;
    rollSP = rollP;
    yawSP = yawP;
else
    for i = 2:N
        pathN(i) = S(i-1);
        rollSP(i) = rollP(i-1);
        yawSP(i) = yawP(i-1);
    end
    pathN(1) = s;
    rollSP(1) = roll;
    yawSP(i) = yaw;
end