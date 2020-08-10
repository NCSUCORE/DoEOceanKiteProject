%loadComponent('Manta2RotNACA2412');   
%path = uigetdir;
files = dir(path);

wingParaSW = ["rootChord","NACACamberedAirfoil","incidenceAngle",...
    "aspectRatio","taperRatio","sweepAngle","dihedral"];
wingParaMAT = {vhcl.wingRootChord.Value,...
    strrep(vhcl.wingAirfoil.Value,"NACA",""),...
    vhcl.wingIncidence.Value,vhcl.wingAR.Value,vhcl.wingTR.Value,...
    vhcl.wingSweep.Value,vhcl.wingDihedral.Value}
hStabParaSW = ["rootChord","NACAairfoil","incidentAngle",...
    "aspectRatio","taperRatio","sweepAngle"];
hStabParaMAT = {vhcl.hStab.rootChord.Value,...
    strrep(vhcl.hStab.Airfoil.Value,"NACA",""),...
    vhcl.hStab.incidence.Value,vhcl.hStab.AR.Value,vhcl.hStab.TR.Value,...
    vhcl.hStab.sweep.Value}
vStabParaSW = ["rootChord","NACAairfoil","incidentAngle",...
    "aspectRatio","taperRatio","sweepAngle"];
vStabParaMAT = {vhcl.vStab.rootChord.Value,...
    strrep(vhcl.vStab.Airfoil.Value,"NACA",""),...
    vhcl.vStab.incidence.Value,vhcl.vStab.AR.Value,vhcl.vStab.TR.Value,...
    vhcl.vStab.sweep.Value}

j=1;
for k = 1 : length(files)
    if endsWith(files(k).name,".txt")
        cntrFiles(j).name = files(k).name;
        j=j+1;
    end
end

for j = 1 : length(cntrFiles)
    fullName = strcat(path,"\",cntrFiles(j).name);
    fid = fopen(fullName,'r');
    i = 1;
    tline = fgetl(fid);
    A{i} = tline;
    while ischar(tline)
        i = i+1;
        tline = fgetl(fid);
        A{i} = tline;
    end
    fclose(fid);

    if contains(cntrFiles(j).name,"wing") == 1
    k=1
    for i = 1:numel(A)
        if A{i+1} == -1 | k > length(wingParaSW) 
            break
        elseif contains(A{i},wingParaSW(k)) == 1
            A{i} = char(strcat(wingParaSW(k),"= ",num2str(wingParaMAT{k})));
            k=k+1;
        end
    end
    end

    if contains(cntrFiles(j).name,"hStab") == 1
    k=1
    for i = 1:numel(A)
        if A{i+1} == -1 | k > length(hStabParaSW) 
            break
        elseif contains(A{i},hStabParaSW(k)) == 1
            A{i} = char(strcat(hStabParaSW(k),"= ",num2str(hStabParaMAT{k})));
            k=k+1;
        end
    end
    end
    
    if contains(cntrFiles(j).name,"vStab") == 1
    k=1
    for i = 1:numel(A)
        if A{i+1} == -1 | k > length(vStabParaSW) 
            break
        elseif contains(A{i},vStabParaSW(k)) == 1
            A{i} = char(strcat(vStabParaSW(k),"= ",num2str(vStabParaMAT{k})));
            k=k+1;
        end
    end
    end
    
    fid = fopen(fullName, 'w');
    for i = 1:numel(A)
        if A{i+1} == -1
            fprintf(fid,'%s', A{i});
            break
        else
            fprintf(fid,'%s\n', A{i});
            A{i}
        end
    end
    fclose(fid)
    clear A
end