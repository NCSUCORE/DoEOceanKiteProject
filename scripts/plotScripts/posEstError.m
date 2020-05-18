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
El_est = zeros(1,length(midNodePosX)); 
Az_est = zeros(1,length(midNodePosX)); 
x_est = zeros(1,length(midNodePosX)); 
y_est = zeros(1,length(midNodePosX)); 
z_est = zeros(1,length(midNodePosX)); 
x_err = zeros(1,length(midNodePosX)); 
y_err = zeros(1,length(midNodePosX)); 
z_err = zeros(1,length(midNodePosX)); 
El_err_p = zeros(1,length(midNodePosX)); 
Az_err_p = zeros(1,length(midNodePosX)); 
El_err_raw = zeros(1,length(midNodePosX)); 
Az_err_raw = zeros(1,length(midNodePosX)); 


for i = 1:length(midNodePosX)
    R(i) = sqrt(midNodePosX(i)^2 + midNodePosY(i)^2 + (200-midNodePosZ(i))^2);
    R_k(i) = sqrt(kitePosX(i)^2 + kitePosY(i)^2 + (200-kitePosZ(i))^2);
    El(i) = asin((200-midNodePosZ(i))/R(i)); 
    Az(i) = asin(midNodePosY(i)/sqrt(midNodePosX(i)^2 + midNodePosY(i)^2)); 
    El_est(i) = asin((200-kitePosZ(i))/R_k(i)); 
    Az_est(i) = asin(kitePosY(i)/sqrt(kitePosX(i)^2 + kitePosY(i)^2));
    z_est(i) = tetherLength(i)*sin(El(i)); 
    x_est(i) = tetherLength(i)*cos(El(i))*cos(Az(i)); 
    y_est(i) = tetherLength(i)*cos(El(i))*sin(Az(i));
    x_err(i) = ((x_est(i)-kitePosX(i)))/max(kitePosX); 
    y_err(i) = ((y_est(i)-kitePosY(i)))/max(kitePosY);
    z_err(i) = (((200-z_est(i))-kitePosZ(i)))/max(kitePosZ); 
end 

for ii= 1:length(midNodePosX)
    El_err_p = (El_est-El)/max(El); 
    Az_err_p = (Az_est-Az)/max(Az); 
    El_err_raw = (El_est-El); 
    Az_err_raw = (Az_est-Az); 
end 

%% 

figure; 
plot(time,100*x_err)
hold on 
plot(time,100*y_err)
plot(time,100*z_err)
hold off 
title('error(%) of Angle estimates using LAS') 
legend('X error','Y error','Z error')

figure; 
plot(time,100*El_err_p)
hold on 
plot(time,100*Az_err_p)
hold off 
title('error(%) of position estimates using LAS') 
legend('El error','Az error')

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
%% 


max_X_error = 100*max(x_err) 
max_Y_error = 100*max(y_err) 
max_Z_error = 100*max(z_err) 
max_El_error = 100*max(El_err_p) 
max_Az_error = 100*max(Az_err_p) 
max_El_error = max(El_err_raw)*(180/pi) 
max_Az_error = max(Az_err_raw)*(180/pi) 

%% 

figure; 
plot(time,El)
hold on 
plot(time,El_est,'--')
title('Elevation') 
legend('true value','LAS Estimate')

figure; 
plot(time,Az)
hold on 
plot(time,Az_est,'--')
title('Azimuth') 
legend('true value','LAS Estimate')
