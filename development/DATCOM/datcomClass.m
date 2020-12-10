classdef datcomClass < handle
    
    properties (SetAccess = public)
        % $FLTCON
        machNumbers
        altitudes
        alphas
        Rnumbers
        loop
        
        % $OPTINS
        refArea
        longRefLength
        latRefLength
        
        % $SYNTHS
        xCG
        zCG
        xWing
        zWing
        incAngWing
        xHTail
        zHTail
        incAngHTail
        xVTail
        zVTail
        
        % $BODY
        fuselageXPositions
        fuselageRadii
        
        % WGPLNF
        wngTpChrd
        wngRtChrd
        wngSwpAng
        wngTwst
        wngDhdrl
        wngHlfSpn
        wngExpHlfSpn
        wngRefChrStn
        wngNACA
        
        % HTPLNF
        hTlTpChrd
        hTlRtChrd
        hTlSwpAng
        hTlTwst
        hTlDhdrl
        hTlHlfSpn
        hTlExpHlfSpn
        hTlRefChrStn
        hTlNACA
        
        % VTPLNF
        vTlTpChrd
        vTlRtChrd
        vTlSwpAng
        vTlTwst
        vTlDhdrl
        vTlHlfSpn
        vTlExpHlfSpn
        vTlRefChrStn
        vTlNACA
        
        % ASYFLP
        alrnLeftDfln
        alrnRightDfln
        alrnType
        alrnIbChrd
        alrnObChrd
        alrnIbSpan
        alrnObSpan
        alrnPhete
        struct
    end
    methods
        function obj = datcomClass
            % $FLTCON
            obj.machNumbers     = SIM.parameter('Value',0,'Unit','','Description','Freestreem mach numbers to charaterize (20 max)');
            obj.altitudes       = SIM.parameter('Unit','m','Description','Altitudes to loop over');
            obj.Rnumbers         = SIM.parameter('Unit','1/m','Description','Reynolds Number Per Unit Length');
            obj.alphas          = SIM.parameter('Unit','deg','Description','Angles of attack (20 max)');
            obj.loop            = SIM.parameter('Unit','','Description','Loopin condition, 1, 2, 3. See user manual.','NoScale',true);
            
            % $OPTINS
            obj.refArea         = SIM.parameter('Unit','m^2','Description','Optional, default = wing area, user man pg 29');
            obj.longRefLength   = SIM.parameter('Unit','m','Description','Longitudinal reference lengt, optional, default = mean aerodynamic chord, user man pg 29');
            obj.latRefLength    = SIM.parameter('Unit','m','Description','Lateral reference length, optional, default = wing span, user man pg 29');
            
            % $SYNTHS
            obj.xCG             = SIM.parameter('Unit','m','Description','X position of CG, starts at nose, moves back, user man pg 32');
            obj.zCG             = SIM.parameter('Unit','m','Description','Z position of CG, starts at nose, moves up, user man pg 32');
            obj.xWing           = SIM.parameter('Unit','m','Description','X position of wing apex point, starts at nose, moves back, user man pg 32');
            obj.zWing           = SIM.parameter('Unit','m','Description','Z position of wing apex point, starts at nose, moves up, user man pg 32');
            obj.incAngWing      = SIM.parameter('Unit','deg','Description','Angle of incidence of root chord of wing, user man pg 32');
            obj.xHTail          = SIM.parameter('Unit','m','Description','X position of horizontal tail, starts at nose, moves back, user man pg 32');
            obj.zHTail          = SIM.parameter('Unit','m','Description','Z position of horizontal tail, starts at nose, moves up, user man pg 32');
            obj.incAngHTail     = SIM.parameter('Unit','deg','Description','Angle of incidence of root chord of horizontal tail, user man pg 32');
            obj.xVTail          = SIM.parameter('Unit','m','Description','X position of vertical tail, starts at nose, moves back, user man pg 32');
            obj.zVTail          = SIM.parameter('Unit','m','Description','Z position of vertical tail, starts at nose, moves up, user man pg 32');
            obj.fuselageXPositions = SIM.parameter('Unit','m','Description','Positions along fuselage where radius is specified, user man pg 34');
            obj.fuselageRadii   = SIM.parameter('Unit','m','Description','List of fuselage radii at x positions specified in fuselageXPositions, man pg 42');
            
            % $WGPLNF
            obj.wngTpChrd       = SIM.parameter('Unit','m','Description','Main wing tip chord length,user man pg 36');
            obj.wngRtChrd       = SIM.parameter('Unit','m','Description','Main wing root chord length,user man pg 36');
            obj.wngSwpAng       = SIM.parameter('Unit','deg','Description','Main wing sweep angle ,user man pg 36');
            obj.wngTwst         = SIM.parameter('Unit','deg','Description','Main wing twist angle ,user man pg 36');
            obj.wngDhdrl        = SIM.parameter('Unit','deg','Description','Main wing dihedral angle ,user man pg 36');
            obj.wngHlfSpn       = SIM.parameter('Unit','m','Description','Main wing, half span, half of total wingspan,user man pg 36');
            obj.wngExpHlfSpn    = SIM.parameter('Unit','m','Description','Main wing, exposed span (half span minus amount covered by fuselage) ,user man pg 36');
            obj.wngRefChrStn    = SIM.parameter('Value',0.25,'Unit','','Description','Wing reference chord station?,user man pg 36');
            obj.wngNACA         = SIM.parameter('NoScale',true,'Description','Wing airfoil NACA code, 4 or 6 series.');
            
            % $HTPLNF
            obj.hTlTpChrd       = SIM.parameter('Unit','m','Description','Main wing tip chord length,user man pg 36');
            obj.hTlRtChrd       = SIM.parameter('Unit','m','Description','Main wing root chord length,user man pg 36');
            obj.hTlSwpAng       = SIM.parameter('Unit','deg','Description','Main wing sweep angle ,user man pg 36');
            obj.hTlTwst         = SIM.parameter('Unit','deg','Description','Main wing twist angle ,user man pg 36');
            obj.hTlDhdrl        = SIM.parameter('Unit','deg','Description','Main wing dihedral angle ,user man pg 36');
            obj.hTlHlfSpn       = SIM.parameter('Unit','m','Description','Main wing, half span, half of total wingspan,user man pg 36');
            obj.hTlExpHlfSpn    = SIM.parameter('Unit','m','Description','Main wing, exposed span (half span minus amount covered by fuselage) ,user man pg 36');
            obj.hTlRefChrStn    = SIM.parameter('Value',0.25,'Unit','','Description','Wing reference chord station?,user man pg 36');
            obj.hTlNACA         = SIM.parameter('NoScale',true,'Description','Wing airfoil NACA code, 4 or 6 series.');
            
            % $VTPLNF
            obj.vTlTpChrd       = SIM.parameter('Unit','m','Description','Main wing tip chord length,user man pg 36');
            obj.vTlRtChrd       = SIM.parameter('Unit','m','Description','Main wing root chord length,user man pg 36');
            obj.vTlSwpAng       = SIM.parameter('Unit','deg','Description','Main wing sweep angle ,user man pg 36');
            obj.vTlTwst         = SIM.parameter('Unit','deg','Description','Main wing twist angle ,user man pg 36');
            obj.vTlDhdrl        = SIM.parameter('Unit','deg','Description','Main wing dihedral angle ,user man pg 36');
            obj.vTlHlfSpn       = SIM.parameter('Unit','m','Description','Main wing, half span, half of total wingspan,user man pg 36');
            obj.vTlExpHlfSpn    = SIM.parameter('Unit','m','Description','Main wing, exposed span (half span minus amount covered by fuselage) ,user man pg 36');
            obj.vTlRefChrStn    = SIM.parameter('Value',0.25,'Unit','','Description','Wing reference chord station?,user man pg 36');
            obj.vTlNACA         = SIM.parameter('NoScale',true,'Description','Wing airfoil NACA code, 4 or 6 series.');
            
            % $ASYFLP
            obj.alrnLeftDfln    = SIM.parameter('Unit','deg','Description','Deflection Angle LH Flap');
            obj.alrnRightDfln   = SIM.parameter('Unit','deg','Description','Deflection Angle RH Flap');
            obj.alrnType        = SIM.parameter('Unit','','Description','CTRL Surface Type - 4 = Aileron, 5 = H Stab');
            obj.alrnIbChrd      = SIM.parameter('Unit','m','Description','Inboard Edge Chord Length measured parallel to long axis');
            obj.alrnObChrd      = SIM.parameter('Unit','m','Description','Outboard Edge Chord Length measured parallel to long axis');
            obj.alrnIbSpan      = SIM.parameter('Unit','m','Description','Inboard Edge Span Location measured perpindicular to vertical symmetry plane');
            obj.alrnObSpan      = SIM.parameter('Unit','m','Description','Outboard Edge Span Location measured perpindicular to vertical symmetry plane');
            obj.alrnPhete       = SIM.parameter('Unit','','Description','Tangent of airfoil trailing edge angle based on X/C = 0.9 and X/C = 0.99');
            
        end
        
        function run(obj)
            
            
            if isempty(obj.fuselageXPositions.Value)
                error('fuselageXPositions not specified');
            end
            if isempty(obj.fuselageRadii.Value)
                error('fuselageRadii not specified');
            end
            
            
            % Write input (.inp) file
            fileName = 'DSG.INP';
            if isfile(fileName)
                delete(fileName);
            end
            fid = fopen(fileName,'w');
            
            %             warning('Setting units to feet for debugging, remember to turn this off')
            if ~isempty(obj.machNumbers.Value)
                str = sprintf('DIM M\n $FLTCON NMACH=%.0f,MACH(1)=',numel(obj.machNumbers.Value));
                str = [str sprintf('%.4f$',obj.machNumbers.Value)];
