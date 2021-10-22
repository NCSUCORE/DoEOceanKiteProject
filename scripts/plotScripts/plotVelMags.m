   
    vels=tsc.velocityVec.Data(:,:,:);%[(1-tsc.velocityVec.Data(1,1,:)); tsc.velocityVec.Data(2:3,1,:)];
    flowVel = squeeze(tsc.vhclFlowVecs.Data(:,1,:));
    flowVelMean = mean(sqrt(dot(flowVel,flowVel)))
    velmags = sqrt(sum((vels).^2,1));
<<<<<<< Updated upstream
    plot(tsc.velocityVec.Time, squeeze(velmags));
=======
    
    plot(tsc.velocityVec.Time, squeeze(velmags)/flowVelMean);
>>>>>>> Stashed changes
    xlabel('time (s)')
    ylabel('ground frame velocity (m/s)')
    hold on