function [ tag ] = getTag( lat, lon)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

x = lon*cos(lat/180*pi);
y = lat;
h = 17 + ceil(x/10);
v = floor((90-y)/10);
tag = {sprintf('h%02dv%02d',h,v)};

end

