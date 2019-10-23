function saveClass(obj,fulltxtFilePath,name)
    FID=fopen(fulltxtFilePath,'w+');    
    if nargin ==3
        cycleProps(FID,name,obj);
    elseif ~isempty(inputname(1))
        cycleProps(FID,inputname(1),obj);
    elseif nargin == 2 && isempty(inputname(1))
        cycleProps(FID,'obj',obj);
    end
    proj=slproject.getCurrentProject;
    addFile(proj,fulltxtFilePath);
    fclose(FID);
end

function cycleProps(FID,name,obj)
    props = properties(obj);
    if isempty(props)
        saveline(FID,name,obj);
    else
        for i=1:length(props)
            newobj = getfield(obj,props{i});
            if isempty(properties(newobj))
                saveline(FID,[name '.' char(props{i})],newobj);
            else
                cycleProps(FID,[name '.' char(props{i})],newobj)
            end
        end
    end
end

function saveline(FID,name,obj)
    objsize = getSize(obj);
    try
        if ~isempty(obj)
            if objsize > 1000
                fprintf(FID,'%s is too big to display and takes up %.4e bytes\n',name,getSize(obj));
            elseif class(obj)=="char" || class(obj)=="string"
                fprintf(FID,'%s = ''%s''\n',name,obj);
            elseif isnumeric(obj) && max(size(obj))==1
                fprintf(FID,'%s = %.4e\n',name,obj);
            elseif isnumeric(obj) 
                fprintf(FID,'%s = %s\n',name,mat2str(obj));
            elseif islogical(obj)
                if obj
                    val="true";
                else
                    val="false";
                end
                fprintf(FID,'%s = %s\n',name,val);
            else
                fprintf(FID,'%s is non-string and non-numeric and takes up %.4e bytes\n',name,getSize(obj));
            end
        end
    catch
        fprintf(FID,'%s could not display and takes up %.4e bytes\n',name,getSize(obj));
    end
end