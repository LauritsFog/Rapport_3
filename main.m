data = importdata('channel_data.txt');

% Conversion constants:

miles2km = 1.609344;
long2miles = 54.6;
lat2miles = 69;

% Extracting components of data: 

xdata = data(:,1);
ydata = data(:,2);
height = data(:,3);

%%

% Computing differences in x- and y-direction in km:

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

% Doing linear interpolation of height

interHeight = interp1(dist,height,d);

%%

figure(1)
plot(d,interHeight);