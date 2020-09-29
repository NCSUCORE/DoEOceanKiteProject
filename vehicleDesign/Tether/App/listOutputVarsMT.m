
varNamesMToutputs = {'strainPercent' ,'supportForce' ,'powerLossPercent' };
    
for i = 1:numel(varNamesMToutputs)
    eval(sprintf('varMT.%s = inputParam;',varNamesMToutputs{i}));
end

%Tether Strain
varMToutputs.strainPercent.defult = 0;
varMToutputs.Structure.Editable = 'off';
varMToutputs.Structure.BackgroundColor = sscanf('CDCDCD','%2x%2x%2x',[1 3])/255; %grey

%Tether Support Force
varMToutputs.strainPercent.defult = 0;
varMToutputs.Structure.Editable = 'off';
varMToutputs.Structure.BackgroundColor = sscanf('CDCDCD','%2x%2x%2x',[1 3])/255; %grey

%Tether Power Loss
varMToutputs.strainPercent.defult = 0;
varMToutputs.Structure.Editable = 'off';
varMToutputs.Structure.BackgroundColor = sscanf('CDCDCD','%2x%2x%2x',[1 3])/255; %grey
