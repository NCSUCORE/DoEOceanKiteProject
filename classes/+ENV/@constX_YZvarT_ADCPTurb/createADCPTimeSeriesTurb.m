function [flowTSX,flowTSY,flowTSZ] = createADCPTimeSeriesTurb(obj)
 
                      startTime = obj.startADCPTime.Value;
                      timeVec = 0:1:obj.endADCPTime.Value-1;
                      obj.depth.setValue((4*61+6.31),'m')
                      obj.depthArray.setValue([6.31:4:4*61+6.31],'m');
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
        
                     magDepth = [];
                  for ii = 1:62
                     magDepthT = .001* sqrt(sum(selTime(:,:,ii).^2,2));
                    
                    %magnitude of xyz at each depth per time
                     magDepth = [magDepth,magDepthT];
                  end
                    
                     magDepthAVG = .5*(magDepth(1:end-1,:)+ magDepth(2:end,:));
              
                   
                     % create grid in the Y-Z plane
                      y = 0:1:10;
                     % z = 140:5:200;% only for testing
                      z = 6.31:4:4*61+6.31;

                     [Y,Z] = meshgrid(y,z);
                      X = zeros(size(Y));

                      y_pos = NaN(numel(Y),1);
                      z_pos = NaN(numel(Z),1);

                      n_elem = numel(Y);

                for i = 1:n_elem
                      y_pos(i) = Y(i);
                      z_pos(i) = Z(i);
                end
    
                       pos_data = [y_pos z_pos];
                       U_mean = []; 
                       % calculate turbulence parameters at each time
                       % 10 minute interval
                       TI         =  0.1;             % turbulence intensity (%)
                       f_min      = 0.01;             % minimum frequency associated with TI
                       f_max      = 1;                % max frequency associated with TI
                       P          = 0.1;              % factor defining relation between standard devs of velocity components u and v
                       Q          = 0.1;              % same as above but for u and w
                       C          = 5;                % along flow coherence decay constant
                       N_mid_freq = 5;                % number of frequency discretizations

                for iii = 1:tenMinTimeInterval
                    for j  = 1:length(y)
                      U_meanTemp = magDepthAVG(iii,:)';
                      U_mean =  [U_mean;U_meanTemp]; 
                    end 
                       turb_param= turbulence_generator2(0,U_mean,TI,f_min,f_max,P,Q,C,N_mid_freq,pos_data);
                       u_star_kj(:,:,iii) = turb_param.u_star_kj;
                       u_th_kR(:,:,iii)   = turb_param.u_th_kR;
                       v_star_kj(:,:,iii) = turb_param.v_star_kj;
                       v_th_kR(:,:,iii)   = turb_param.v_th_kR;
                       w_star_kj(:,:,iii) = turb_param.w_star_kj;
                       w_th_kR(:,:,iii)   = turb_param.w_th_kR;
                       ff(:,:,iii)        = turb_param.ff;
                       U_mean = []; 
                 end 
                    
                        clk_stamp = clock;
                        date_time = datetime(clk_stamp);

                        fid = fopen( 'code_completion_flag.txt', 'a' );
                        fprintf( fid, 'Turbulent inlet plane generation completed on %s \n \n',date_time);
                        fclose(fid);

                        save('turb_data');

                        fid = fopen( 'code_completion_flag.txt', 'a' );
                        fprintf( fid, 'Data saved successfully to file turb_data.mat \n');
                        fclose(fid)
          
                    
                    
 %% Post Process
                       
                        % Time
                        timeStep = 1;
                        tf = 600;

                        time = 1:timeStep:tf;
                        n_steps = length(time);
                        % pre-allocation
                        U_f_grid = NaN([size(Y) n_steps]);
                        V_f_grid = NaN([size(Y) n_steps]);
                        W_f_grid = NaN([size(Y) n_steps]);  

                        
