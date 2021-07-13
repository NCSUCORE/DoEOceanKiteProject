SENSORS = 'lasPosEst';

sns = SNS.realistic;
sns.addprop('pwrQnt')
sns.pwrQnt = SNS.quantization;
sns.pwrQnt.setZeroOffset(0,'');
sns.pwrQnt.setStepSize(1,'');

saveBuildFile('sns',mfilename,'variant','SENSORS');