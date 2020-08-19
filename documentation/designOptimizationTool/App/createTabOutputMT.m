function createTabOutputMT(app)
            listOutputVarsMT;
            
            T = 'MT';  
            
            fontSize = 20;
            width = 130; height = 25;
            x = 430; y = 700;
            
            app.Labels.SlidSwitch = uilabel(app.UITabs.(T));
            app.Labels.SlidSwitch.Text = 'Results';
            app.Labels.SlidSwitch.Position = [x y 320 30];
            app.Labels.SlidSwitch.FontSize = fontSize;
            
            y = y-40;
            
            for varind = 1:(length(varNamesMToutputs))
                % Creating labels for outbox boxes
                fontSize = 14;
                app.Labels.(varNamesMToutputs{varind}) = uilabel(app.UITabs.(T));
                app.Labels.(varNamesMToutputs{varind}).Text = join([varMToutputs.(varNamesMToutputs{varind}).symbol,' (',varMToutputs.(varNamesMToutputs{varind}).unit,')']);
                app.Labels.(varNamesMToutputs{varind}).Position = [x y width+50 height];
                app.Labels.(varNamesMToutputs{varind}).FontSize = fontSize;
                
                
                x = x-5; y = y-25;
                % Creating output boxes and initilize
                app.InputBoxs.(varNamesMToutputs{varind}) = uieditfield(app.UITabs.(T),'numeric');
                app.InputBoxs.(varNamesMToutputs{varind}).Position = [x y width height];
                app.InputBoxs.(varNamesMToutputs{varind}).Limits = [varMToutputs.(varNamesMToutputs{varind}).min varMToutputs.(varNamesMToutputs{varind}).max];
                app.InputBoxs.(varNamesMToutputs{varind}).Value = varMToutputs.(varNamesMToutputs{varind}).default;
                app.InputBoxs.(varNamesMToutputs{varind}).FontSize = fontSize;
                app.InputBoxs.(varNamesMToutputs{varind}).Editable = varMToutputs.(varNamesMToutputs{varind}).Editable;
                app.InputBoxs.(varNamesMToutputs{varind}).BackgroundColor = varMToutputs.(varNamesMToutputs{varind}).BackgroundColor;
                
                x = x+5; y = y- 40;

            end
            
        end