for ip = 1:tenMinTimeInterval
                        

                        % pre-allocation
                        uf_int = NaN(1,N_mid_freq);
                        vf_int = NaN(1,N_mid_freq);
                        wf_int = NaN(1,N_mid_freq);

                        uf = NaN(n_elem,n_steps);
                        vf = NaN(n_elem,n_steps);
                        wf = NaN(n_elem,n_steps);

            % calculation
            for i = 1:n_steps

                for j = 1:n_elem
                    for k = 1:N_mid_freq
                        uf_int(1,k) = abs(u_star_kj(j,k,ip))*sin(2*pi*ff(k,:,ip)*time(i) + u_th_kR(j,k,ip));
                        vf_int(1,k) = abs(v_star_kj(j,k,ip))*sin(2*pi*ff(k,:,ip)*time(i) + v_th_kR(j,k,ip));
                        wf_int(1,k) = abs(w_star_kj(j,k,ip))*sin(2*pi*ff(k,:,ip)*time(i) + w_th_kR(j,k,ip));

                    end

                    uf(j,i) = sum(uf_int(1,:));
                    vf(j,i) = sum(vf_int(1,:));
                    wf(j,i) = sum(wf_int(1,:));

                end

            end

                    % superimpose on actual flow
                    U_f = NaN(n_elem,n_steps);
                    V_f = NaN(n_elem,n_steps);
                    W_f = NaN(n_elem,n_steps);

                    %rewrite this portion
                    for i = 1:n_steps

                    U_f(:,i) = uf(:,i);
                    V_f(:,i) = vf(:,i);
                    W_f(:,i) = wf(:,i);

                    end

%%%%%%%%%%%%%%%%%%%%% stop code if generating turbulence along a line
                    if length(y) == 1 || length(z) == 1
                        return
                    end

                    
                    U_f_grid_int = NaN(size(Y));
                    V_f_grid_int = NaN(size(Y));
                    W_f_grid_int = NaN(size(Y));

            for j = 1:n_steps

                for i = 1:n_elem

                    U_f_grid_int(i) = U_f(i,j);
                    V_f_grid_int(i) = V_f(i,j);
                    W_f_grid_int(i) = W_f(i,j);

                end

                U_f_grid(:,:,j,ip) =  U_f_grid_int(:,:);
                V_f_grid(:,:,j,ip) =  V_f_grid_int(:,:);
                W_f_grid(:,:,j,ip) =  W_f_grid_int(:,:);

            end
            
            
            
            
end

                U_f_gridInt1 = NaN(size(U_f_grid(:,:,:,1)));
                V_f_gridInt1 = NaN(size(V_f_grid(:,:,:,1)));
                W_f_gridInt1 = NaN(size(W_f_grid(:,:,:,1)));
            for ip = 1:tenMinTimeInterval 
               %concatination on the thrid dimension per ten minute interval
        
                U_f_gridInt1 = cat(3,U_f_gridInt1,U_f_grid(:,:,:,ip));
                V_f_gridInt1 = cat(3,V_f_gridInt1,V_f_grid(:,:,:,ip));
                W_f_gridInt1 = cat(3,W_f_gridInt1,W_f_grid(:,:,:,ip));
            end
            
            % grabbing all of the third dimension except ,10 minutes*60 = seconds
            % + 1 for time zero
            %did this a weird way to concatenate variable sizes in three
            %dimensions
             U_f_gridFinished = U_f_gridInt1(:,:,601:end);
             V_f_gridFinished = V_f_gridInt1(:,:,601:end);
             W_f_gridFinished = W_f_gridInt1(:,:,601:end);            
             
              save('turbGrid.mat','U_f_gridFinished','V_f_gridFinished','W_f_gridFinished','y')
             
             
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
            
            flowTSX = timeseries(tableForFlowSeriesX,timeVec);
            flowTSY = timeseries(tableForFlowSeriesY,timeVec);
            flowTSZ = timeseries(tableForFlowSeriesZ,timeVec);
            end
                    
