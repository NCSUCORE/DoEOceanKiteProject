function val = initializeKFGPForExponentialKernel(obj)
% INITIALIZEKFGPFOREXPONENTIALKERNEL calculate the KFGP initialization
% matrices A,H,Q,s0, and sigma0 for using the exponential kernel

% local variables
% time step
dt = obj.kfgpTimeStep;
% temporal length scale
l_t = obj.temporalLengthScale;
% total number of points in the entire domain of interest
nXD = size(obj.xMeasure,2);

% % calculate F,H,Q as per Carron Eqn. (14)
F = exp(-dt/l_t);
H = sqrt(2/l_t);
G = 1;
Q = (1 - exp(-2*dt/l_t))/(2/l_t);
% % solve the Lyapunov equation for X
sigma0 = lyap(F,G*G');
% % outputs
val.Amat    = eye(nXD)*F;
val.Hmat    = eye(nXD)*H;
val.Qmat    = eye(nXD)*Q;
val.sig0Mat = eye(nXD)*sigma0;
val.s0      = zeros(nXD,1);

end

