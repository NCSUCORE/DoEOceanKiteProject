function y = Fseriesval2(a,b,x)
% FSERIESVAL Evaluates real Fourier series approximation at given data values
%
% Y = FSERIESVAL(A,B,X) the Fourier expansion of the form
%    y = A_0/2 + Sum_k[ A_k cos(kx) + B_k sin(kx) ]
% at the data values in the vector X.
%
% Y = FSERIESVAL(A,B,X,RESCALING) scales the X data to lie in the interval
% [-pi,pi] if RESCALING is TRUE (default).  If RESCALING is FALSE, no
% rescaling of X is performed.
%
% See also: Fseries


% make design matrix
 n = length(b);
nx = x*(1:n);
F = [0.5*ones(size(x)),cos(nx),sin(nx)];

% evaluate fit
y = F*[a;b];



end