%                 str = insertLineBreaks(str,74,',');
                fwrite(fid,str);
            end
            
            if ~isempty(obj.altitudes.Value)
                str = sprintf('\n $FLTCON NALT=%.3f,ALT(1)=',numel(obj.altitudes.Value));
                str = [str sprintf('%.3f$',obj.altitudes.Value)];
%                 str = insertLineBreaks(str,74,',');
                fwrite(fid,str);
            end
            
            if ~isempty(obj.alphas.Value)
                str = sprintf('\n $FLTCON NALPHA=%.3f,ALSCHD(1)=',numel(obj.alphas.Value));
                str = [str sprintf('%.3f,',obj.alphas.Value)];
                str = [str sprintf('$')];
%                 str = insertLineBreaks(str,74,',');
                fwrite(fid,str);
            end
            
            if ~isempty(obj.loop.Value)
                str = [str sprintf('\n $FLTCON LOOP=%.0f$',obj.loop.Value)];
                fwrite(fid,str);
            end
            
            if ~isempty(obj.Rnumbers.Value)
                str = sprintf('\n $FLTCON RNNUB(1)=%s$',obj.Rnumbers.Value);
%                 str = insertLineBreaks(str,74,',');
                fwrite(fid,str);
            end
            
            if ~isempty(obj.refArea.Value) ...
                    || ~isempty(obj.latRefLength.Value) ...
                    || ~isempty(obj.longRefLength.Value) ...
                    
                str = sprintf('\n $OPTINS ');
                if ~isempty(obj.refArea.Value)
                    str = [str sprintf('SREF=%.3f,',obj.refArea.Value)];
                end
                if ~isempty(obj.longRefLength.Value)
                    str = [str sprintf('CBARR=%.3f,',obj.longRefLength.Value)];
                end
                if ~isempty(obj.latRefLength.Value)
                    str = [str sprintf('BLREF=%.3f,',obj.latRefLength.Value)];
                end
                str(end) = '$';
