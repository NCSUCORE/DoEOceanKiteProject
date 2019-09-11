function flowSeries = createTimeSeriesFlow(obj,duration_s,flowMat,flowType)
            %% intialize
                    %time for time series object
                    timeVec = linspace(0,duration_s,duration_s*obj.waveCoursenessFactor.Value);
                    
                    %creating sine wave
                    x = linspace(0,2*pi*obj.repeat.Value,duration_s*obj.waveCoursenessFactor.Value);
                    wave = obj.amplitude.Value*sin(x)+obj.waveBias.Value;
                    
                    %matrix of ones
                    oneZerZerMat = [ones(1,obj.depth.Value);zeros(1,obj.depth.Value);zeros(1,obj.depth.Value)];
                    onesMat = ones(3,obj.depth.Value); 
                    flowMatTemp = [];
                    startTime = obj.startADCPTime.Value;
              %%    constant flow  
            
            if strcmpi(flowType, 'constantUniformFlow')==1
                  constFlowMat = repmat(flowMat',1,obj.depth.Value);
                  varyingFlow = repmat(constFlowMat ,1,1,length(timeVec));
            end
            
            %sine wave flow over time
            if strcmpi(flowType, 'sineWaveFlow')==1
                for i = 1:length(timeVec)
    
                    flowMatTemp = oneZerZerMat * wave(i);
                    varyingFlow(:,:,i) = flowMatTemp;
  
                end 
            end
            %% adcpFlowInXYDirectionOnly
                  %adcp Data in just xy 
            if strcmpi(flowType, 'adcpFlowInXYDirectionOnly')==1
                %sets your depth array to match the oct data
                timeVec = 0:1:duration_s-1;
                obj.depth.setValue((4*61+6.31),'m')
                obj.depthArray.setValue([6.31:1:4*61+6.31],'m');
                load('usefulFlowData.mat')
                tenMinTimeInterval = ceil(duration_s/600);

                    fprintf('timeStart is year 20%d, month %d, day %d ,hour %d min %d\n',[SerYear(obj.startADCPTime.Value),SerMon(obj.startADCPTime.Value),SerDay(obj.startADCPTime.Value),SerHour(obj.startADCPTime.Value),SerMin(obj.startADCPTime.Value)])
                    fprintf('timeEnd is closest to year 20%d, month %d, day %d ,hour %d min %d\n',[SerYear(obj.startADCPTime.Value+tenMinTimeInterval),SerMon(obj.startADCPTime.Value+tenMinTimeInterval),...
                    SerDay(obj.startADCPTime.Value+tenMinTimeInterval),SerHour(obj.startADCPTime.Value+tenMinTimeInterval),SerMin(obj.startADCPTime.Value+tenMinTimeInterval)])
                for i = 1:62
                    flowInXYDirectionOnly(:,:,i)  = [SerEmmpersec(:,i),SerNmmpersec(:,i), zeros(length(SerEmmpersec),1)];
                end
                    %matrix of the data between the times you have selected
                    selTime =  flowInXYDirectionOnly(obj.startADCPTime.Value:obj.startADCPTime.Value+tenMinTimeInterval,:,:);
                    %%%%%%%%%%%%%%%%%%%need to interpolate between depths
                    for i = 1:62
                    xMat(:,i) = selTime(:,1,i);
                    yMat(:,i) = selTime(:,2,i);
                    zMat(:,i) = selTime(:,3,i);
                    sXM = size(xMat);
                    end
                    
                    for j = 1:sXM(1)
                        xMatInterp(j,:) = interp1(xMat(j,:),linspace(1,62,length(obj.depthArray.Value)));
                        yMatInterp(j,:) = interp1(yMat(j,:),linspace(1,62,length(obj.depthArray.Value)));
                        zMatInterp(j,:) = interp1(zMat(j,:),linspace(1,62,length(obj.depthArray.Value)));
                    end
                   
                       for ii =  1:length(obj.depthArray.Value)
                    interpolatedDepthMat(:,:,ii) = [xMatInterp(:,ii),yMatInterp(:,ii),zMatInterp(:,ii)];
                    
                       end 
                      %%%%%%%%%%%%%%%%%%%need to interpolate between time
                       for iii = 1:length(obj.depthArray.Value)
                           vq = linspace(1,sXM(1),tenMinTimeInterval*600);
                           xDatInterpedDepth = interpolatedDepthMat(:,1,iii);
                           yDatInterpedDepth = interpolatedDepthMat(:,2,iii);
                           zDatInterpedDepth = interpolatedDepthMat(:,3,iii);
                           interpedDataTimeX = interp1(xDatInterpedDepth,vq);
                           interpedDataTimeY = interp1(yDatInterpedDepth,vq);
                           interpedDataTimeZ = interp1(zDatInterpedDepth,vq);
                           
                           %%%% must be reshaped
                          
                           varyingFlow(:,:,iii) = [ .001*interpedDataTimeX; .001*interpedDataTimeY; .001*interpedDataTimeZ];
                          
                       end 
                    varyingFlow = permute(varyingFlow,[1,3,2]);
                    varyingFlow = varyingFlow(:,:,1:length(timeVec)); 
                         
                   
            end
            %% adcpFlow
                  
            if strcmpi(flowType, 'adcpFlow')==1
                    %sets your depth array to match the oct data
                    timeVec = 0:1:duration_s-1;
                    obj.depth.setValue((4*61+6.31),'m')
                    obj.depthArray.setValue([6.31:1:4*61+6.31],'m');
                    load('usefulFlowData.mat')
                    tenMinTimeInterval = ceil(duration_s/600);

                    fprintf('timeStart is year 20%d, month %d, day %d ,hour %d min %d\n',[SerYear(startTime),SerMon(startTime),SerDay(startTime),SerHour(startTime),SerMin(startTime)])
                    fprintf('timeEnd is closest to year 20%d, month %d, day %d ,hour %d min %d\n',[SerYear(startTime+tenMinTimeInterval),SerMon(startTime+tenMinTimeInterval),...
                    SerDay(startTime+tenMinTimeInterval),SerHour(startTime+tenMinTimeInterval),SerMin(startTime+tenMinTimeInterval)])
                for i = 1:62
                    flowIn(:,:,i)  = [SerEmmpersec(:,i),SerNmmpersec(:,i),SerNmmpersec(:,i)];
                end
                    %matrix of the data between the times you have selected
                    selTime =  flowIn(startTime:startTime+tenMinTimeInterval,:,:);
                    %%%%%%%%%%%%%%%%%%%need to interpolate between depths
                    for i = 1:62
                        xMat(:,i) = selTime(:,1,i);
                        yMat(:,i) = selTime(:,2,i);
                        zMat(:,i) = selTime(:,3,i);
                        sXM = size(xMat);
                    end
                    
                    for j = 1:sXM(1)
                        xMatInterp(j,:) = interp1(xMat(j,:),linspace(1,62,length(obj.depthArray.Value)));
                        yMatInterp(j,:) = interp1(yMat(j,:),linspace(1,62,length(obj.depthArray.Value)));
                        zMatInterp(j,:) = interp1(zMat(j,:),linspace(1,62,length(obj.depthArray.Value)));
                    end
                   
                       for ii =  1:length(obj.depthArray.Value)
                    interpolatedDepthMat(:,:,ii) = [xMatInterp(:,ii),yMatInterp(:,ii),zMatInterp(:,ii)];
                    
                       end 
                      %%%%%%%%%%%%%%%%%%%need to interpolate between time
                       for iii = 1:length(obj.depthArray.Value)
                           vq = linspace(1,sXM(1),tenMinTimeInterval*600);
                           xDatInterpedDepth = interpolatedDepthMat(:,1,iii);
                           yDatInterpedDepth = interpolatedDepthMat(:,2,iii);
                           zDatInterpedDepth = interpolatedDepthMat(:,3,iii);
                           interpedDataTimeX = interp1(xDatInterpedDepth,vq);
                           interpedDataTimeY = interp1(yDatInterpedDepth,vq);
                           interpedDataTimeZ = interp1(zDatInterpedDepth,vq);
                           
                           %%%% must be reshaped
                          
                           varyingFlow(:,:,iii) = [ .001*interpedDataTimeX; .001*interpedDataTimeY; .001*interpedDataTimeZ];
                          
                       end 
                    varyingFlow = permute(varyingFlow,[1,3,2]);
                    varyingFlow = varyingFlow(:,:,1:length(timeVec)); 
                         
                    
            end
            %% adcp data flow with turbulence
            if strcmpi(flowType, 'adcpFlowWithTurbulence')==1
                    %sets your depth array to match the oct data
                    timeVec = 0:1:duration_s-1;
                    obj.depth.setValue((4*61+6.31),'m')
                    obj.depthArray.setValue([6.31:4:4*61+6.31],'m');
                    load('usefulFlowData.mat')
                    tenMinTimeInterval = ceil(duration_s/600);
                    

                    fprintf('timeStart is year 20%d, month %d, day %d ,hour %d min %d\n',[SerYear(startTime),SerMon(startTime),SerDay(startTime),SerHour(startTime),SerMin(startTime)])
                    fprintf('timeEnd is closest to year 20%d, month %d, day %d ,hour %d min %d\n',[SerYear(startTime+tenMinTimeInterval),SerMon(startTime+tenMinTimeInterval),...
                    SerDay(startTime+tenMinTimeInterval),SerHour(startTime+tenMinTimeInterval),SerMin(startTime+tenMinTimeInterval)])
                
                for i = 1:62
                    flowIn(:,:,i)  = [SerEmmpersec(:,i),SerNmmpersec(:,i),SerNmmpersec(:,i)];
                end
                    %matrix of the data between the times you have selected
                    selTime =  flowIn(startTime:startTime+tenMinTimeInterval,:,:);
        
               
            
            %%% adding to adcp data 
            for iii = 1:length(obj.depthArray.Value) 
                      vq = linspace(1,tenMinTimeInterval+1,tenMinTimeInterval*600);
                      xDatForInterp = selTime(:,1,iii);
                      yDatForInterp = selTime(:,2,iii);
                      zDatForInterp = selTime(:,3,iii);
                      interpedDataTimeX = interp1(xDatForInterp,vq);
                      interpedDataTimeY = interp1(yDatForInterp,vq);
                      interpedDataTimeZ = interp1(zDatForInterp,vq);
                      interpedDataTime(:,:,iii) = [ .001*interpedDataTimeX; .001*interpedDataTimeY; .001*interpedDataTimeZ];
                           
            end    
           load ('turbGrid')
                 interpedDataTime = permute(interpedDataTime,[1,3,2]);
                 
                     flowX = interpedDataTime(1,:,:);
                     flowY = interpedDataTime(2,:,:);
                     flowZ = interpedDataTime(3,:,:);
                     
                     flowXX = [];
                     flowYY = [];
                     flowZZ = [];
                     for q = 1:length(y)
                        flowXXTemp = permute(flowX,[2,1,3]);
                        flowYYTemp = permute(flowY,[2,1,3]);
                        flowZZTemp = permute(flowZ,[2,1,3]);
                        flowXX = [flowXX,flowXXTemp];
                        flowYY = [flowYY,flowYYTemp];
                        flowZZ = [flowZZ,flowZZTemp];
                     end 
                     
                     
                     
                  
                     
            %%%%%%%%Final Flow Grid%%%%%%%
            
            tableForFlowSeriesX = flowXX +  U_f_gridFinished;
            tableForFlowSeriesY = flowYY +  V_f_gridFinished;
            tableForFlowSeriesZ = flowZZ +  W_f_gridFinished;
            end
            %% time Series
                
                    flowSeries = timeseries(varyingFlow,timeVec);
end