function RMSE = calcRMSE(simRes,expRes)

% square and take mean
err = simRes(:) - expRes(:);

RMSE = sqrt(mean(err.^2));

end
