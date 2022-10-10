function [op] = trimConditionFinder(alpha_a,beta_a,az,el,ht)
mdl = 'kiteModelNoAddedMassRapp';
opspec = operspec(mdl);

%% inputs

%aileron
opspec.Inputs(1).Known = 0; 
opspec.Inputs(1).Min = deg2rad(-30); 
opspec.Inputs(1).Max = deg2rad(30); 

%elevator
opspec.Inputs(2).Known = 0; 
opspec.Inputs(2).Min = deg2rad(-30); 
opspec.Inputs(2).Max = deg2rad(30); 

%rudder
opspec.Inputs(3).Known = 0; 
opspec.Inputs(3).Min = deg2rad(-30); 
opspec.Inputs(3).Max = deg2rad(30); 

%fThrTanZ
opspec.Inputs(4).Known = 1; 
opspec.Inputs(4).u = 1e4; 
 
%% unknown states that are at steady state

%v_a
opspec.States(1).SteadyState = 1; 
opspec.States(1).Min = 0; 
opspec.States(1).Max = 14; 

%p_b
opspec.States(9).SteadyState = 1; 
opspec.States(9).Min =-pi/2; 
opspec.States(9).Max =pi/2; 

%q_b
opspec.States(10).SteadyState = 1; 
opspec.States(10).Min = -pi/2; 
opspec.States(10).Max = pi/2; 

%r_b
opspec.States(11).SteadyState = 1; 
opspec.States(11).Min = -pi/2; 
opspec.States(11).Max = pi/2; 


%% unknown state that are not at steady state

%phi_t
opspec.States(6).SteadyState = 0; 
opspec.States(6).Min =-pi/2; 
opspec.States(6).Max =pi/2; 

%theta_t
opspec.States(7).SteadyState = 0; 
opspec.States(7).Min =-pi/2; 
opspec.States(7).Max =pi/2; 

%psi_t
opspec.States(8).SteadyState = 0; 
opspec.States(8).Min =-pi/2; 
opspec.States(8).Max =pi/2; 
%% known states 
opspec.States(2).Known = 1; %alpha
opspec.States(3).Known = 1; %elevation
opspec.States(4).Known = 1; %ht
opspec.States(5).Known = 1; %beta
opspec.States(12).Known = 1; %az

opspec.States(2).x = alpha_a; %alpha
opspec.States(3).x = el; %elevation
opspec.States(4).x = ht; %ht
opspec.States(5).x = beta_a; %beta
opspec.States(12).x = az; %az

%% unit delays 
opspec.States(13).Known = 1; 
opspec.States(14).Known = 1; 
opspec.States(15).Known = 1; 
opspec.States(16).Known = 1; 

opspec.States(13).x = 1; 
opspec.States(14).x = 1; 
opspec.States(15).x = 1; 
opspec.States(16).x = 1; 

opt = findopOptions('OptimizerType','graddescent-elim','DisplayReport','iter');


op = findop(mdl,opspec,opt);

end

