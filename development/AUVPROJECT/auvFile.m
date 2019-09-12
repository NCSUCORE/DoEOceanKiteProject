
clc;
clear all;
%% Constants
%number of stages 
numStages                = length(vq);
flowSpeeds               = vq; 

%xdistance between each stage
posInt                   = xq(end)/length(vq);

% full charge
socLimitUpper            = 1;

% recharge
socLimitLower            = 0;

%fluid density
densityOfFluid           = 1000; %kg/m^3

%refarea
aRef                     = 10; %m^2

%maximum battery energy capacity 
batteryMaxEnergy         = 3.6e+8 ; %joules %400 KHW

%propulsion Power of a 10 hp motor
propulsionPower          = 7.457; %kw

%vCurrent
vWind                    = [-1;0;0];

%start with full battery

vhclVelocity             = [5;0;0]; % m/s %velocity of the vehicle 
vhclVelMag               = sqrt(sum(vhclVelocity.^2));

%possible Battery Life
possibleBatteryLife      = 0:100;

%time cost from charging at  flowspeeds at 100 different flow speeds
flowTimeCost             = randi(10,1,100);

% VEHICLE POSITION TO POSITION STAGE PENALTY (TIME)
vhclPosChangeTimePenalty = posInt/vhclVelMag ; %tau
% COST TO REAL IN AN OUT THE KITE 
startKiteCost = 300; %seconds
%% final cost computation 

            terminalCost              = [];
            
  for j = 1:numStages 
      
            terminalBatteryRemaining  = socLimitUpper*100 - (possibleBatteryLife(j)+1); 
            timeToChargeToFull        = flowTimeCost(100)*terminalBatteryRemaining;
            terminalCost              = [terminalCost,timeToChargeToFull]; 
            
  end 
%% for loop 

for i = 1:numStages 
    
    %number of states in current stage
    for ii = numStages:-1:1
        
            %velocity of wind at current stage
            %possible battery lifes 
            vWind                    = flowSpeeds(ii);
            stateBatteryLife         = possibleBatteryLife(ii); 
            %if you cannot make it to next position, you have to stop and
            %charge until you can
            
%%%%%%%%%%%%%%%%% DRAG DYNAMICS
            Cd                       = 1; 
            vApp                     = vWind - vhclVelocity;
            vAppMag                  = sqrt(sum(vApp.^2));
            dragForce                = .5.*densityOfFluid.*vAppMag.^2 .*aRef.*Cd;

%%%%%%%%%%%%%%%%%INCREASE IN CHARGE COST 
            dragEnergy               = dragForce * posInt; 
            propulsionEnergy         = propulsionPower * vhclPosChangeTimePenalty ;  
            energySpentToMovePercent = ceil(dragEnergy + propulsionEnergy)/batteryMaxEnergy;
            batteryEnergyRemaining   = stateBatteryLife - energySpentToMovePercent;
            timeToChargeOnePercent   = flowTimeCost(ii);
            %if you cannot make it to next position, you have to stop and
            %charge until you can
            if batteryEnergyRemaining < 0   
            timePenaltyCantMakeIt    = timeToChargeOnePercent * (energySpentToMovePercent - batteryEnergyRemaining);
            totalAddedStageCost      = timePenaltyCantMakeIt + startKiteCost;
            else
            totalAddedStageCost      = 0;
            end
            costToFinishMat          = [];
        %number of stages in previous stage
        for iii = 1: numStages           

            
            timePenaltyCharging      = timeToChargeOnePercent*(batteryEnergyRemaining+1-iii);
            if timePenaltyCharging   == 0 
            costToFinish             = totalAddedStageCost + vhclPosChangeTimePenalty + terminalCost(iii);  
            else
            costToFinish             = totalAddedStageCost + vhclPosChangeTimePenalty + timePenaltyCharging + terminalCost(iii);
            end
            
            costToFinishMat          =[costToFinishMat,costToFinish];
        end
        
           [bestCost,index]          = min(costToFinishMat);

    end
    
    
    
end
%% cost for initial position to finish


























