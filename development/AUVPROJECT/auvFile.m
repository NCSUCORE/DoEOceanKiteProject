clc; 
clear all; 

transectData

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

% Total matrix of indexes for the best previous at each current
totalIndexMat = [];

%% final cost computation 

            terminalCost              = [];
            
  for j = 1:length(possibleBatteryLife)
      
            terminalBatteryRemaining  = socLimitUpper*100 - possibleBatteryLife(j); 
            timeToChargeToFull        = flowTimeCost(100)*(100-terminalBatteryRemaining) + startKiteCost;
            terminalCost              = [terminalCost,timeToChargeToFull]; 
            
  end 
%% for loop 

%stage before the last backwards to 
for i = numStages-1:-1:2 
    
            smallestCostMat          = [];
            indexMat                 = [];
    %number of states in current stage
    for ii = length(possibleBatteryLife):-1:1
        
            %as you change stages, the cost to finish at each state combo is
            %carried back
            if exist('initialStateCostPerStage')
            intialStateCost          = initialStateCostPerStage(ii);
            else
            intialStateCost          = 0;     
            end
            
            
            
            %velocity of wind at current stage
            %possible battery lifes 
            vWind                    = flowSpeeds(i);
            stateBatteryLife         = possibleBatteryLife(ii); 
            
            
%%%%%%%%%%%%%%%%% DRAG DYNAMICS
            Cd                       = 1; 
            vApp                     = vWind - vhclVelocity;
            vAppMag                  = sqrt(sum(vApp.^2));
            dragForce                = .5.*densityOfFluid.*vAppMag.^2 .*aRef.*Cd;

%%%%%%%%%%%%%%%%%INCREASE IN CHARGE COST 
            
            dragEnergy               = dragForce * posInt; 
            propulsionEnergy         = propulsionPower * vhclPosChangeTimePenalty ;  
            energySpentToMovePercent = ceil(100*(dragEnergy + propulsionEnergy)/batteryMaxEnergy);
            batteryEnergyRemaining   = stateBatteryLife - energySpentToMovePercent;
            timeChargeOnePercentCur  = flowTimeCost(i-1);
            %if you cannot make it to next position, you have to stop and
            %charge until you can make it. Your battery in the next stage
            %is now zero starting out
            if batteryEnergyRemaining< 0   
            timePenaltyCantMakeIt    = timeChargeOnePercentCur * (energySpentToMovePercent - batteryEnergyRemaining);
            batteryEnergyRemaining   = 0;
            totalAddedStageCost      = timePenaltyCantMakeIt + startKiteCost;
            else
            totalAddedStageCost      = 0;
            end
            costToFinishMat          = [];
%             disp(batteryEnergyRemaining)
        
        % possible battery life = states
        for iii = length(possibleBatteryLife):-1:1           

            timeChargeOnePercentPrev = flowTimeCost(i); 
            timePenaltyCharging      = timeChargeOnePercentPrev*((iii-1)-batteryEnergyRemaining);
%             disp(timePenaltyCharging) 
            
            if timePenaltyCharging   == 0 
            costToFinish             = totalAddedStageCost + vhclPosChangeTimePenalty + intialStateCost;  
            elseif timePenaltyCharging <0 
            costToFinish             = NaN;
            else
            costToFinish             = totalAddedStageCost + vhclPosChangeTimePenalty + timePenaltyCharging + startKiteCost + intialStateCost;
            end
            
            if i == numStages
                costToFinish = costToFinish + terminalCost(1+length(possibleBatteryLife)-iii);
            end
            
            costToFinishMat          =[costToFinishMat,costToFinish];
        end
        
           [smallestCost,index]      = min(costToFinishMat);
            smallestCostMat          =[smallestCostMat, smallestCost];
            indexMat                 =[indexMat;index]; 

    end   
            %gets updated after the completion of finding the lowest cost
            %per state in a stage
            initialStateCostPerStage = smallestCostMat;
            totalIndexMat            =[totalIndexMat, indexMat];
        
    
end
%% cost for initial position to finish

           vWind                    = flowSpeeds(1);
            stateBatteryLife         = possibleBatteryLife(end); 
            
%%%%%%%%%%%%%%%%% INITIAL DRAG DYNAMICS
            Cd                       = 1; 
            vApp                     = vWind - vhclVelocity;
            vAppMag                  = sqrt(sum(vApp.^2));
            dragForce                = .5.*densityOfFluid.*vAppMag.^2 .*aRef.*Cd;
    
            dragEnergy               = dragForce * posInt; 
            propulsionEnergy         = propulsionPower * vhclPosChangeTimePenalty ;  
            energySpentToMovePercent = ceil(100*(dragEnergy + propulsionEnergy)/batteryMaxEnergy);
            batteryEnergyRemaining   = stateBatteryLife - energySpentToMovePercent;
            timeChargeOnePercentInit = flowTimeCost(1);
            initCostToFinishMat      = [];
for iii = length(possibleBatteryLife):-1:1

            timePenaltyCharging      = timeChargeOnePercentInit*((iii-1)-batteryEnergyRemaining);
       
            if timePenaltyCharging   == 0 
            initCostToFinish         =  vhclPosChangeTimePenalty;  
            elseif timePenaltyCharging <0 
            initCostToFinish         = NaN;
            else
            initCostToFinish         = vhclPosChangeTimePenalty + timePenaltyCharging + startKiteCost ;
            end
            initCostToFinishMat      =[initCostToFinishMat,costToFinish];
end


            [smallestCostInit,indexInit]      = min(costToFinishMat);
            
            






















