function [ bool_res ] = outOfbound( im, r,c)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

    if im(r,c,1)==0
        bool_res = 1;
    elseif im(r,c,2)==0
        bool_res = 1;
    elseif im(r,c,3)==0
        bool_res = 1;
    else
        bool_res = 0;
    end
    
end

