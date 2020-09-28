classdef AA_tetherSelectionTool < matlab.apps.AppBase
    
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
            

            createTabInputMT(app);
            %createTabPlots(app); 
            
            app.UIFigure.Visible = 'on';
            drawnow
            
        end
    end
        
    
    methods (Access = public)
        
        function updateTool(app)
            updateTabInputMT(app);
        end
        
        function app = AA_tetherSelectionTool
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