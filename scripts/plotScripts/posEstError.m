close all 
midNodePos = tsc.thrNodePosVecs.Data(:,2,:);
tetherLength = squeeze(tsc.tetherLengths.Data)'; 
time = tsc.thrNodePosVecs.Time'; 

midNodePosX = squeeze(midNodePos(1,:,:))'; 
midNodePosY = squeeze(midNodePos(2,:,:))'; 
midNodePosZ = squeeze(midNodePos(3,:,:))'; 

kitePos = tsc.positionVec.Data; 

kitePosX = squeeze(kitePos(1,:,:))'; 
kitePosY = squeeze(kitePos(2,:,:))'; 
kitePosZ = squeeze(kitePos(3,:,:))'; 

R = zeros(1,length(midNodePosX)); 
El = zeros(1,length(midNodePosX)); 
Az = zeros(1,length(midNodePosX)); 
x_est = zeros(1,length(midNodePosX)); 
y_est = zeros(1,length(midNodePosX)); 
z_est = zeros(1,length(midNodePosX)); 
x_err = zeros(1,length(midNodePosX)); 
y_err = zeros(1,length(midNodePosX)); 
z_err = zeros(1,length(midNodePosX)); 

for i = 1:length(midNodePosX)
    R(i) = sqrt(midNodePosX(i)^2 + midNodePosY(i)^2 + (200-midNodePosZ(i))^2);
    El(i) = asin((200-midNodePosZ(i))/R(i)); 
    Az(i) = asin(midNodePosY(i)/sqrt(midNodePosX(i)^2 + midNodePosY(i)^2)); 
    z_est(i) = tetherLength(i)*sin(El(i)); 
    x_est(i) = tetherLength(i)*cos(El(i))*cos(Az(i)); 
    y_est(i) = tetherLength(i)*cos(El(i))*sin(Az(i));
    x_err(i) = (abs(x_est(i)-kitePosX(i)))/max(kitePosX); 
    y_err(i) = (abs(y_est(i)-kitePosY(i)))/max(kitePosY);
    z_err(i) = (abs((200-z_est(i))-kitePosZ(i)))/max(kitePosZ); 
end 

figure; 
plot(time,100*x_err)
hold on 
plot(time,100*y_err)
plot(time,100*z_err)
hold off 
title('error(%) of position estimates using LAS') 
legend('X error','Y error','Z error')

figure; 
plot(time,kitePosX)
hold on 
plot(time,x_est,'--')
title('x positions') 
legend('true value','LAS Estimate')


figure; 
plot(time,kitePosY)
hold on 
plot(time,y_est,'--')
title('y positions') 
legend('true value','LAS Estimate')

figure; 
plot(time,kitePosZ)
hold on 
plot(time,200-z_est,'--')
title('z positions') 
legend('true value','LAS Estimate')

mean_X_error = 100*mean(x_err) 
mean_Y_error = 100*mean(y_err) 
mean_Z_error = 100*mean(z_err) 