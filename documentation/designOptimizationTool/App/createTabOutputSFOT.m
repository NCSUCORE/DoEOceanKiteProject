function createTabOutputSFOT(app)
            listOutputVarsSFOT;
            
            T = 'SFOT';  
            
            fontSize = 20;
            width = 130; height = 25;
            x = 430; y = 700;
            
            app.Labels.SlidSwitch = uilabel(app.UITabs.(T));
            app.Labels.SlidSwitch.Text = 'Results';
            app.Labels.SlidSwitch.Position = [x y 320 30];
            app.Labels.SlidSwitch.FontSize = fontSize;
            
            y = y-40;
            
            for varind = 1:(length(varNamesSFOToutputs))
                % Creating labels for inputs boxes
                fontSize = 14;
                app.Labels.(varNamesSFOToutputs{varind}) = uilabel(app.UITabs.(T));
                app.Labels.(varNamesSFOToutputs{varind}).Text = join([varSFOToutputs.(varNamesSFOToutputs{varind}).symbol,' (',varSFOToutputs.(varNamesSFOToutputs{varind}).unit,')']);
                app.Labels.(varNamesSFOToutputs{varind}).Position = [x y width+50 height];
                app.Labels.(varNamesSFOToutputs{varind}).FontSize = fontSize;
                
                
                x = x-5; y = y-25;
                % Creating input boxes
                app.InputBoxs.(varNamesSFOToutputs{varind}) = uieditfield(app.UITabs.(T),'numeric');
                app.InputBoxs.(varNamesSFOToutputs{varind}).Position = [x y width height];
                app.InputBoxs.(varNamesSFOToutputs{varind}).Limits = [varSFOToutputs.(varNamesSFOToutputs{varind}).min varSFOToutputs.(varNamesSFOToutputs{varind}).max];
                app.InputBoxs.(varNamesSFOToutputs{varind}).Value = varSFOToutputs.(varNamesSFOToutputs{varind}).default;
                app.InputBoxs.(varNamesSFOToutputs{varind}).FontSize = fontSize;
                app.InputBoxs.(varNamesSFOToutputs{varind}).Editable = varSFOToutputs.(varNamesSFOToutputs{varind}).Editable;
                app.InputBoxs.(varNamesSFOToutputs{varind}).BackgroundColor = varSFOToutputs.(varNamesSFOToutputs{varind}).BackgroundColor;              
                
                x = x+5; y = y- 40;

            end
            
        end