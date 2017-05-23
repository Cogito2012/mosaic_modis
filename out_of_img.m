function [ boolres ] = out_of_img( im,x1,x2,y1,y2 )
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
[h,w,c] = size(im);
if x1<0 || x1>w || y1<0 || y1>h || x2<0 || x2>w || y2<0 || y2>h
    boolres = true;
else
    boolres = false;
end

end

