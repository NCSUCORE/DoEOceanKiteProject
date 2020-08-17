function createTabOutputSFDT(app)
            createOutputVarsSFDT;
            
            T = 'SFDT';  
            
            fontSize = 20;
            width = 130; height = 25;
            x = 330; y = 700;
            
            app.Labels.SlidSwitch = uilabel(app.UITabs.(T));
            app.Labels.SlidSwitch.Text = 'Results';
            app.Labels.SlidSwitch.Position = [x y 320 30];
            app.Labels.SlidSwitch.FontSize = fontSize;
            
            y = y-40;
            
            for varind = 1:(length(varNamesSFDToutputs))
                % Creating labels for inputs boxes
                fontSize = 14;
                app.Labels.(varNamesSFDToutputs{varind}) = uilabel(app.UITabs.(T));
                app.Labels.(varNamesSFDToutputs{varind}).Text = varSFDToutputs.(varNamesSFDToutputs{varind}).symbol;
                app.Labels.(varNamesSFDToutputs{varind}).Position = [x y width+50 height];
                app.Labels.(varNamesSFDToutputs{varind}).FontSize = fontSize;
                
                
                x = x-5; y = y-25;
                % Creating input boxes
                app.InputBoxs.(varNamesSFDToutputs{varind}) = uieditfield(app.UITabs.(T),'numeric');
                app.InputBoxs.(varNamesSFDToutputs{varind}).Position = [x y width height];
                app.InputBoxs.(varNamesSFDToutputs{varind}).Limits = [varSFDToutputs.(varNamesSFDToutputs{varind}).min varSFDToutputs.(varNamesSFDToutputs{varind}).max];
                app.InputBoxs.(varNamesSFDToutputs{varind}).Value = varSFDToutputs.(varNamesSFDToutputs{varind}).default;
                app.InputBoxs.(varNamesSFDToutputs{varind}).FontSize = fontSize;
                
                x = x+5; y = y- 40;

            end
            
        end