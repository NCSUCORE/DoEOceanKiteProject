clear

%   Aggregate coefficients of the kite alone (not the tether), along with
%   the reference area
Cd_kite = .15;
Cl_kite = 1.5;
A_kite = 10;        %   m^2

%   Tether length, unfaired length, diameter, and tension limit
Lt = 400;           %   Length (m)
fairing_factor = .25;   %   Fraction of the tether that is faired
L_unfaired = (1-fairing_factor)*Lt;
dt = .017;          %   Diameter (m)
T_max = 20000;      %   Tension limit (N) -- Note: This should be replaced with a calculation, based on dt

%   Calculate aggregate kite Cd including the contribution of the tether -
%   Note that my (simple) derivation results in a 1/6 in the expression for
%   drag (see the attachment), whereas the more detailed derivation in the
%   literature has it at 1/8. Nevertheless, drag is proportional to L^3 in
%   either case, and the ratio of the (partially) faired tether drag to completely
%   unfaired tether drag will be consistent in either case. I'll use the
%   more accurate calculation of Cd from the literature here.
Cd_tether_nominal = 1.2;
Cd_tether_faired = .1;
Cd_tether_adjusted = Cd_tether_nominal*dt*Lt/A_kite*1/4;     %   Referenced to dynamic pressure at the kite and kite area
Cd_tether_adj_with_fairings = Cd_tether_adjusted*((Cd_tether_nominal*L_unfaired^3 + Cd_tether_faired*(Lt^3-L_unfaired^3))/(Cd_tether_nominal*Lt^3));

Cd_kite_aggregate = Cd_kite + Cd_tether_adj_with_fairings;

%   Calculate power curve
rho = 1000;                     %   Fluid density (kg/m^3)
K = 1.5;                        %   Ct/Cp
v_flow_vec = 0:.01:.5;          %   Range of flow speeds to consider (m/s)
theta = 30*pi/180;              %   Elevation angle (rad)
LF = .8;                        %   Loyd factor - A measure of flight efficiency
P_loyd = 2/27*LF*rho*Cl_kite^3/Cd_kite^2*K*A_kite*cos(theta)^3*v_flow_vec.^3;       %   Loyd power
P_limited = 1/3*K*T_max*v_flow_vec;         %   Power generated under maximum tension
P = min(P_loyd,P_limited);

%   Plot both the Loyd power and tension-limited power in one figure
figure(1)
hold on
plot(v_flow_vec,P_loyd);
plot(v_flow_vec,P_limited,'r');
xlabel('Flow speed (m/s)');
ylabel('Power output (W)');
legend('Loyd power','Tension-limited power');

%   Plot the resulting power curve, which is the minimum of the curves in
%   Figure 1
figure(2)
hold on
plot(v_flow_vec,P);
xlabel('Flow speed (m/s)');
ylabel('Power output (W)');
