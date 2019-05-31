function buildAVLSweepRunFile(fileName,alphas,betas,flaps,ailerons,elevators,rudders)
if isfile(fileName)
     delete(fileName)
end

fid = fopen(fileName,'w');
caseNum = 1;
for ii = 1:length(alphas)
    alpha = alphas(ii);
    for jj = 1:length(betas)
        beta = betas(jj);
        for kk = 1:length(flaps)
            flap = flaps(kk);
            for mm = 1:length(ailerons)
                aileron = ailerons(mm);
                for nn = 1:length(elevators)
                    elevator = elevators(nn);
                    for pp = 1:length(rudders)
                        rudder = rudders(pp);
                        appendAVLRunCase(fid,caseNum,alpha,beta,flap,aileron,elevator,rudder)
                        caseNum = caseNum + 1;
                    end
                end
            end
        end
    end
end
fclose(fid);
end