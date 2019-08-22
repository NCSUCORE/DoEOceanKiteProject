    figure
    vels=tsc.velocityVec.Data(:,:,:);%[(1-tsc.velocityVec.Data(1,1,:)); tsc.velocityVec.Data(2:3,1,:)];
    velmags = sqrt(sum((vels).^2,1));
    plot(tsc.velocityVec.Time, squeeze(velmags));
    xlabel('time (s)')
    ylabel('ground frame velocity (m)')
    hold on