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
    % ����Ĭ������ͼ��Ϊ��ͨ��
    [ylen, xlen] = size(img);
    % ͳ��ֱ��ͼ
    % ����ͼ��Ϊ16λ��ȡֵ��ΧΪ 0 �� 65535
    bins = 0:65535;
    histcount = histc(img(:)', bins);

    %�����ʱ����
    clear bins max_val min_val;
    % ֱ��ͼ�ü���������ֵ����ֵ
    [l_val, r_val] = cal_lr_val(histcount, xlen*ylen, 0.02);
    % ������ֵ����ֵ����ͼ����16λӳ����8λ
    img = img_map(img, l_val, r_val);
    img_rgb(:,:,i) = img;
end
img_rgb = img_rgb./255;
imshow(img_rgb)
% ������
% imwrite(img_8bit, 'res.png');