function [op] = trimConditionFinder(alpha_a,beta_a,az,el,ht,vW,vhcl)
mdl = 'kiteModelNoAddedMassRapp';
opspec = operspec(mdl);

%% Use Quasistatic Relations To Determine fThrTanZ and v_a
alpha_deg=180/pi*alpha_a;
thrDiameter=0.022;%m
thrCD=1.2;
clAg=vhcl.portWing.CL.Value.*2 +vhcl.hStab.CL.Value+vhcl.vStab.CL.Value;
kiteDrag=vhcl.portWing.CD.Value.*2+vhcl.hStab.CD.Value+vhcl.vStab.CD.Value;
thrDrag=thrCD.*0.25*(ht*thrDiameter./vhcl.fluidRefArea.Value);
cl=interp1(vhcl.portWing.alpha.Value,clAg,alpha_deg)%Interpolate CL
cdk=interp1(vhcl.portWing.alpha.Value,kiteDrag,alpha_deg)%Interpolate CD
cd=(cdk+thrDrag)*1.5;%Assuming Optimally Sized Turbines
fTens=0.5*vhcl.fluidDensity.Value*vhcl.fluidRefArea.Value*vW^2*(cl^3/cd^2);
vA=vW*(cl/cd);
FLift=fTens;

%Using quasistatically calculated Lift, determine bank angle

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
opspec.Inputs(4).u = fTens/10; 
opspec.Inputs(4).Known = 0; 
opspec.Inputs(4).Min = 0; 
opspec.Inputs(4).Max = 1e6; 
%% unknown states that are at steady state

%v_a
opspec.States(1).SteadyState = 1; 
opspec.States(1).Min = 0; 
opspec.States(1).Max = 10; 

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

%az
% opspec.States(12).SteadyState = 0; 
% opspec.States(12).Min =-pi/2; 
% opspec.States(12).Max =pi/2; 


%% known states 
opspec.States(1).Known=1;%Va
opspec.States(2).Known = 1; %alpha
opspec.States(3).Known = 1; %elevation
opspec.States(4).Known = 1; %ht
opspec.States(5).Known = 1; %beta
opspec.States(12).Known = 1; %az

opspec.States(1).x=vA;%va
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

opt.OptimizationOptions.MaxFunEvals=10e4;
opt.OptimizationOptions.MaxIter=10e3;
op = findop(mdl,opspec,opt);

end