%                 str = insertLineBreaks(str,74,',');
                fwrite(fid,str);
            end
            
            % $SYNTHS
            str = sprintf('\n $SYNTHS ');
            if ~isempty(obj.xCG.Value)
                str = [str sprintf('XCG=%.3f,' ,obj.xCG.Value)];
            else
                warning('xCG not specified')
            end
            
            %             fprintf(fid,'ZCG=%.3f ' ,obj.zCG.Value);
            if ~isempty(obj.zCG.Value)
                str = [str sprintf('ZCG=%.3f,' ,obj.zCG.Value)];
            else
                warning('zCG not specified')
            end
            
            %             fprintf(fid,'XW=%.3f '  ,obj.xWing.Value);
            if ~isempty(obj.xCG.Value)
                str = [str sprintf('XW=%.3f,' ,obj.xWing.Value)];
            else
                warning('xWing not specified')
            end
            
            %             fprintf(fid,'ZW=%.3f '  ,obj.zWing.Value);
            if ~isempty(obj.zWing.Value)
                str = [str sprintf('ZW=%.3f,' ,obj.zWing.Value)];
            else
                warning('zWing not specified')
            end
            
            %             fprintf(fid,'ALIW=%.3f ',obj.incAngWing.Value);
            if ~isempty(obj.incAngWing.Value)
                str = [str sprintf('ALIW=%.3f,' ,obj.incAngWing.Value)];
            else
                warning('incAngWing not specified')
            end
            
            %             fprintf(fid,'XH=%.3f '  ,obj.xHTail.Value);
            if ~isempty(obj.xHTail.Value)
                str = [str sprintf('XH=%.3f,\n    ' ,obj.xHTail.Value)];
            else
                warning('xHTail not specified')
            end
            
            %             fprintf(fid,'ZH=%.3f '  ,obj.zHTail.Value);
            if ~isempty(obj.zHTail.Value)
                str = [str sprintf('ZH=%.3f,' ,obj.zHTail.Value)];
            else
                warning('zHTail not specified')
            end
            
            %             fprintf(fid,'ALIH=%.3f ',obj.incAngHTail.Value);
            if ~isempty(obj.incAngHTail.Value)
                str = [str sprintf('ALIH=%.3f,' ,obj.incAngHTail.Value)];
            else
                warning('incAngHTail not specified')
            end
            
            %             fprintf(fid,'XV=%.3f '  ,obj.xVTail.Value);
            if ~isempty(obj.xVTail.Value)
                str = [str sprintf('XV=%.3f,' ,obj.xVTail.Value)];
            else
                warning('xVTail not specified')
            end
            
            %             fprintf(fid,'ZV=%.3f '  ,obj.zVTail.Value);
            if ~isempty(obj.zVTail.Value)
                str = [str sprintf('ZV=%.3f,' ,obj.zVTail.Value)];
            else
                warning('zVTail not specified')
            end
            str = [str  sprintf('VERTUP=.TRUE.$')];
