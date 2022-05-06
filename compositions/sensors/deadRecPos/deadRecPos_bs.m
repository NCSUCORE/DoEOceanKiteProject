SENSORS = 'deadRecPos';

sns = SNS.realistic;
sns.addprop('ARW')
sns.addprop('VRW')
sns.addprop('kGyro')
sns.addprop('bGyro')
sns.addprop('bPrimeGyro')
sns.addprop('bAcc')
sns.addprop('kAcc');
sns.addprop('gndTruthFreq');
sns.addprop('posErrMag');
sns.addprop('velErrMag');
%Random Walks given in unit/sqrt(hr). Divide by 60 to get unit/sqrt(s)
sns.ARW = SIM.parameter('Unit','deg/(s)^1/2','Value',0.2546/60,'Description','Angle Random Walk');
sns.VRW = SIM.parameter('Unit','m/s/(s)^1/2','Value',0.09123/60,'Description','Velocity Random Walk');
sns.kGyro = SIM.parameter('Unit','deg/s','Value',0,'Description','IMU Gyro Linearity');
sns.kAcc = SIM.parameter('Unit','','Value',[0;0;0],'Description','IMU Acceleration Linearity');
%Gyro bias given in deg/h, also should bem ultiplied by 5 for conservative
sns.bGyro = SIM.parameter('Unit','','Value',5*6.415*ones(3,1)/3600,'Description','Static Gyro Bias');
sns.bPrimeGyro = SIM.parameter('Unit','','Value',[0;0;0],'Description','Time Varying Gyro Bias');
%Acc bias given in milli-g*9.81m/s^2/g*1/1000milli
sns.bAcc = SIM.parameter('Unit','','Value',5*0.07441*9.81/1000*ones(3,1),'Description','Static Accelleration Bias');
sns.gndTruthFreq = SIM.parameter('Unit','rad/s','Value',pi/2,'Description','Update Frequency for acoustic ground truth');
sns.posErrMag = SIM.parameter('Unit','m','Value',3,'Description','Positional Accuracy of Acoustic Ping');
sns.velErrMag = SIM.parameter('Unit','','Value',0.01,'Description','Velocity Accuracy of Acoustic Ping');
saveBuildFile('sns',mfilename,'variant','SENSORS');