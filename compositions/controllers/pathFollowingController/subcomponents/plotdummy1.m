phis=[.1,.4,.6,.9];
lams=[-.8,-.3,.3,.8];
end_time = 80;
aB=1;
bB=1;
phi_curve=.5;
locs=cell(15,1);
for i=1:length(phis)
    for j=1:length(lams)
        p=phis(i);
        l=lams(j);
        disp(i)
        disp(j)
        sphere_loc = [ cos(l).*cos(p);
                  sin(l).*cos(p);
                  sin(p);];
        init_pos = [sphere_loc(1);sphere_loc(2);sphere_loc(3);];
        init_pos = init_pos/norm(init_pos);
        sim('courseFollow_plant_th')
        logs=parseLogsout;
        locs{length(lams)*(i-1) + j,:,:}=squeeze(logs.pos.Data);
    end
end
lamda=@(s) aB*sin(s)./(1+(aB/bB)^2*cos(s).^2);
phi=@(s) (aB/bB)^2*sin(s).*cos(s)./(1 + (aB/bB)^2*cos(s).^2);
path = @(s)[cos(lamda(s)).*cos(phi_curve+phi(s));...
            sin(lamda(s)).*cos(phi_curve+phi(s));...
            sin(phi_curve+phi(s));];
        %%
figure
ax=axes;
[x, y, z] = sphere;
h = surfl(x, y, z); 
set(h, 'FaceAlpha', 0.5)
shading(ax,'interp')
hold on
pathvals=path(0:.01:2*pi);
plot3(pathvals(1,:),pathvals(2,:),pathvals(3,:),'lineWidth',3)
view(90,30)
for i=1:size(locs,1)
    hold on
    plot3(locs{i}(:,1),locs{i}(:,2),locs{i}(:,3),'k','lineWidth',1.5)
end