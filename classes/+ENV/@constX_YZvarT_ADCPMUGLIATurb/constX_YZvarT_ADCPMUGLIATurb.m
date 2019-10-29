classdef constX_YZvarT_ADCPMUGLIATurb 
    %Flow profile that's constant WRT x, but varies with Y and Z according
    %to the ADCP data with superimposed turbulence
    
    properties (SetAccess = private)
        density
        depthArray
        gravAccel
        startADCPTime
        endADCPTime
        yBreakPoints
        flowVecTSeries
        flowDirTSeries
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
        depthMin
        depthMax
    end
    
    properties (Access = private)
        adcp
    end
    
    methods
        
        %% contructor
        function obj = constX_YZvarT_ADCPMUGLIATurb
            obj.gravAccel                   = SIM.parameter('Unit','m/s^2');
            obj.density                     = SIM.parameter('Unit','kg/m^3','NoScale',false);
            obj.startADCPTime               = SIM.parameter('Value',0,'Unit','s','NoScale',true);
            obj.endADCPTime                 = SIM.parameter('Value',inf,'Unit','s','NoScale',true);
            obj.depthMin                    = SIM.parameter('Value',1,'Unit','','NoScale',true);
            obj.depthMax                    = SIM.parameter('Value',67,'Unit','','NoScale',true);
            obj.yBreakPoints                = SIM.parameter('Unit','m','NoScale',true);
            obj.TI                          = SIM.parameter('Unit','');
            obj.f_min                       = SIM.parameter('Unit','Hz');
            obj.f_max                       = SIM.parameter('Unit','Hz');
            obj.P                           = SIM.parameter('Unit','');
            obj.Q                           = SIM.parameter('Unit','Hz');
            obj.C                           = SIM.parameter('Unit','');
            obj.N_mid_freq                  = SIM.parameter('Unit','');
  
            obj.adcp = ENV.ADCPMUGLIA;
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
         function setDepthMin(obj,val,unit)
            obj.depthMin.setValue(val,unit);
         end
        function setDepthMax(obj,val,unit)
            obj.depthMax.setValue(val,unit);
         end
        

 function obj = setStartADCPTime(obj,val,unit)
            obj.startADCPTime.setValue(val,unit);
            
            if obj.startADCPTime.Value<=obj.endADCPTime.Value
                [vecTSeries,depths] = obj.adcp.crop(obj.startADCPTime.Value,obj.endADCPTime.Value,obj.depthMin.Value,obj.depthMax.Value);
                
                obj.flowVecTSeries = SIM.parameter(...
                    'Value',vecTSeries,...
                    'Unit' ,vecTSeries.DataInfo.Units);
                 obj.depthArray = SIM.parameter(...
                    'Value',depths,...
                    'Unit' , 'm');
            else
                error('Start time must be <= end time')
            end
        end
        function obj = setEndADCPTime(obj,val,unit)
            obj.endADCPTime.setValue(val,unit);
            if obj.startADCPTime.Value<=obj.endADCPTime.Value
                
                [vecTSeries,depths] = obj.adcp.crop(obj.startADCPTime.Value,obj.endADCPTime.Value,obj.depthMin.Value,obj.depthMax.Value);
                obj.flowVecTSeries = SIM.parameter(...
                    'Value',vecTSeries,...
                    'Unit' ,vecTSeries.DataInfo.Units);
                obj.depthArray = SIM.parameter(...
                    'Value',depths,...
                    'Unit' , 'm');
            else
                error('Start time must be <= end time')
            end
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
 
      
        
        
        % function to generate turbGrid.mat
        process(obj)
        
        % function to build timeseries from turbGrid.mat
       obj =  buildTimeseries(obj)
        
        % turbulence generator
        val = turbulence_generator2(x1,x2,x3,x4,x5,x6,x7,x8,x9,x10);
        %% other methods
        % Function to scale the object
        function obj = scale(obj,lengthScaleFactor,densityScaleFactor)
            props = findAttrValue(obj,'SetAccess','public');
            for ii = 1:numel(props)
                obj.(props{ii}).scale(lengthScaleFactor,densityScaleFactor);
            end
        end
        
         function makeTurbVid(obj,vidLength)
              colormap(jet);
              timeStep = 1;
              frame_rate = 10*1/timeStep;
              video = VideoWriter('vid_Test3', 'Motion JPEG AVI');
              video.FrameRate = frame_rate;
              num_frames = length(obj.flowTSX.time);
              
              mov(1:length(obj.flowTSX.time))=struct('cdata',[],'colormap',[]);
              set(gca,'nextplot','replacechildren')
              
              for i = 1:vidLength%length(env.water.flowTSY.time)
                  
                  figure(1)
                  colormap(jet);
                  contourf(obj.yBreakPoints.Value,obj.depthArray.Value,obj.flowTSX.data(:,:,i))
                  
                  
                  h1 = colorbar;
                  h1.Limits = [.8 2]
                  h1.Label.String= '[m/s]';
                  %     ('Ticks',1:0.2:1.8)
                  
                  xlabel('Y (m)')
                  ylabel('Depth (m)')
                  title(['U Component of Turbulent Flow at Y Z plane. Time = ',sprintf('%0.2f', obj.flowTSX.time(i)),' s'])
                  %     h1 = axis;
                  %     set(h1, 'Ydir', 'reverse')
                  ax6 = gca;
                  ax6.FontSize = 16;
                  %  h6.LineWidth = 1.5
                  %  h6.Color = [0, 0 ,0]
                  x0=100;
                  y0=100;
                  width=700;
                  height= 500;
                  set(gcf,'position',[x0,y0,width,height])
                  F(i) = getframe(gcf);
                  
              end
              
              
              open(video)
              for i = 1:length(F)
                  writeVideo(video, F(i));
              end
              close(video)
              
          end

    end
end