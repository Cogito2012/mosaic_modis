function [ rectboxes ] = generate_boxes( img_rgb,stride,patch_w,patch_h )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
stride_x = round(stride*patch_w);
stride_y = round(stride*patch_h);
[H,W,C] = size(img_rgb);
randseq = 1:stride_x:(W-patch_w);
patch_x = randseq(randperm(length(randseq)));
nx = length(patch_x);
randseq = 1:stride_y:(H-patch_h);
patch_y = randseq(randperm(length(randseq)));
ny = length(patch_y);

rectbox_init = zeros(nx*ny,4);
rectbox_init(:,1) = cell2mat(arrayfun(@(x)(repmat(x,1,ny)),patch_x,'UniformOutput',false));
rectbox_init(:,2) = repmat(patch_y,1,nx);
rectbox_init(:,3) = repmat(patch_w,1,nx*ny);
rectbox_init(:,4) = repmat(patch_h,1,nx*ny);
rectboxes = rectbox_init;
n = 0;idx = [];
for i=1:nx*ny
    r = rectbox_init(i,2);
    c = rectbox_init(i,1);
    w = rectbox_init(i,3);
    h = rectbox_init(i,4);
    if outOfbound(img_rgb,r,c) || outOfbound(img_rgb,r+h,c+w)
        n = n + 1;
        idx(n) = i;
    end
end
rectboxes(idx,:) = [];
    
end

