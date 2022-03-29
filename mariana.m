%% Problem 2

clear
close all 
clc

data=load('channel_data.txt');

% Conversion constants: 

miles2km = 1.609344; 
long2miles = 54.6; 
lat2miles = 69; 
km2meter=1000;
meter2km=1/1000;


%% 

% Definding the data and converting to km.

xdata = data(:,1).*(lat2miles*miles2km);
ydata = data(:,2).*(long2miles*miles2km);
height = data(:,3); 


%%

% Finding the cumulative distance between the point in the plan through the channel.

Distance=zeros(99,1);

for i=1:98
    
        Distance(i+1) = Distance(i)+ sqrt((xdata(i+1)-xdata(i))^2+(ydata(i+1)-ydata(i))^2);
        
end


%% Plottet height against the Distance

figure (1) 
plot(Distance,height) 

%%
% The total distance into the channel from the sea:
totaldist=floor(Distance(end));

%%

% Finding the number of point we have to make with a distance of 250 km

numPoints = totaldist/0.25;

% Linear spacing from 0 to 78 with spacing of 250 

d = linspace(0,totaldist,numPoints+1)'; 

%%

% Doing linear interpolation of height. 

interHeight = interp1(Distance,height,d); 

%%

figure(2)
plot(d,interHeight);

%%

% Exporting for Julia.

csvwrite('interHeight.csv',interHeight);


%% 

% Importing from Julia.

objectiveFunction = table2array(readtable("xValues.csv"));
dirtRemoved = table2array(readtable("RValues.csv"));

%% 

figure(3)
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

figure(4)
hold on
plot(d(2:end),newInterHeight);
ylim([-300 0]);

%%

% Importing results from non-linear objective function.

objectiveFunctionNonLinear = table2array(readtable("xValuesNonLinear.csv"));
dirtRemovedNonLinear = table2array(readtable("RValuesNonLinear.csv"));

newInterHeightNonLinear = interHeight(2:end)-dirtRemovedNonLinear;

%%

% Plotting the new height map without having chosing plots 
hold on
plot(d(2:end),newInterHeightNonLinear);

%% 

% Importing results from non-linear objective function with bombs chosed.

objectiveFunctionNonLinear2 = table2array(readtable("xValuesNonLinearnok.csv"));
dirtRemovedNonLinear2 = table2array(readtable("RValuesNonLinearnok.csv"));

newInterHeightNonLinear2 = interHeight(2:end)-dirtRemovedNonLinear2;

%%

% Plotting the new height map without having chosing plots 

hold on
plot(d(2:end),newInterHeightNonLinear2);
legend("min bombs","smoothing","no neighbors")


%% Number of bombs

numboms_min_bombs=sum(objectiveFunction);
numboms=sum(objectiveFunctionNonLinear2);
numboms_nok=sum(objectiveFunctionNonLinear);

table(numboms_min_bombs,numboms_nok,numboms)

distancebetweenbombs=objectiveFunctionNonLinear2-objectiveFunctionNonLinear;

%% 

figure(5)
plot(d(2:end),newInterHeightNonLinear2);

















