%% Plot Any Four Bar Linkage
%% Mohammad Y. Saadeh May, 10, 2010, University of Nevada Las Vegas
clc;clear;close all
figure('Position',[100 100 700 250]); hold on; grid on;
for linkage = 1:2; %1 for el 2 for vStab
%Reworked Tailcone
% if linkage == 1 %Elevator
%     X =   [12.7 23.5 36.3 33.3 0 0];
%     offset = 135.11;
% elseif linkage == 2 %Vertical Stabilizer
%     X = [12.7 26.8 25.4 29.7 0 0];
%     offset = 115.53; 
% end
%Old Tailcone
if linkage == 1 %Elevator
    X =   [9.2 23.2 23.6+9.2 33.1 0 0];
    offset = 135.49;
elseif linkage == 2 %Vertical Stabilizer
    X = [22 26.9 34.1 29.5 0 0];
    offset = 114.22; 
end
% X =   [180 100 185 220 55 0];
% X = [r1  r2  r3  r4  Cx  Cy ];
% r1: Crank (make sure its always the smallest, also r3+r4>=r1+r2)
% r2: Coupler
% r3: Lever (Rocker)
% r4: Frame
% Cu: x coordinate for coupler point wrt crank-coupler point
% Cv: y coordinate for coupler point wrt crank-coupler point

cycles = 1;% number of crank rotations
INCREMENTS = 361;% divide a rotation into this number
%% check the geometry
P = X(1:4);
check = P;
[L locL] = max(check);
check(locL) = [];
[S locS] = min(check);
check(locS) = [];
R = check;
flag = 0;

if S==X(4) & sum(check)>(L+S)
    TITLE = 'This is a Double-Crank Mechanism';
elseif (S==X(1)|S==X(3)) & sum(check)>(L+S)
    TITLE = 'This is a Rocker-Crank Mechanism';
elseif S==X(2) & sum(check)>(L+S)
    TITLE = 'This is a Double-Rocker Mechanism';
    flag  = 1;
elseif sum(check)==(L+S)
    TITLE = 'This is a Change Point Mechanism';
elseif sum(check)<(L+S)
    flag  = 1;
    TITLE = 'This is a Double-Rocker Mechanism';
end
%%
TH1 = linspace(0,2*pi,INCREMENTS);% Input angle theta1
dig = 1;% divide links into this number
R1 = X(1); r1 = linspace(0,R1,dig);
R2 = X(2); r2 = linspace(0,R2,dig);
R3 = X(3); r3 = linspace(0,R3,dig);
R4 = X(4); r4 = linspace(0,R4,dig);
Cu = X(5); cu = linspace(0,Cu,dig);
Cv = X(6); cv = linspace(0,Cv,dig);

%% check valid region
D = sqrt(R1^2 + R4^2 - 2*R1*R4*cos(TH1));% diagonal distance between
%                           crank-coupler point and rocker-frame point
TH5 = acos((R3^2+D.^2-R2^2)./(2*R3*D));% angle between rocker and diagonal
%                                        link (d)
IMAG = imag(TH5);
[VALUES LOCATION] = find(IMAG==0);
%%
IMAG = imag(TH5);
LOCATION = IMAG==0;
LOCATION1 = find(IMAG==0);
LOC = LOCATION;
n = length(LOCATION);
n1 = length(LOCATION1);
Check = 0;
direction = 1;
for i=1:n-1
    if LOC(i+1)~=LOC(i)
        if Check==0
            direction = LOC(i);
        end
        Check = Check+1;
    end
end
%%
Rotate = 0;
if isempty(LOCATION1)
    error('This is not a valid linkage');
elseif direction==0 & Check==2
    LOC1 = find(LOCATION==1);
    th1 = [TH1(LOC1) TH1(fliplr(LOC1))];
elseif n1==n
    th1 = TH1;
elseif direction==1 & Check==2
    Rotate = 1;
    loc1 = LOC(1:end-1);
    loc2 = LOC(2:end);
    [Value deadpoint] = find((loc2-loc1)~=0);
    deadp = deadpoint + [0 1];
    LOC2 = [deadp(2):n 1:deadp(1)];
    th1 = [TH1(LOC2) TH1(fliplr(LOC2))];
elseif Check==4
    Rotate = 1;
    loc1 = LOC(1:end-1);
    loc2 = LOC(2:end);
    [Value deadpoint] = find((loc2-loc1)~=0);
    deadp1 = deadpoint(1:2) + [1 0];
    deadp2 = deadpoint(3:4) + [1 0];
    fprintf('This mechanism has two disconnected upper and lower regions\n');
    DIREC = 1;
    DIREC = input('Select [1] for upper, [2] for lower    Default = [1]  ');
    if DIREC == 1
        LOC3 = [deadp1(1):deadp1(2)];
    else
        LOC3 = [deadp2(1):deadp2(2)];
    end
    th1 = [TH1(LOC3) TH1(fliplr(LOC3))];
