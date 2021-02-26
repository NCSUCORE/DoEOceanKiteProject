%%  Script to generate static Munk Moment lookup table
loadComponent('Manta2RotXFoil_AR8_b8');                         %   Load new vehicle with 2 rotors
pitch = -20:20;
flwSpd = 0.05:0.1:4;
tic
for ii = 1:numel(flwSpd)
    for jj = 1:numel(pitch)
        vFlow = [flwSpd(ii);0;0];
        vGrad = zeros(3,6);   vGrad(1,:) = flwSpd(ii);
        eul = [0;pitch(jj);0]*pi/180;
        sim('AddedMassTest')
        Munk.F(ii,jj,:) = Fadd;
        Munk.M(ii,jj,:) = Madd;
    end
    ii
end
toc
Munk.vFlow = flwSpd;    Munk.pitch = pitch;
save('MunkMoments.mat','Munk')
%%
figure; subplot(2,1,1);
surf(Munk.pitch,Munk.vFlow,squeeze(Munk.M(:,:,2))*1e-3,'edgecolor','none');
xlabel('Pitch [deg]');  ylabel('Flow Speed [m/s]');  zlabel('Munk Moment [kNm]')
subplot(2,1,2);
contourf(Munk.pitch,Munk.vFlow,squeeze(Munk.M(:,:,2))*1e-3,30,'edgecolor','none');
xlabel('Pitch [deg]');  ylabel('Flow Speed [m/s]');  colorbar;
set(gcf,'OuterPosition',[-5.4000   34.6000  700.0000  830.4000]);
