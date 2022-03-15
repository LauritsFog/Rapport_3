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

numPoints = floor(dist(end))/0.25;

d = linspace(0,floor(dist(end)),numPoints+1)';

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

objectiveFunction = table2array(readtable("xValues.csv"));
dirtRemoved = table2array(readtable("RValues.csv"));

%%

figure(2)
plot(d,interHeight);
hold all
for i = 1:length(objectiveFunction)
    if objectiveFunction(i) == 1
        xline(i*0.25);
    end
end

%%

newInterHeight = interHeight(2:end)-dirtRemoved;

%%

% Plotting the new height map with bombs. 

figure(3)
plot(d(2:end),newInterHeight);
hold all
for i = 1:length(objectiveFunction)
    if objectiveFunction(i) == 1
        xline(i*0.25);
    end
end
ylim([-300 0]);

%%

% Importing results from non-linear objective function.

objectiveFunctionNonLinear = table2array(readtable("xValuesNonLinear.csv"));
dirtRemovedNonLinear = table2array(readtable("RValuesNonLinear.csv"));

newInterHeightNonLinear = interHeight(2:end)-dirtRemovedNonLinear;

%%

% Plotting the new height map with bombs. 

figure(4)
plot(d(2:end),newInterHeightNonLinear);
hold all
for i = 1:length(objectiveFunction)
    if objectiveFunctionNonLinear(i) == 1
        xline(i*0.25);
    end
end
ylim([-300 0]);
