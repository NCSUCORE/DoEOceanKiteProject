%% initial conditions / linearization equillibrum points
% these are dummy values and should be selected correctly

% to select correctly, look at equation 3.18-3.22 in rapp paper. Solve
% systems of equations here

% 
% vaI =   3.0471;
% alphaaI= deg2rad(5); % not dummy
% betaaI = 0 ; % not dummy 
% phitI =4.3688e-05;
% thetatI =   -1.1345;
% psitI = 0 ;
% pbI = 0.48496;
% qbI = 0;
% rbI = 0.30471 ;
% azI =  0.10017;  %dummy
% elI =  deg2rad(30); %dummy
% htI = 100 ;

vA =   3.0471;
alphaaI= deg2rad(5); % not dummy
betaaI = 0 ; % not dummy 
phitI =4.3688e-05;
theta =   -1.1345;
psi = 0 ;
pb = 0.48496;
qb = 0;
rb = 0.30471 ;
azu =  0.10017;  %dummy
el =  deg2rad(30); %dummy
ht = 100 ;

%% system parameters
loadComponent('fullScale1thr');

m = vhcl.mass.Value;

J = vhcl.inertia_CM.Value;

Jinv = inv(J);

vW = 1; %water speed




%% Trim condition selector
pathRadius=10;%m
alpha_a = deg2rad(5);
beta_a_trim = 0; 
az_trim =  0.10017; 
el_trim = deg2rad(30);
ht_trim = 100; 
%[op] = trimConditionFinder(alpha_a_trim,beta_a_trim,az_trim,el_trim,ht_trim,vW,vhcl)
[op] = trimConditionFinderwithAssu(alpha_a,beta_a_trim,az_trim,el_trim,ht_trim,vW,pathRadius,vhcl)

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




