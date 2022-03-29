data = importdata('channel_data.txt');

% Conversion constants:

miles2km = 1.609344;
long2miles = 54.6;
lat2miles = 69;

% Extracting components of data.

xdata = data(:,1);
ydata = data(:,2);
height = data(:,3);

%%

% Computing differences in x- and y-direction in km.

xdif = (xdata(1:end-1)-xdata(2:end)).*lat2miles*miles2km;
ydif = (ydata(1:end-1)-ydata(2:end)).*long2miles*miles2km;

% Computing distance from mediterrenean sea.

dist = zeros(1,length(xdata))';

for i = 2:length(xdata)
    dist(i) = dist(i-1)+sqrt(xdif(i-1).^2+ydif(i-1).^2);
end

%%

% Linear spacing from 0 to end of river with spacing of 250 meters.

numPoints = floor(dist(end)/0.25)+2;

% Mutl. by 10 to round to nearest 100th meter.

d = linspace(0,floor(dist(end)*10),numPoints-1)'./10;

%%

% Doing linear interpolation of height.

interHeight = interp1(dist,height,d);

%%

figure(1)
plot(d,interHeight);

%%

% Exporting for Julia.

csvwrite('interHeight.csv',interHeight);

%%

% Importing from Julia.

xValues = table2array(readtable("xValues.csv"));
dirtRemoved = table2array(readtable("RValues.csv"));

%%

%Takes the hight from the start and removes the dirt

newInterHeight = interHeight-dirtRemoved;

%%

figure(2)
title('Minimizing number of bombs');
plot(d,interHeight,'b');
hold on
plot(d,newInterHeight,'r');
hold all
for i = 1:length(xValues)
    if xValues(i) == 1
        xline(i*0.25);
    end
end
legend('Height before bombing','Height after bombing','Placement of bombs');
xlabel('Distance from sea (km)');
ylabel('Height from sea level (m)');

%%

% Importing results from non-linear objective function.

xValuesNonLinear = table2array(readtable("xValuesNonLinear.csv"));
dirtRemovedNonLinear = table2array(readtable("RValuesNonLinear.csv"));

newInterHeightNonLinear = interHeight-dirtRemovedNonLinear;

%%

% Plotting the new height map with bombs.

figure(4)
title('Maximizing smoothness');
plot(d,interHeight,'b');
hold on
plot(d,newInterHeightNonLinear,'r');
hold all
for i = 1:length(xValuesNonLinear)
    if xValuesNonLinear(i) == 1
        xline(i*0.25);
    end
end
legend('Height before bombing','Height after bombing','Placement of bombs');
xlabel('Distance from sea (km)');
ylabel('Height from sea level (m)');

%% 5

% Implementing a constraint in Julia

xValuesNonLinearNoNeighbors = table2array(readtable("xValuesNonLinearNoNeighbors.csv"));
dirtRemovedNonLinearNoNeighbors = table2array(readtable("RValuesNonLinearNoNeighbors.csv"));

newInterHeightNonLinearNoNeighbors = interHeight-dirtRemovedNonLinear;

%%

figure(5)
title('Maximizing smoothness without neighbouring bombs');
plot(d,interHeight,'b');
hold on
plot(d,newInterHeightNonLinearNoNeighbors,'r');
hold all
for i = 1:length(xValuesNonLinearNoNeighbors)
    if xValuesNonLinearNoNeighbors(i) == 1
        xline(i*0.25);
    end
end
legend('Height before bombing','Height after bombing','Placement of bombs');
xlabel('Distance from sea (km)');
ylabel('Height from sea level (m)');

%%

xBombs = table2array(readtable("xValuesNonLinearExtended.csv"));
yBombs = table2array(readtable("yValuesNonLinearExtended.csv"));
zBombs = table2array(readtable("zValuesNonLinearExtended.csv"));

dirtRemovedNonLinearExtended = table2array(readtable("RValuesNonLinearExtended.csv"));

newInterHeightNonLinearExtended = interHeight(2:end-2)-dirtRemovedNonLinearExtended;

%%

figure(6)
title('Minimizing number of bombs with possibility of three different bombs');
plot(d,interHeight,'b');
hold on
plot(d(2:end-2),newInterHeightNonLinearExtended,'r');
for i = 1:length(newInterHeightNonLinearExtended)
    if xBombs(i) == 1
        hold on
        xline(i*0.25,'g');
    end
    if yBombs(i) == 1
        hold on
        xline(i*0.25,'m');
    end
    if zBombs(i) == 1
        hold on
        xline(i*0.25,'c');
    end
end

legend('Height before bombing','Height after bombing','Placement of bombs');
legend('Height before bombing','Height after bombing','Placement of K1 bombs','Placement of K2 bombs');

xlabel('Distance from sea (km)');
ylabel('Height from sea level (m)');

%% Plots together

figure(7)
hold on
plot(d,newInterHeight);
hold on
plot(d,newInterHeight,'LineWidth',1);
ylim([-300 0]);
hold on
plot(d,newInterHeightNonLinear,'LineWidth',2);
hold on
plot(d,newInterHeightNonLinearNoNeighbors,'LineWidth',1);
legend("Minimizing bombs","Smoothing","No neighbors")


%% Number of bombs

Minbombs=sum(xValues);
SmoothingNumberbombs=sum(xValuesNonLinear);
NoneigboorNumberbombs=sum(xValuesNonLinearNoNeighbors);

table(Minbombs,SmoothingNumberbombs,NoneigboorNumberbombs)

distancebetweenbombs=xValuesNonLinearNoNeighbors-xValuesNonLinear;