%             str = insertLineBreaks(str,74,',');
            fprintf(fid,str);
            
            
            % $BODY
            str = sprintf('\n $BODY NX=%.3f,',numel(obj.fuselageXPositions.Value)+1);
            fprintf(fid,str);
            
            str = sprintf('\n    X(1)=');
            str = [str sprintf('%.3f,',obj.fuselageXPositions.Value)];
%             str = insertLineBreaks(str,74,',');
            fprintf(fid,str);
            
            str = sprintf('\n    R(1)=');
            str = [str sprintf('%.3f,',obj.fuselageRadii.Value)];
            str = [str sprintf('\n    METHOD=2.0$')]; % Jorgensen method
%             str(end) = '$';
%             str = insertLineBreaks(str,74,',');
            fprintf(fid,str);
            
            
            
            % $WGPLNF
            str = sprintf('\n $WGPLNF ');
            str = [str sprintf('CHRDTP=%.3f,\n    '       ,obj.wngTpChrd.Value)];
            str = [str sprintf('SSPNE=%.3f,\n    '        ,obj.wngExpHlfSpn.Value)];
            str = [str sprintf('SSPN=%.3f,\n    '         ,obj.wngHlfSpn.Value)];
            str = [str sprintf('CHRDR=%.3f,\n    '        ,obj.wngRtChrd.Value)];
            str = [str sprintf('SAVSI=%.3f,\n    '        ,obj.wngSwpAng.Value)];
            str = [str sprintf('CHSTAT=%.3f,\n    '       ,obj.wngRefChrStn.Value)];
            str = [str sprintf('TWISTA=%.3f,\n    '       ,obj.wngTwst.Value)];
            str = [str sprintf('DHDADI=%.3f,\n    '       ,obj.wngDhdrl.Value)];
            str = [str sprintf('TYPE=1.0$\nNACA-W-%.0f-%s'  ,numel(obj.wngNACA.Value),upper(obj.wngNACA.Value))];
