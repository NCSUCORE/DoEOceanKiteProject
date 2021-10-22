    figure(100)
    vels=tsc.velocityVec.Data(:,:,:);%[(1-tsc.velocityVec.Data(1,1,:)); tsc.velocityVec.Data(2:3,1,:)];
    flowVel = squeeze(tsc.gndStnVelocityVec.Data(:,1,:));
    flowVelMean = mean(sqrt(sum(flowVel.^2,1)));
    velmags = sqrt(sum((vels).^2,1));
    hold on
    plot(tsc.velocityVec.Time, squeeze(velmags)/flowVelMean);
    xlabel('Time [s]')
    ylabel('Velocity Augmentation')
    hold on