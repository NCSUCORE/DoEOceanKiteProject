function createTabOutputSWDT(app)
            listOutputVarsSWDT;
            
            T = 'SWDT';  
            
            fontSize = 20;
            width = 130; height = 25;
            x = 430; y = 700;
            
            app.Labels.SlidSwitch = uilabel(app.UITabs.(T));
            app.Labels.SlidSwitch.Text = 'Results';
            app.Labels.SlidSwitch.Position = [x y 320 30];
            app.Labels.SlidSwitch.FontSize = fontSize;
            
            y = y-40;
            
            for varind = 1:(length(varNamesSWDToutputs))
                % Creating labels for inputs boxes
                fontSize = 14;
                app.Labels.(varNamesSWDToutputs{varind}) = uilabel(app.UITabs.(T));
                app.Labels.(varNamesSWDToutputs{varind}).Text = varSWDToutputs.(varNamesSWDToutputs{varind}).symbol;
                app.Labels.(varNamesSWDToutputs{varind}).Position = [x y width+50 height];
                app.Labels.(varNamesSWDToutputs{varind}).FontSize = fontSize;
                
                
                x = x-5; y = y-25;
                % Creating input boxes
                app.InputBoxs.(varNamesSWDToutputs{varind}) = uieditfield(app.UITabs.(T),'numeric');
                app.InputBoxs.(varNamesSWDToutputs{varind}).Position = [x y width height];
                app.InputBoxs.(varNamesSWDToutputs{varind}).Limits = [varSWDToutputs.(varNamesSWDToutputs{varind}).min varSWDToutputs.(varNamesSWDToutputs{varind}).max];
                app.InputBoxs.(varNamesSWDToutputs{varind}).Value = varSWDToutputs.(varNamesSWDToutputs{varind}).default;
                app.InputBoxs.(varNamesSWDToutputs{varind}).FontSize = fontSize;
                
                x = x+5; y = y- 40;

            end
            
        end