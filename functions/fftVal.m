function y = fftVal(A,B,t)

A_0=A(1);
y=ones(numel(t),1).*A_0/2;
FREQ=2*pi/(t(end));
for k=1:numel(B)
y=y+ A(k+1)*cos((FREQ*k.*t) + B(k)*sin((FREQ)*k.*t));
end




end

