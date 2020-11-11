function val = initializeKFGPForSquaredExponentialKernel(obj)
%INITIALIZEKFGPFORSQUAREDEXPONENTIALKERNEL calculate the KFGP initialization
% matrices A,H,Q,s0, and sigma0 for using the squared exponential kernel

% local variables
% time step
dt = obj.kfgpTimeStep;
% temporal length scale
l_t = obj.temporalLengthScale;
% total number of points in the entire domain of interest
nXD = size(obj.xMeasure,2);
% taylor series expansion order
N = 2;

% % find the transfer function as per the Hartinkainen paper
syms x
px = 0;
% % Hartinkainen paper Eqn. (11)
k = 1/(2*l_t^2);

for n = 0:N
    px = px + (factorial(N)*((-1)^n)*((4*k)^(N-n))*(x^(2*n)))/factorial(n);
end
% % find the roots of the above polynomial
rts = vpasolve(px,x);
% % locate the roots with negative real parts
negReal = rts(real(rts) < 0);
% % make transfer function out of the negative real parts roots
H_iw = vpa(expand(prod(x-negReal)));
% % find the coefficients of the polynomial
coEffs = coeffs(H_iw,x);
% break the coefficients in real and imaginary parts and
% eliminate numbers lower than eps
nRound = 8;
coEffs = removeEPS(coEffs,nRound);
% % normalize them by dividing by the highest degree
% % coefficient
coEffs = coEffs./coEffs(end);
% % form the F, G, and H matrices as per Carron Eqn. (8)
F = [zeros(N-1,1) eye(N-1); -coEffs(1:end-1)];
G = [zeros(N-1,1);1];
% % calculate the numerator
b0 = sqrt(factorial(N)*((4*k)^N)*sqrt(pi/k));
H = [b0 zeros(1,N-1)];
sigma0 = removeEPS(lyap(F,G*G'),nRound);
% % calculate the discretized values
syms tau
% % use cayley hamilton theorem to calcualte e^Ft
eFt = cayleyHamilton(F);
% % calculate Fbar using the above expression
Fbar = removeEPS(subs(eFt,tau,dt),nRound);
% % evaluate Qbar, very computationally expensive
Qsym = eFt*(G*G')*eFt';
Qint = NaN(N);
for ii = 1:N^2
    fun = matlabFunction(Qsym(ii));
    Qint(ii) = integral(fun,0,dt);
end
% % remove numbers lower than eps
Qbar = removeEPS(Qint,nRound);
% % outputs
% initialize matrices as cell matrices
Amat = cell(nXD);
Hmat = cell(nXD);
Qmat = cell(nXD);
sig0Mat = cell(nXD);

% form the block diagonal matrices
for ii = 1:nXD
    for jj = 1:nXD
        if ii == jj
            Amat{ii,jj} = Fbar;
            Hmat{ii,jj} = H;
            Qmat{ii,jj} = Qbar;
            sig0Mat{ii,jj} = sigma0;
        else
            Amat{ii,jj} = zeros(N);
            Hmat{ii,jj} = zeros(1,N);
            Qmat{ii,jj} = zeros(N);
            sig0Mat{ii,jj} = zeros(N);
        end
    end
end
% convert them to matrices and send to output structure
val.Amat = cell2mat(Amat);
val.Hmat = cell2mat(Hmat);
val.Qmat = cell2mat(Qmat);
val.sig0Mat = cell2mat(sig0Mat);
val.s0 = zeros(nXD*N,1);
end


function val = removeEPS(xx,nRound)
% eliminate numbers lower than eps
realParts = double(real(xx));
realParts(realParts <= eps) = 0;
imagParts = double(imag(xx));
imagParts(imagParts <= eps) = 0;
% round up to nRound decimal places
val = round(realParts,nRound) + 1i*round(imagParts,nRound);
end

% % % %         Cayley Hamilton theorem implementation
function eAt = cayleyHamilton(A)
% order of matrix
n = length(A);
% eigen values
eVals = eig(A);
reVals = real(eVals);
ieVals = imag(eVals);
% define t
syms tau
lhs = sym('lhs',[n,1]);
rhs = NaN(n,n);
% populate the LHS and RHS matrices
for ii = 1:n
    lhs(ii) = exp(reVals(ii)*tau)*(cos(abs(ieVals(ii))*tau) + ...
        1i*sign(ieVals(ii))*sin(abs(ieVals(ii))*tau));
    for jj = 1:n
        rhs(ii,jj) = eVals(ii)^(jj-1);
    end
end
% solve for alpha
alp = simplify(inv(rhs)*lhs(:));
eAt = zeros(n);
% calculate the e^At matrix
for ii = 1:n
    eAt = alp(ii).*A^(ii-1) + eAt;
end
% simplify the symbolic expression
eAt = vpa(simplify(eAt),4);
end