end

d = sqrt(R1^2 + R4^2 - 2*R1*R4*cos(th1));
th5 = acos((R3^2+d.^2-R2^2)./(2*R3*d));% angle between rocker and

%%
if Rotate == 1
    d = sqrt(R1^2 + R4^2 - 2*R1*R4*cos(th1));
    th5 = acos((R3^2+d.^2-R2^2)./(2*R3*d));% angle between rocker and diagonal link (d)
    th5 = [th5(1:end/2) -th5(end/2+1:end)];
end
Ax = R1*cos(th1);% x coordinate for the crank-coupler point
Ay = R1*sin(th1);% y coordinate for the crank-coupler point
a = R4 - R1*cos(th1);% horizontal distance between rocker-frame point and
%                      projection of crank-coupler point
b = Ay;% vertical projection of crank-coupler point
th6 = atan2(b,a);% angle between frame and diagonal link (d)
th4 = pi - th5 - th6;% angle the rocker makes with horizon
Bx = R3*cos(th4) + R4;% horizontal distance between frame-crank point and
%                       projection of coupler-rocker point
By = R3*sin(th4);% vertical projection of coupler-rocker point
th2 = atan2((By-Ay),(Bx-Ax));% angle the coupler makes with the horizon
Cx = Ax + Cu*cos(th2) - Cv*sin(th2);% horizontal projection of coupler
%                                     point wrt coupler
Cy = Ay + Cu*sin(th2) + Cv*cos(th2);% vertical projection of coupler
%                                     point wrt coupler
% calculate display (figure) limits
xmin = 1.2*min([min(Cx) -R1 -R3]);
xmax = 1.2*max([max(Cx) R4+max([R3 max(R3*cos(th4))])]);
ymin = 1.2*min([min(Cy) -R1 -R3]);
ymax = 1.2*max([max(Cy) max([R1 R3 R3+Cv])]);
%%
increments = length(th1);
for i=1:increments
    link1x(i,:) = r1*cos(th1(i));
    link1y(i,:) = r1*sin(th1(i));
    link2x(i,:) = linspace(Ax(i),Bx(i),dig);
    link2y(i,:) = linspace(Ay(i),By(i),dig);
    link3x(i,:) = R4 + r3*cos(th4(i));
    link3y(i,:) = r3*sin(th4(i));
    Couplx1(i,:) = linspace(Ax(i),Cx(i),dig);
    Couply1(i,:) = linspace(Ay(i),Cy(i),dig);
    Couplx2(i,:) = linspace(Cx(i),Bx(i),dig);
    Couply2(i,:) = linspace(Cy(i),By(i),dig);
end
thetaOut = atan2(link3y,link3x-X(4))
plot(th1*180/pi-offset,thetaOut*180/pi-offset)

if linkage == 1
    elMap = [th1;thetaOut']*180/pi-offset;
    zero = floor(offset);   
    elSlope = (thetaOut(zero+1)-thetaOut(zero));
    elLinMap = (th1*180/pi-offset)*elSlope*180/pi;
    plot(th1*180/pi-offset,elLinMap)
else
    vStabMap = [th1;thetaOut']*180/pi-offset;
    zero = floor(offset);
    vStabSlope = (thetaOut(zero+1)-thetaOut(zero));
    vStabLinMap = (th1*180/pi-offset)*vStabSlope*180/pi;
    plot(th1*180/pi-offset,vStabLinMap)
end
end



legend('Elevator Mapping','Elevator Linear Approx','V-Stab Mapping','V-Stab Linear Approx')
xlabel('Servo Output [deg]')
ylabel('Control Deflection [deg]')
xlim([-50 50])
set(gca,'FontSize',15)

figure('Position',[100 100 700 250]); hold on; grid on;
plot(elMap(1,:),elMap(2,:)-elLinMap)
plot(vStabMap(1,:),vStabMap(2,:)-vStabLinMap)
xlabel('Servo Output [deg]')
ylabel('Mapping Error [deg]')
legend('Elevator Linear Map Error','Rudder Linear Map Error')
xlim([-50 50])
set(gca,'FontSize',15)
ctrlMap.El = elMap
ctrlMap.elSlope = elSlope
ctrlMap.vStab = vStabMap
ctrlMap.vStabSlope = vStabSlope