function objsize=getSize(this) 

   props = properties(this); 
   if ~isempty(props)
       objsize = 0; 

       for ii=1:length(props)
          try
              subprops=properties(getfield(this, char(props(ii))));
              if ~isempty(subprops)
                  objsize=objsize+getSize(getfield(this, char(props(ii))));
              end
              currentProperty = getfield(this, char(props(ii))); 
              s = whos('currentProperty'); 
              objsize = objsize + s.bytes; 
          catch
          end
       end      
   else
       try
           s=evalin('caller',['whos(''' inputname(1) ''');']);
           objsize = s.bytes;
       catch
       end
   end
end