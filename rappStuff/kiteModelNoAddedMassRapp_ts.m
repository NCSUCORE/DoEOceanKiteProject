%% initial conditions / linearization equillibrum points
% these are dummy values and should be selected correctly

% to select correctly, look at equation 3.18-3.22 in rapp paper. Solve
% systems of equations here



vaI = 5 ;
alphaaI= deg2rad(5); % not dummy
betaaI = 0 ; % not dummy 
phitI =0  ;
thetatI = 0 ;
psitI = 0 ;
pbI = 0  ;
qbI = 0 ;
rbI = 0 ;
azI = 0 ;  %dummy
elI =  deg2rad(30); %dummy
htI = 120 ;


%% system parameters
loadComponent('fullScale1thr');

m = vhcl.mass.Value;

J = vhcl.inertia_CM.Value;

Jinv = inv(J);

vW = 1; %water speed




%% Trim condition selector
alpha_a_trim = deg2rad(5);
beta_a_trim = 0; 
az_trim = 0; 
el_trim = deg2rad(30);
ht_trim = 125; 
[op] = trimConditionFinder(alpha_a_trim,beta_a_trim,az_trim,el_trim,ht_trim)

%% Linearize

io(1)  = linio('kiteModelNoAddedMassRapp/inputBlock',1,'input'); % aileron
io(2)  = linio('kiteModelNoAddedMassRapp/inputBlock',2,'input'); % elevator
io(3)  = linio('kiteModelNoAddedMassRapp/inputBlock',3,'input'); % rudder
io(4)  = linio('kiteModelNoAddedMassRapp/inputBlock',4,'input'); % Fthr
io(5)  = linio('kiteModelNoAddedMassRapp/kiteModelNoAddedMassRapp',1,'output'); % v_a
io(6)  = linio('kiteModelNoAddedMassRapp/kiteModelNoAddedMassRapp',2,'output'); % beta_a
io(7)  = linio('kiteModelNoAddedMassRapp/kiteModelNoAddedMassRapp',3,'output'); % alpha_a
io(8)  = linio('kiteModelNoAddedMassRapp/kiteModelNoAddedMassRapp',4,'output'); % phi_t
io(9)  = linio('kiteModelNoAddedMassRapp/kiteModelNoAddedMassRapp',5,'output'); % theta_t
io(10)  = linio('kiteModelNoAddedMassRapp/kiteModelNoAddedMassRapp',6,'output'); % psi_t
io(11)  = linio('kiteModelNoAddedMassRapp/kiteModelNoAddedMassRapp',7,'output'); % p_b
io(12)  = linio('kiteModelNoAddedMassRapp/kiteModelNoAddedMassRapp',8,'output'); % q_b
io(13)  = linio('kiteModelNoAddedMassRapp/kiteModelNoAddedMassRapp',9,'output'); % r_b
io(14)  = linio('kiteModelNoAddedMassRapp/kiteModelNoAddedMassRapp',10,'output'); % az
io(15)  = linio('kiteModelNoAddedMassRapp/kiteModelNoAddedMassRapp',11,'output'); % el
io(16)  = linio('kiteModelNoAddedMassRapp/kiteModelNoAddedMassRapp',12,'output'); % ht

linsys = linearize(mdl,io,op)




