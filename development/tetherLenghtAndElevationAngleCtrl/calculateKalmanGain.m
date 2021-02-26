function Lk = calculateKalmanGain(C,sigKp1_K,R)
% kalman gain as per Carron eqn. 6e
Lk = sigKp1_K*C'/(C*sigKp1_K*C' + R);
end