%             str = insertLineBreaks(str,74,',');
            fprintf(fid,str);
            
            % $HTPLNF
            if ~isempty(obj.hTlHlfSpn.Value)
                str = sprintf('\n $HTPLNF ');
                str = [str sprintf('CHRDTP=%.3f,\n    '       ,obj.hTlTpChrd.Value)];
                str = [str sprintf('SSPNE=%.3f,\n    '        ,obj.hTlExpHlfSpn.Value)];
                str = [str sprintf('SSPN=%.3f,\n    '         ,obj.hTlHlfSpn.Value)];
                str = [str sprintf('CHRDR=%.3f,\n    '        ,obj.hTlRtChrd.Value)];
                str = [str sprintf('SAVSI=%.3f,\n    '        ,obj.hTlSwpAng.Value)];
                str = [str sprintf('CHSTAT=%.3f,\n    '       ,obj.hTlRefChrStn.Value)];
                str = [str sprintf('TWISTA=%.3f,\n    '       ,obj.hTlTwst.Value)];
                str = [str sprintf('DHDADI=%.3f,\n    '       ,obj.hTlDhdrl.Value)];
                str = [str sprintf('TYPE=1.0$\nNACA-H-%.0f-%s'  ,numel(obj.hTlNACA.Value),upper(obj.hTlNACA.Value))];
                %             str = insertLineBreaks(str,74,',');
                fprintf(fid,str);
            end
            
            % $VTPLNF
            if ~isempty(obj.vTlHlfSpn.Value)
                str = sprintf('\n $VTPLNF ');
                str = [str sprintf('CHRDTP=%.3f,\n    '       ,obj.vTlTpChrd.Value)];
                str = [str sprintf('SSPNE=%.3f,\n    '        ,obj.vTlExpHlfSpn.Value)];
                str = [str sprintf('SSPN=%.3f,\n    '         ,obj.vTlHlfSpn.Value)];
                str = [str sprintf('CHRDR=%.3f,\n    '        ,obj.vTlRtChrd.Value)];
                str = [str sprintf('SAVSI=%.3f,\n    '        ,obj.vTlSwpAng.Value)];
                str = [str sprintf('CHSTAT=%.3f,\n    '       ,obj.vTlRefChrStn.Value)];
                str = [str sprintf('TWISTA=%.3f,\n    '       ,obj.vTlTwst.Value)];
                str = [str sprintf('DHDADI=%.3f,\n    '       ,obj.vTlDhdrl.Value)];
                str = [str sprintf('TYPE=1.0$\nNACA-V-%.0f-%s'  ,numel(obj.vTlNACA.Value),upper(obj.vTlNACA.Value))];
                %             str = insertLineBreaks(str,74,',');
                fprintf(fid,str);
            end
            % $ASYFLP
            str = sprintf('\n $ASYFLP ');
            str = [str sprintf('CHRDFI=%.3f,\n    '       ,obj.alrnIbChrd.Value)];
            str = [str sprintf('CHRDFO=%.3f,\n    '       ,obj.alrnObChrd.Value)];
            str = [str sprintf('SPANFI=%.3f,\n    '       ,obj.alrnIbSpan.Value)];
            str = [str sprintf('SPANFO=%.3f,\n    '       ,obj.alrnObSpan.Value)];
            str = [str sprintf('NDELTA=%.1f, DELTAL(1)='       ,numel(obj.alrnLeftDfln.Value))];
            str = [str sprintf('%.1f,',obj.alrnLeftDfln.Value)];
            str = [str sprintf('\n                 DELTAR(1)=')];
            str = [str sprintf('%.1f,',obj.alrnRightDfln.Value)];
            str = [str sprintf('\n    ')];
            str = [str sprintf('PHETE=%.3f,\n    '       ,obj.alrnPhete.Value)];
            str = [str sprintf('STYPE=%.1f,\n    '       ,obj.alrnType.Value)];
            fprintf(fid,str);
            
            
            
            fprintf(fid,'\nCASEID PLAINFLAP ANALYSIS \nSAVE \nNEXT CASE');
            
            fclose(fid);
            
            % Do this
            !datcom &
            % https://stackoverflow.com/questions/15313469/java-keyboard-keycodes-list/31637206
            rbt = java.awt.Robot
            % Type DSG.INP
            rbt.keyPress(68)
            rbt.keyPress(83)
            rbt.keyPress(71)
            rbt.keyPress(46)
            rbt.keyPress(73)
            rbt.keyPress(78)
            rbt.keyPress(80)
            rbt.keyPress(10)
            % Type exit
            rbt.keyPress(69)
            rbt.keyPress(88)
            rbt.keyPress(73)
            rbt.keyPress(84)
            rbt.keyPress(10)
            
            % Or possibly this
            %             !datcom<DSG.INP &
            alldata = datcomimport('datcom.out')%, true, 0);
            obj.struct = alldata{1};
            data = alldata{1};
            
            aerotab = {'cyb' 'cnb' 'clq' 'cmq'};
            
            for k = 1:length(aerotab)
                for m = 1:data.nmach
                    for h = 1:data.nalt
                        data.(aerotab{k})(:,m,h) = data.(aerotab{k})(1,m,h);
                    end
                end
            end
            h1 = figure;
            figtitle = {'Lift Curve' ''};
            for k=1:2
                subplot(2,1,k)
                plot(data.alpha,permute(data.cl(:,k,:),[1 3 2]))
                grid
                ylabel(['Lift Coefficient (Mach =' num2str(data.mach(k)) ')'])
                title(figtitle{k});
            end
            xlabel('Angle of Attack (deg)')
            
            h2 = figure;
            figtitle = {'Drag Polar' ''};
            for k=1:2
                subplot(2,1,k)
                plot(permute(data.cd(:,k,:),[1 3 2]),permute(data.cl(:,k,:),[1 3 2]))
                grid
                ylabel(['Lift Coefficient (Mach =' num2str(data.mach(k)) ')'])
                title(figtitle{k})
            end
            xlabel('Drag Coefficient')
            
            h3 = figure;
            figtitle = {'Pitching Moment' ''};
            for k=1:2
                subplot(2,1,k)
                plot(permute(data.cm(:,k,:),[1 3 2]),permute(data.cl(:,k,:),[1 3 2]))
                grid
                ylabel(['Lift Coefficient (Mach =' num2str(data.mach(k)) ')'])
                title(figtitle{k})
            end
            xlabel('Pitching Moment Coefficient')
            
        end
    end
end