function avlProcess(obj,type)

alphas      = obj.([type 'Case']).alpha;
betas       = obj.([type 'Case']).beta;
flaps       = obj.([type 'Case']).flap;
elevators   = obj.([type 'Case']).elevator;
ailerons    = obj.([type 'Case']).aileron;
rudders     = obj.([type 'Case']).rudder;

% If the files exist already, delete them
if isfile(obj.run_file_name)
    fclose('all');
    delete(obj.run_file_name)
end
if isfile(obj.result_file_name)
    fclose('all');
    delete(obj.result_file_name)
end

% Open files
runFileID    = fopen(obj.run_file_name,'a');
resultFileID = fopen(obj.result_file_name,'a');

% Run nested loops for every combination of angles
caseNumber = 1;
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
                        
                        % Append case number to run file
                        avlAppendRunFile(runFileID,caseNumber,...
                            alpha,beta,flap,aileron,elevator,rudder)
                        
                        % If we just wrote the 25th one, delete and
                        % recreate the runfile
                        if rem(caseNumber,25)==0 || strcmpi(type,'single')
                            fprintf('\nRunning %d - %d\n',...
                                max([caseNumber-24 1]), caseNumber)
                            % Run AVL and append to output
                            fwrite(resultFileID,avlRunFile(obj));
                            % Reset the output file
                            fclose(runFileID);
                            delete(obj.run_file_name)
                            runFileID = fopen(obj.run_file_name,'a');
                        end

                        % Increment case number
                        caseNumber = caseNumber + 1;
                    end
                end
            end
        end
    end
end

end