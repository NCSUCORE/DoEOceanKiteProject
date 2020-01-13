function RMSE = calcRMSE(x1,x2)

% square and take mean
RMSE = sqrt(mean((x1(:) - x2(:)).^2));

end
