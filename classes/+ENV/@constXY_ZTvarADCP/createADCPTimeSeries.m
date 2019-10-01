function flowSeries = createADCPTimeSeries(obj)
startTime = obj.startADCPTime.Value;
  %% adcpFlowInXYDirectionOnly
                  %adcp Data in just xy 
            if strcmpi(obj.flowType.Value, 'adcpFlowInXYDirectionOnly')==1
                %sets your depth array to match the oct data
                timeVec = 0:1:obj.endADCPTime.Value-1;
                obj.depth.setValue((4*61+6.31),'m')
                obj.depthArray.setValue([6.31:1:4*61+6.31],'m');
                load('ADCPData')
                tenMinTimeInterval = ceil(obj.endADCPTime.Value/600);

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
                  
            if strcmpi(obj.flowType.Value, 'adcpFlow')==1
                    %sets your depth array to match the oct data
                    timeVec = 0:1:obj.endADCPTime.Value-1;
                    obj.depth.setValue((4*61+6.31),'m')
                    obj.depthArray.setValue([6.31:1:4*61+6.31],'m');
                    load('ADCPData')
                    tenMinTimeInterval = ceil(obj.endADCPTime.Value/600);

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
%% time Series
                
                    flowSeries = timeseries(varyingFlow,timeVec);

end

