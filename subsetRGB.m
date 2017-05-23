function [ img_rgb ] = subsetRGB( img )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
[H,W,C] = size(img);
img = im2double(img);
img_rgb = zeros(H,W,3);
img_rgb(:,:,1) = img(:,:,1);
img_rgb(:,:,2) = img(:,:,4);
img_rgb(:,:,3) = img(:,:,3);
% normalize each channel to be 0-1 by minmax form
for i=1:3
    M = double(img_rgb(:,:,i));
    maxval = max(max(M));
    tmp = reshape(M,[W*H,1]);
    tmp(find(tmp<=0)) = [];
    minval = min(tmp);
    M = (M-minval)./(maxval-minval);
    M(find(M<0))=0;
    img_rgb(:,:,i) = double(M);
end

end

