close all;clear;clc;format compact

% Test 1: Surface in horizontal plane
aeroCenterVec     = [1 0 0];
spanRotationVec   = [0 1 0];
chordDirectionVec = [1 0 0];

ClFitParams = [5 0];
CdFitParams = [0.1 0 0.1];

refArea = 1;

dynPress = 1;

uAppBody = [1 0 0];
uAppBody = uAppBody/sqrt(sum(uAppBody.^2));

chord = 0.2;
span = 1;

defAng = 1*pi/180;

panel(:,1) = aeroCenterVec(:) + chord*chordDirectionVec(:)/2 + span*spanRotationVec(:)/2;
panel(:,2) = aeroCenterVec(:) + chord*chordDirectionVec(:)/2 - span*spanRotationVec(:)/2;
panel(:,3) = aeroCenterVec(:) - chord*chordDirectionVec(:)/2 - span*spanRotationVec(:)/2;
panel(:,4) = aeroCenterVec(:) - chord*chordDirectionVec(:)/2 + span*spanRotationVec(:)/2;
panel(:,5) = aeroCenterVec(:) + chord*chordDirectionVec(:)/2 + span*spanRotationVec(:)/2;

sim('aeroSurface_th')

figure('Position',[0    0.0370    1.0000    0.8917])
plot3(panel(1,:),panel(2,:),panel(3,:))
axis equal
view(-37.5000,30)
grid on
set(gca,'NextPlot','add')
scatter3(aeroCenterVec(1),aeroCenterVec(2),aeroCenterVec(3),'CData',[1 0 0])

plot3([aeroCenterVec(1)-uAppBody(1) aeroCenterVec(1)],...
      [aeroCenterVec(2)-uAppBody(2) aeroCenterVec(2)],...
      [aeroCenterVec(3)-uAppBody(3) aeroCenterVec(3)],...
    'Color','b')

plot3([aeroCenterVec(1) aeroCenterVec(1) + liftVec.Data(1)],...
      [aeroCenterVec(2) aeroCenterVec(2) + liftVec.Data(2)],...
      [aeroCenterVec(3) aeroCenterVec(3) + liftVec.Data(3)],...
      'Color','g')
  
plot3([aeroCenterVec(1) aeroCenterVec(1) + dragVec.Data(1)],...
      [aeroCenterVec(2) aeroCenterVec(2) + dragVec.Data(2)],...
      [aeroCenterVec(3) aeroCenterVec(3) + dragVec.Data(3)],...
      'Color','r')

quiver3(aeroCenterVec(1),aeroCenterVec(2),aeroCenterVec(3),spanRotationVec(1),spanRotationVec(2),spanRotationVec(3))
  
  
  
  
  