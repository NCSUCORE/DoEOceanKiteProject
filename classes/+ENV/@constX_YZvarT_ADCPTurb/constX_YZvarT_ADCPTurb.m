classdef constX_YZvarT_ADCPTurb < dynamicprops
    %CONSTANT UNIVFORM FLOW
    
    properties (SetAccess = private)
        %         velVec
        density
        %         depth
        depthArray
        gravAccel
       
        startADCPTime
        endADCPTime
        %         flowType
        %         nominal100mFlowVec
        yBreakPoints
        TI
        f_min
        f_max
        P
        Q
        C
        N_mid_freq
        flowTSX
        flowTSY
        flowTSZ
    end
    
    properties (Access = private)
        adcp
    end
    
    methods
        
        %% contructor
        function obj = constX_YZvarT_ADCPTurb
            obj.gravAccel                   = SIM.parameter('Unit','m/s^2');
            obj.density                     = SIM.parameter('Unit','kg/m^3','NoScale',false);
            obj.startADCPTime               = SIM.parameter('Value',0,'Unit','s','NoScale',true);
            obj.endADCPTime                 = SIM.parameter('Value',inf,'Unit','s','NoScale',true);
            obj.yBreakPoints                = SIM.parameter('Unit','m','NoScale',true);
            obj.TI                          = SIM.parameter('Unit','');
            obj.f_min                       = SIM.parameter('Unit','Hz');
            obj.f_max                       = SIM.parameter('Unit','Hz');
            obj.P                           = SIM.parameter('Unit','');
            obj.Q                           = SIM.parameter('Unit','Hz');
            obj.C                           = SIM.parameter('Unit','');
            obj.N_mid_freq                  = SIM.parameter('Unit','');
            
            obj.adcp = ENV.ADCP;
        end
        
        function val = get.depthArray(obj)
            val = obj.adcp.depths;
        end
        
        function process(obj)
            val = obj.adcp.flowVecTSeries;
            val = getsampleusingtime(val,obj.startADCPTime.Value,obj.endADCPTime.Value);
            val.Time = val.Time-val.Time(1);
            tenMinTimeInterval =  ceil((val.Time(end)+600)/600);
            magDepth = [];
            selTime = permute(val.Data,[1 3 2]);
            for ii = 1:62
                magDepthT = sqrt(sum(selTime(:,:,ii).^2,2));
                
                %magnitude of xyz at each depth per time
                magDepth = [magDepth,magDepthT];
            end
            
            magDepthAVG = .5*(magDepth(1:end-1,:)+ magDepth(2:end,:));
            
            
            % create grid in the Y-Z plane
            y = obj.yBreakPoints.Value;
            % z = 140:5:200;% only for testing
            z = obj.adcp.depths;
            
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
            for iii = 1:tenMinTimeInterval
                for j  = 1:length(y)
                    U_meanTemp = magDepthAVG(iii,:)';
                    U_mean =  [U_mean;U_meanTemp];
                end
                turb_param = obj.turbulence_generator2(U_mean,...
                    obj.TI.Value,obj.f_min.Value,obj.f_max.Value,...
                    obj.P.Value,obj.Q.Value,obj.C.Value,...
                    obj.N_mid_freq.Value,pos_data);
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
                uf_int = NaN(1,obj.N_mid_freq.Value);
                vf_int = NaN(1,obj.N_mid_freq.Value);
                wf_int = NaN(1,obj.N_mid_freq.Value);
                
                uf = NaN(n_elem,n_steps);
                vf = NaN(n_elem,n_steps);
                wf = NaN(n_elem,n_steps);
                
                % calculation
                for i = 1:n_steps
                    
                    for j = 1:n_elem
                        for k = 1:obj.N_mid_freq.Value
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
            filePath = fullfile(fileparts(which('OCTProject.prj')),...
                'classes','+ENV','@constX_YZvarT_ADCPTurb','turbGrid.mat');
            save(filePath,'U_f_gridFinished','V_f_gridFinished','W_f_gridFinished','y')
            
        end
        
        function buildTimeseries(obj)
            filePath = fullfile(fileparts(which('OCTProject.prj')),...
                'classes','+ENV','@constX_YZvarT_ADCPTurb','turbGrid.mat');
            load(filePath)
            
            timeVec = 0:1:obj.endADCPTime.Value-1-obj.startADCPTime.Value ;
            val = obj.adcp.flowVecTSeries;
            val = getsampleusingtime(val,obj.startADCPTime.Value,obj.endADCPTime.Value);
            val.Time = val.Time-val.Time(1);
            selTime = permute(val.Data,[3,1,2]);
            tenMinTimeInterval =  ceil((val.Time(end)+600)/600);
            %%% adding to adcp data
            for iii = 1:length(obj.depthArray)
                vq = linspace(1,tenMinTimeInterval,tenMinTimeInterval*600);
                xDatForInterp = selTime(:,1,iii);
                yDatForInterp = selTime(:,2,iii);
                zDatForInterp = selTime(:,3,iii);
                interpedDataTimeX = interp1(xDatForInterp,vq);
                interpedDataTimeY = interp1(yDatForInterp,vq);
                interpedDataTimeZ = interp1(zDatForInterp,vq);
                interpedDataTime(:,:,iii) = [ interpedDataTimeX;interpedDataTimeY; interpedDataTimeZ];
            end
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
            obj.flowTSX = timeseries(tableForFlowSeriesX,timeVec);
            obj.flowTSY = timeseries(tableForFlowSeriesY,timeVec);
            obj.flowTSZ = timeseries(tableForFlowSeriesZ,timeVec);
        end
        
        
        %% Setters
        function setGravAccel(obj,val,unit)
            obj.gravAccel.setValue(val,unit);
        end
        
        function setDensity(obj,val,unit)
            obj.density.setValue(val,unit);
        end
        
        function setYBreakPoints(obj,val,unit)
            obj.yBreakPoints.setValue(val,unit);
        end
        
        function setStartADCPTime(obj,val,unit)
            obj.startADCPTime.setValue(val,unit);
        end
        
        function setEndADCPTime(obj,val,unit)
            obj.endADCPTime.setValue(val,unit);
        end
        function setTI(obj,val,unit)
            obj.TI.setValue(val,unit);
        end
        function setF_min(obj,val,unit)
            obj.f_min.setValue(val,unit);
        end
        function setF_max(obj,val,unit)
            obj.f_max.setValue(val,unit);
        end
        function setP(obj,val,unit)
            obj.P.setValue(val,unit);
        end
        function setQ(obj,val,unit)
            obj.Q.setValue(val,unit);
        end
        function setC(obj,val,unit)
            obj.C.setValue(val,unit);
        end
        function setN_mid_freq(obj,val,unit)
            obj.N_mid_freq.setValue(val,unit);
        end
        
        
        %% other methods
        % Function to scale the object
        function obj = scale(obj,lengthScaleFactor,densityScaleFactor)
            props = findAttrValue(obj,'SetAccess','public');
            for ii = 1:numel(props)
                obj.(props{ii}).scale(lengthScaleFactor,densityScaleFactor);
            end
        end
        val = turbulence_generator2(x1,x2,x3,x4,x5,x6,x7,x8,x9,x10);
        
    end
end