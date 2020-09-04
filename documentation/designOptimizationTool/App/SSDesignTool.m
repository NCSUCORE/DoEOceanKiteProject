classdef SSDesignTool < matlab.apps.AppBase
    %These properties correspond to app components
    %Kartik: Add components here
    properties (Access = public)
       UIFigure               matlab.ui.Figure
       UITabGroup             matlab.ui.container.TabGroup
       UITabs                 struct
       InputBoxs              struct
       Labels                 struct
       Sliders                struct
       SliderSwitch           struct
       DropDownBox            struct
       Buttons                struct
       PlotAxes               struct
       Plots                  struct
       ValueLabels            struct
       
       
        
    end
    
    methods (Access = private)
        
        function createComponents(app)
            warning('off','all');
            app.UITabs           = struct;
            app.InputBoxs        = struct;
            app.Labels           = struct;
            app.Sliders          = struct;
            app.SliderSwitch     = struct;
            app.DropDownBox      = struct;
            app.Buttons          = struct;
            app.PlotAxes         = struct;
            app.Plots            = struct;
            app.ValueLabels      = struct;
            
            %Create UIFigure
            app.UIFigure = uifigure('Visible','off');
            app.UIFigure.Name = 'Design Tool';
            app.UIFigure.Color = [1 1 1];
            app.UIFigure.Visible = 'off';
            app.UIFigure.WindowState = 'maximized';
            
          
            app.UITabGroup = uitabgroup(app.UIFigure);
            app.UITabGroup.Position = [20 20 1480 770];
            
            app.UITabs.('MT') = uitab(app.UITabGroup);
            app.UITabs.('MT').Title = 'Main Tab';
            
            
            app.UITabs.('SFOT') = uitab(app.UITabGroup);
            app.UITabs.('SFOT').Title = 'Steady Flight Optimization Tool';
            

            app.UITabs.('SWDT') = uitab(app.UITabGroup);
            app.UITabs.('SWDT').Title = 'Structual Wing Design Tool';
            
            app.UITabs.('SFDT') = uitab(app.UITabGroup);
            app.UITabs.('SFDT').Title = 'Structual Fuselage Design Tool';
            
            
            % Function for creating Tabs
            % 1) Input and Output blocks
            createTabInputMT(app);
            createTabInputSFOT(app);
            createTabInputSWDT(app);
            createTabInputSFDT(app);
            
            createTabOutputMT(app);
            createTabOutputSFOT(app);
            createTabOutputSWDT(app);
            createTabOutputSFDT(app);
            
            App_SetGlobVar(app)
            
            % Create Plots
            createTabPlots(app);
            
            app.UIFigure.Visible = 'on';

            drawnow

        end
    end
        
    
    methods (Access = public)
        
        function runOptimization(app)

            % Query list of output variables
            listOutputVarsMT;
            listOutputVarsSFOT;
            listOutputVarsSWDT;
            listOutputVarsSFDT;
            

            % Set input fields as global variables
            App_SetGlobVar(app)
            
            % Run optimization
            [Mtot, Mwing_opt,Mfuse_opt, AR_opt,Span_opt, D_opt,L_opt,...
                Wingdim,Power_out, NSp] = App_OverallKiteDesign()
            
            % Calculate optimal angle of attack
            [AoA_opt] = App_AoA_opt_calc(AR_opt,Span_opt,D_opt,L_opt);

            % Update output fields on MT
            app.InputBoxs.(varNamesMToutputs{1}).Value = Power_out;
            app.InputBoxs.(varNamesMToutputs{3}).Value = AR_opt;
            app.InputBoxs.(varNamesMToutputs{4}).Value = Span_opt;
            app.InputBoxs.(varNamesMToutputs{5}).Value = D_opt;
            app.InputBoxs.(varNamesMToutputs{6}).Value = L_opt;
            app.InputBoxs.(varNamesMToutputs{7}).Value = Mtot;
            app.InputBoxs.(varNamesMToutputs{8}).Value = AoA_opt;
            
            % Update output fields on SFOT
            app.InputBoxs.(varNamesSFOToutputs{1}).Value = AoA_opt;
            
            % Update output fields on SWDT
            app.InputBoxs.(varNamesSWDToutputs{1}).Value = Wingdim(1);
            
            if NSp == 0
            app.InputBoxs.(varNamesSWDToutputs{2}).Value = 0;
            app.InputBoxs.(varNamesSWDToutputs{3}).Value = 0;
            app.InputBoxs.(varNamesSWDToutputs{4}).Value = 0;
            
            elseif NSp == 1
            app.InputBoxs.(varNamesSWDToutputs{2}).Value = Wingdim(2);
            app.InputBoxs.(varNamesSWDToutputs{3}).Value = 0;
            app.InputBoxs.(varNamesSWDToutputs{4}).Value = 0;            
            
            elseif NSp == 2
            app.InputBoxs.(varNamesSWDToutputs{2}).Value = Wingdim(2);
            app.InputBoxs.(varNamesSWDToutputs{3}).Value = Wingdim(2);
            app.InputBoxs.(varNamesSWDToutputs{4}).Value = 0;
            
            elseif NSp == 3
            app.InputBoxs.(varNamesSWDToutputs{2}).Value = Wingdim(2);
            app.InputBoxs.(varNamesSWDToutputs{3}).Value = Wingdim(2);
            app.InputBoxs.(varNamesSWDToutputs{4}).Value = Wingdim(2);
            end
            

            
            % Updating plots on all tabs
            clearTabPlots(app);
            updateTabPlots(app,AR_opt,Span_opt,D_opt,L_opt,Wingdim, NSp);

            
            
        end
        
        function app = SSDesignTool
            createComponents(app)
            
            registerApp(app, app.UIFigure)
            
            if nargout == 0
                clear app
            end
        end
        
        % Code that executes before app deletion
        function delete(app)
            
            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
    
end