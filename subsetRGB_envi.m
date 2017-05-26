function [ img_rgb ] = subsetRGB_envi( img_src )
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
[H,W,C] = size(img_src);
img_rgb = zeros(H,W,3);
img_rgb(:,:,1) = img_src(:,:,1);
img_rgb(:,:,2) = img_src(:,:,4);
img_rgb(:,:,3) = img_src(:,:,3);
% normalize each channel to be 0-1 by minmax form
for i=1:3
    img = img_rgb(:,:,i);
    [ylen, xlen] = size(img);
    bins = 0:65535;
    histcount = histc(img(:)', bins);
    clear bins max_val min_val;
    [l_val, r_val] = cal_lr_val(histcount, xlen*ylen, 0.02);
    img = img_map(img, l_val, r_val);
    img_rgb(:,:,i) = img;
end
img_rgb = img_rgb./255;
end

