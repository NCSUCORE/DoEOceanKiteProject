classdef ff
    %ff stands for figure functions
    methods(Static)
        function objList = findAllWithProp(obj,propName)
            %finds all of the graphics objects within obj that have the
            %property propName
            objList=gobjects(0);
            if isprop(obj,propName)
                objList(1)=obj;
            end
            subGraphics = findall(obj);
            subGraphics(~isprop(subGraphics,propName))=[];
            objList(end+1:end+length(subGraphics))=subGraphics;
            objList=objList(:);
        end
        
        function setAllProp(obj,propName,val)
            %Sets all graphics objects within obj that have the property
            %propName to the value val.
            objList=figfuncs.findAllWithProp(obj,propName);
            for i = 1:length(objList)
                objList(i).(propName) = val;
            end
        end
        
        function setAll(obj,searchProp,searchVal,propName,val)
            %uses findall with inputs 1-3, then applies sets their propName
            %to the value val.
            objList=findall(obj,searchProp,searchVal);
            for i = 1:length(objList)
                objList(i).(propName) = val;
            end
        end
        
        function holdOnAll(varargin)
            %Holds on all axes
            if nargin==0
                fig=gcf;
            else
                fig=varargin{1};
            end
            figfuncs.setAll(fig,"Type","axes","NextPlot","add");
        end
    end
end