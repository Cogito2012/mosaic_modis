clc
clear

test_data_dir = 'I:\RSData\MOD09A1_CHINA_JUN2SEP_DAY\test_rect\09-JUN-16-Reproj';
imagename = 'mod09a1.a2016161.h24v03.006.2016170073734_reproj.tif';
[img_src, R] = geotiffread(fullfile(test_data_dir,imagename));
geoinfo = geotiffinfo(fullfile(test_data_dir,imagename));
[H,W,C] = size(img_src);
img_rgb = zeros(H,W,3);
img_rgb(:,:,1) = img_src(:,:,1);
img_rgb(:,:,2) = img_src(:,:,4);
img_rgb(:,:,3) = img_src(:,:,3);

for i=1:3
    img = img_rgb(:,:,i);
    % 这里默认输入图像为单通道
    [ylen, xlen] = size(img);
    % 统计直方图
    % 输入图像为16位，取值范围为 0 到 65535
    bins = 0:65535;
    histcount = histc(img(:)', bins);

    %清除临时变量
    clear bins max_val min_val;
    % 直方图裁剪，计算左值和右值
    [l_val, r_val] = cal_lr_val(histcount, xlen*ylen, 0.02);
    % 根据左值和右值，将图像由16位映射至8位
    img = img_map(img, l_val, r_val);
    img_rgb(:,:,i) = img;
end
img_rgb = img_rgb./255;
imshow(img_rgb)
% 保存结果
% imwrite(img_8bit, 'res.png');