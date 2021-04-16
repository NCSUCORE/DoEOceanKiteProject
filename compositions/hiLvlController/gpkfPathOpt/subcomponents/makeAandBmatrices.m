function [A,b] = makeAandBmatrices(duMax,duMin,u0,nSteps)
% constraints
A = zeros(nSteps-1,nSteps);
b = [duMax*ones((nSteps-1),1);-duMin*ones((nSteps-1),1)];
% populate the A matrix such that each row gives u(i+1)-u(i)
for ii = 1:nSteps-1
    for jj = 1:nSteps
        if ii == jj
            A(ii,jj) = -1;
            A(ii,jj+1) = 1;
        end
        
    end
end
% repeate
A = [A;-A];
% bounds on first step
fsBoundsA = zeros(2,nSteps);
fsBoundsA(1,1) = 1;
fsBoundsA(2,1) = -1;
A = [fsBoundsA;A];
%
fsBoundsB(1,1) = u0 + duMax;
fsBoundsB(2,1) = -(u0 + duMin);
b = [fsBoundsB;b];
end
