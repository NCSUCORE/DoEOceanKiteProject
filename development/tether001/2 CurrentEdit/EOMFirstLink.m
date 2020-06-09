
clc
clear

syms Theta(t) Psi(t) t
syms Fx Fy Fz
syms la lad ladd
syms wxd wyd wzd
syms ma mad

syms theta psi theta_dot psi_dot
A = [Theta Psi diff(Theta(t),t) diff(Psi(t),t) ];
B = [theta psi theta_dot        psi_dot        ];

Ry = [cos(Theta(t)),0,-sin(Theta(t));...
      0            ,1,0             ;...
      sin(Theta(t)),0,cos(Theta(t)) ];
  
Rz = [cos(Psi(t)) ,sin(Psi(t)),0;...
      -sin(Psi(t)),cos(Psi(t)),0;...
      0           ,0          ,1];

A_c_O = simplify(Ry*Rz);
O_c_A = transpose(A_c_O); 
O_cd_A = diff(O_c_A,t);

A_c_O = simplify(subs(A_c_O,A,B));
O_c_A = simplify(subs(O_c_A,A,B));
O_cd_A = simplify(subs(O_cd_A,A,B));

wx = simplify([0,0,1]*A_c_O*O_cd_A*[0;1;0]);
wy = simplify([1,0,0]*A_c_O*O_cd_A*[0;0;1]);
wz = simplify([0,1,0]*A_c_O*O_cd_A*[1;0;0]);

Fapp_O = [Fx;Fy;Fz];
Fapp_A = simplify(A_c_O*Fapp_O);

r_AO_A = [la;...
          0 ;...
          0 ];
o_v_AO_A = [lad   ;...
            wz*la ;...
            -wy*la];
o_a_AO_A = [ladd-la*(wy^2+wz^2)      ;...
            wzd*la+2*wz*lad+wx*wy*la ;...
            -wyd*la-2*wy*lad+wx*wz*la];

% EQ_NoMdot   = cross(r_AO_A,Fapp_A) == ma*(cross(r_AO_A,o_a_AO_A));
EQ_WithMdot = cross(r_AO_A,Fapp_A) == ma*(cross(r_AO_A,o_a_AO_A))+mad*(cross(r_AO_A,o_v_AO_A));

% Ans_NoMdot   = solve(EQ_NoMdot,[wxd,wyd,wzd]);
% Wxd = simplify(Ans_NoMdot.wxd)
% Wyd = simplify(Ans_NoMdot.wyd)
% Wzd = simplify(Ans_NoMdot.wzd)

Ans_WithMdot = solve(EQ_WithMdot,[wxd,wyd,wzd]);
Wxd = simplify(Ans_WithMdot.wxd);
Wyd = simplify(Ans_WithMdot.wyd);
Wzd = simplify(Ans_WithMdot.wzd);

syms Wx Wy Wz
ANS = solve([Wy==wy,Wz==wz],[theta_dot,psi_dot]);
Td = ANS.theta_dot;
Pd = ANS.psi_dot;


syms vXa vYa vZa
Q = solve([Wz*la;-Wy*la]==[vYa;vZa],[Wz,Wy])
Q.Wy
Q.Wz


% syms Xo Yo Zo Xa Ya Za
% r_O = [Xo;Yo;Zo];
% r_A = [Xa;0;0];
% Q = solve(r_O == O_c_A*r_A,[theta,psi,Xa]);
% Q.theta
% Q.psi
% Q.Xa

