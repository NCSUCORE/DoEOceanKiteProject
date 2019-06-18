classdef aeroParamsClass < handle
    properties
        VS_LE
        VS_length
        VS_TR
        VS_sweep
        VS_span
        VS_chord
        VS_Sref
        Rvs_cm
        Sref
        HS_span
        HS_chord
        HS_Sref
        HS_LE
        pcl_mw
        pcd_mw
        pcm_mw
        pcl_VS
        pcd_VS
        pcm_VS
        CM_nom
        k_CM
        t_max
    end
    methods
        % Constructor, builds parts of the aerodynamic parameters that are
        % independent of the geometric parameters
        function obj = aeroParamsClass
            airfoil_data = readtable('naca0015data');
            airfoil_data = table2array(airfoil_data);
            
            % separate cd,cl and cm values
            alp = airfoil_data(:,1);
            cl = airfoil_data(:,2);
            cd = airfoil_data(:,3);
            cm = airfoil_data(:,5);
            
            obj.pcl_mw = simulinkProperty(polyfit(alp,0.9*cl,4));
            obj.pcd_mw = simulinkProperty(polyfit(alp,cd,4));
            obj.pcm_mw = simulinkProperty(polyfit(alp,cm,4));
            
            alp_n = linspace(-29,29,500);
            pcl_n = polyval(obj.pcl_mw.Value,alp_n);
            pcd_n = polyval(obj.pcd_mw.Value,alp_n);
            pcm_n = polyval(obj.pcm_mw.Value,alp_n);
            
            % use same rudder
            obj.pcl_VS = obj.pcl_mw;
            obj.pcd_VS = obj.pcd_mw;
            obj.pcm_VS = obj.pcm_mw;
            
            obj.CM_nom = simulinkProperty(-0.1,'Description','Roll moment coefficient');
            obj.k_CM   = simulinkProperty(0.6,'Description','No idea, WTF is this? - MC');
            obj.t_max  = simulinkProperty(0.15);
            
        end
        % Method to calculate aerodynamic parameters that depend on
        % geometric parameters.  Call this method once geometry has been
        % defined.
        function obj = setupGeometry(obj,geomParam)
            
            % symmetric airfoil thickness/chord
            t_max = obj.t_max.Value;
            
            % reference area
            Sref = geomParam.chord.Value*geomParam.span.Value;
            
            % horizontal stabilizer
            HS_LE = 4*geomParam.chord.Value;
            HS_chord = 0.25*geomParam.chord.Value;
            HS_AR = geomParam.AR.Value;
            HS_span = HS_chord*HS_AR;
            
            HS_Sref = HS_chord*HS_span;
            
            % Vertical stbilizer
            percent_VS = 1;
            VS_chord = percent_VS*HS_chord;
            VS_LE = HS_LE + (1 - percent_VS)*VS_chord;
            VS_AR = HS_AR/4;
            VS_span = VS_AR*VS_chord;
            VS_TR = 0.8;
            VS_sweep = 15;
            
            obj.VS_LE     = simulinkProperty(VS_LE);
            obj.VS_length = simulinkProperty(VS_span);
            obj.VS_TR     = simulinkProperty(VS_TR);
            obj.VS_sweep  = simulinkProperty(VS_sweep);
            obj.VS_chord  = simulinkProperty(VS_chord);
            obj.VS_span   = simulinkProperty(VS_span);
            
            obj = VS_and_HS_design_modified(obj,geomParam);
%             aeroRvs_cm = obj.Rvs_cm;
            
            VS_Sref = obj.VS_Sref;
            
            
            obj.HS_chord = simulinkProperty(HS_chord);
            obj.HS_span  = simulinkProperty(HS_span);
            obj.HS_LE = simulinkProperty(HS_LE);
            % store in structure
            obj.Sref = simulinkProperty(Sref);
            obj.HS_Sref = simulinkProperty(HS_Sref);
            
        end
        function obj = scale(obj,scaleFactor)
            obj = scaleObj(obj,scaleFactor);
        end
        
    end
    
end