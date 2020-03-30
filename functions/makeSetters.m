function makeSetters(fileName)
%Turns a text file with each line being a property name (copy pasted from
%the list of properties) into a text file with the necessary setters. 
%WARNING: OVERWRITES FILE fileName
    fid=fopen(fileName,'r+');
    frewind(fid)
    flag=true;
    strlist=cell(0,1);
    while flag
        li = fgetl(fid);
        if li==-1
            flag=false;
        else
            li = strtrim(li);
            if ~isempty(li)
                strlist{end+1}=li; %#ok<AGROW>
            end
        end
        clear li
    end
    fclose(fid);
    fid=fopen(fileName,'w+');
    frewind(fid);
    for i=1:length(strlist)
        fprintf(fid,"function set%s%s(obj,val,units)\n",upper(strlist{i}(1)),strlist{i}(2:end));
        fprintf(fid,"    obj.%s.setValue(val,units)\n",strlist{i});
        fprintf(fid,"end\n\n");
    end
    fclose(fid);
end