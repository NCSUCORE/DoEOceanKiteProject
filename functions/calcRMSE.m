function RMSE = calcRMSE(x1,x2)

% square and take mean
err = x1(:) - x2(:);

RMSE = sqrt(mean((err./max(abs(err))).^2));

end
