function val = calcObjectiveForOmniscientAlt(zTraj,tCurrent,...
    synFlow,synAlt,hiLvlCtrl)

tVals = 0:hiLvlCtrl.predictionHorz-1;
tVals = tCurrent + tVals*hiLvlCtrl.mpckfgpTimeStep;

pVal = zeros(1,hiLvlCtrl.predictionHorz);
fVal = 0*zTraj;
imagLine = @(x) -750 + (700/4)*x;

for ii = 1:hiLvlCtrl.predictionHorz
    
    fData = resample(synFlow,tVals(ii)*60).Data;
    hData = resample(synAlt,tVals(ii)*60).Data;
    
    fVal(ii) = interp1(hData,fData,zTraj(ii));
    
    pVal(ii) = hiLvlCtrl.powerGrid(fVal(ii),zTraj(ii))...
        -0.0*(max(0,imagLine(fVal(ii))-zTraj(ii)));
    
end

val = sum(pVal);

end