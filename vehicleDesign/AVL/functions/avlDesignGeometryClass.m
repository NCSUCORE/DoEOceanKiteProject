classdef avlDesignGeometryClass < handle
    properties
        % Input file names
        input_file_name        = 'inputFile.avl'; % File name for .avl file
        run_file_name          = 'testRunFile.run';
        exe_file_name          = 'exeFile';
        % Output file names
        result_file_name       = 'resultsFile';
        lookup_table_file_name = 'lookupTablesFile';
        
        % Name for design in the input file
        design_name            = 'designName'; % String at top of input file defining the name
        
        reference_point = [0.6;0;0];
        
        wing_chord = 1;
        wing_AR = 10;
        wing_sweep = 5;
        wing_dihedral = 2;
        wing_TR = 0.8;
        wing_incidence_angle = 0;
        wing_naca_airfoil = '2412';
        wing_airfoil_ClLimits = [-1.5 1.5];
        wing_CS_deflection_range = [-30 30];
        
        wing_Nspanwise = 20;
        wing_Nchordwise = 2;
        
        h_stab_LE = 4.5;
        h_stab_chord = 0.5;
        h_stab_AR = 4;
        h_stab_sweep = 10;
        h_stab_dihedral = 0;
        h_stab_TR = 0.8;
        h_stab_naca_airfoil = '2412';
        h_stab_airfoil_ClLimits = [-1.5 1.5];
        h_stab_CS_deflection_range = [-30 30];
        
        h_stab_Nspanwise = 5;
        h_stab_Nchordwise = 1;
        
        v_stab_LE = 4.5;
        v_stab_chord = 0.5;
        v_stab_AR = 2;
        v_stab_sweep = 10;
        v_stab_TR = 0.9;
        v_stab_naca_airfoil = '0015';
        v_stab_airfoil_ClLimits = [-2 2];
        v_stab_CS_deflection_range = [-30 30];

        v_stab_Nspanwise = 5;
        v_stab_Nchordwise = 1;
        
        singleCase = struct(...
            'alpha',0,....
            'beta',0,...
            'flap',0,...
            'aileron',0,...
            'elevator',0,...
            'rudder',0)
        
        sweepCase = struct(...
            'alpha',[-5 5],....
            'beta',[-5 5],...
            'flap',[-5 5],...
            'aileron',[-5 5],...
            'elevator',[-5 5],...
            'rudder',[-5 5])
    end
    properties (Dependent)
        wing_ip_file_name
        hs_ip_file_name
        vs_ip_file_name
        wing_span
        h_stab_span
        v_stab_span
        ref_area
        runResults
    end
    methods
        % Class constructor to get initial values
        function obj = avlDesignGeometryClass
            obj.h_stab_LE = 5*obj.wing_chord;
            obj.v_stab_LE = obj.h_stab_LE;
        end
        
        % Make sure the input file has the right file extension
        function val = get.input_file_name(obj)
            val = obj.input_file_name;
            if ~endsWith(obj.input_file_name,'.avl')
                val = [val '.avl'] ;
            end
        end
        
        % Make sure the run file has the right extension
        function val = get.run_file_name(obj)
            val = obj.run_file_name;
            if ~endsWith(obj.run_file_name,'.run')
                val = [val '.run'] ;
            end
        end
        
        % create more input file names
        function val = get.wing_ip_file_name(obj)
            val = obj.input_file_name;
            if endsWith(obj.input_file_name,'.avl')
                val = erase(val,'.avl');
            end
            val = strcat(val,'_wing.avl');
        end
        
        function val = get.hs_ip_file_name(obj)
            val = obj.input_file_name;
            if endsWith(obj.input_file_name,'.avl')
                val = erase(val,'.avl');
            end
            val = strcat(val,'_hs.avl');
        end
        
        function val = get.vs_ip_file_name(obj)
            val = obj.input_file_name;
            if endsWith(obj.input_file_name,'.avl')
                val = erase(val,'.avl');
            end
            val = strcat(val,'_vs.avl');
        end
        
        % Funtion defining how wing span depends on chord and AR
        function val = get.wing_span(obj)
            val = obj.wing_AR*obj.wing_chord;
        end
        % Function defining how horiz stab. span depends on chord and AR
        function val = get.h_stab_span(obj)
            val = obj.h_stab_AR*obj.h_stab_chord;
        end
        % Function defining how vert stab. span depends on chord and AR
        function val = get.v_stab_span(obj)
            val = obj.v_stab_AR*obj.v_stab_chord;
        end
        
        function val = get.ref_area(obj)
            val = obj.wing_AR*obj.wing_chord^2;
        end
        
        % Function to write geometry to an input file
        function writeInputFile(obj)
            avlCreateInputFile(obj)
        end
        
        
        % Function to plot the geometry
        function plot(obj,varargin)
            % Function to plot the design
            % Input parsin
            p = inputParser;
            % Create optional parameter to plot on last plot or plot on new
            % plot, default is new plot
            addParameter(p,'hold','off',@(x) any(validatestring(x,{'on','off'})))
            parse(p,varargin{:})
            
            if strcmpi(p.Results.hold,'on')
                hold on
            elseif strcmpi(p.Results.hold,'off')
                figure
            end
            
            
            % Plot the main wing
            % Port wing x and y points
            outline = [...
                0 0 0;...
                obj.wing_span*tand(obj.wing_sweep)/2 -obj.wing_span/2 tand(obj.wing_dihedral)*obj.wing_span/2;...
                obj.wing_span*tand(obj.wing_sweep)/2+obj.wing_TR*obj.wing_chord -obj.wing_span/2 tand(obj.wing_dihedral)*obj.wing_span/2;...
                obj.wing_chord 0 0;...
                0 0 0];
            plot3(outline(:,1),outline(:,2),outline(:,3),'LineWidth',2,'Color','k','LineStyle','-')
            hold on
            % Starboard wing x and y points
            outline = [...
                0 0 0;...
                obj.wing_span*tand(obj.wing_sweep)/2 obj.wing_span/2 tand(obj.wing_dihedral)*obj.wing_span/2;...
                obj.wing_span*tand(obj.wing_sweep)/2+obj.wing_TR*obj.wing_chord obj.wing_span/2 tand(obj.wing_dihedral)*obj.wing_span/2;...
                obj.wing_chord 0 0;...
                0 0 0];
            plot3(outline(:,1),outline(:,2),outline(:,3),'LineWidth',2,'Color','k','LineStyle','-')
            
            % Plot the horizontal stabilizer
            % Port x and y points
            outline = [...
                0 0 0;...
                obj.h_stab_span*tand(obj.h_stab_sweep)/2 -obj.h_stab_span/2 tand(obj.h_stab_dihedral)*obj.h_stab_span/2;...
                obj.h_stab_span*tand(obj.h_stab_sweep)/2+obj.h_stab_TR*obj.h_stab_chord   -obj.h_stab_span/2 0;...
                obj.h_stab_chord                                            0                  0;...
                0 0 0];
            
            % Translate backwards
            outline = outline + obj.h_stab_LE*[ones(5,1) zeros(5,2)];
            plot3(outline(:,1),outline(:,2),outline(:,3),'LineWidth',2,'Color','k','LineStyle','-')
            
            % Starboard x and y points
            outline = [...
                0 0 0;...
                obj.h_stab_span*tand(obj.h_stab_sweep)/2 obj.h_stab_span/2 tand(obj.h_stab_dihedral)*obj.h_stab_span/2;...
                obj.h_stab_span*tand(obj.h_stab_sweep)/2+obj.h_stab_TR*obj.h_stab_chord   obj.h_stab_span/2 tand(obj.h_stab_dihedral)*obj.h_stab_span/2;...
                obj.h_stab_chord                                            0                  0;...
                0 0 0];
            
            % Translate backwards
            outline = outline + obj.h_stab_LE*[ones(5,1) zeros(5,2)];
            plot3(outline(:,1),outline(:,2),outline(:,3),'LineWidth',2,'Color','k','LineStyle','-')
            
            % Plot the vertical stabilizer
            outline = [...
                0 0 0;...
                obj.v_stab_span*tand(obj.v_stab_sweep)                      0    obj.v_stab_span;...
                obj.v_stab_span*tand(obj.v_stab_sweep)+obj.v_stab_TR*obj.v_stab_chord     0    obj.v_stab_span;...
                obj.v_stab_chord                                            0                  0;...
                0 0 0];
            % Translate backwards
            outline = outline + obj.v_stab_LE*[ones(5,1) zeros(5,2)];
            plot3(outline(:,1),outline(:,2),outline(:,3),'LineWidth',2,'Color','k','LineStyle','-')
            
            % Plot the fuselage line
            plot3([0 obj.v_stab_LE],[0 0],[0 0],'LineWidth',2,'Color','k','LineStyle','-')
            
            scatter3(obj.reference_point(1),obj.reference_point(2),obj.reference_point(3),...
                'Marker','x','SizeData',72,'CData',[1 0 0]);
            
            axis equal
            grid on
        end
    end
end
