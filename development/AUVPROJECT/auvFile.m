
clc;
clear all;
%% Constants

% full charge
socLimitUpper = 1;

% recharge
socLimitLower = .30;

%load flow data

%fluid density
densityOfFluid = 1000; 

%refarea
aRef = 10; 

%maximum battery energy capacity 
batteryMaxEnergy = 3.6e+8 ; %joules %400 KHW

%propulsion Power of a 10 hp motor
propulsionPower = 7.457; %kw

vWind = [-1;0;0];
batteryEnergyRemaining = batteryMaxEnergy ; %initializing battery energy

simFlag = 0; 
secondsForDistance = 0;

%% time loop 
% i = time
while ( i <= 10000)
    if simFlag == 0
     secondsForDistance = secondsForDistance + 1;
    else
     simFlag = 0; 
    end 
%%%%%%%%%%%%%%%%% VEHICLE POSITION
vhclVelocity = [5;0;0]; % m/s %velocity of the vehicle 
vhclVelMag = sqrt(sum(vhclVelocity.^2));
motorForce = propulsionPower/vhclVelMag;
vhclPos = vhclVelMag * secondsForDistance ; 

%%%%%%%%%%%%%%%%% DRAG DYNAMICS
Cd = 1; 
vApp = vWind - vhclVelocity;
vAppMag = sqrt(sum(vApp.^2));
dragForce = .5.*densityOfFluid.*vAppMag.^2 .*aRef.*Cd;

%%%%%%%%%%%%%%%%% POWER CALCULATION
dragPower  = dragForce*vhclVelMag; 
netPowerSpent = dragPower + propulsionPower;

%%%%%%%%%%%%%%%%% BATTERY ENERGY LEFT AT EACH TIME STEP

%power is calculated on a second by second basis so at each second you can 
%subtract the power from from the energy balance at each time step
batteryEnergyRemaining = batteryEnergyRemaining - netPowerSpent; 



%%%%%%%%%%%%%%%%%%% GP MODEL
%this entails estimating the max flow and the covarience.
stopAndCharge = 1;

%%%%%%%%%%%%%%%%% BINARY CHARGE DECISION

if (((batteryEnergyRemaining/batteryMaxEnergy) <= socLimitLower) || ( stopAndCharge == 0  ) )
    
    %simulate kite power generation
    james_ts
    
    %energy gained 
    energyGained =  tsc.energy.data(end);
    batteryEnergyRemaining = batteryEnergyRemaining + energyGained;
    
    i = i + ceil(tsc.energy.time(end)); 
    simflag = 1; 
else 
    i = i + 1; 
    
 
end