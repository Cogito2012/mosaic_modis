clc
clear
close all

root_dir = 'I:\RSData\MOD09A1_CHINA_JUN2SEP_DAY\code';
DATE = '01-JUN-16';
cd(root_dir)

% input directory
input_dir = fullfile(root_dir,'../reproj',DATE);
refimg_dir = fullfile(root_dir,'../refmap');
refimg_prefix = 'world.topo.bathy.200406.3x21600x21600';

% output directory
samples_dir = fullfile(root_dir,'../pairs',DATE);
if ~exist(samples_dir,'dir')
    mkdir(samples_dir)
end

stride = 1/4;
patch_w = 512;
patch_h = 512;
visualize = false;
% im_ref_C1 = imread(fullfile(refimg_dir,[refimg_prefix,'.C1.png']));
% im_ref_D1 = imread(fullfile(refimg_dir,[refimg_prefix,'.D1.png']));
    
imglist = textread(fullfile(input_dir,'list.txt'),'%s');
for n=1:length(imglist)
    imgname_ext = imglist{n};
    disp(['Process image: ',imgname_ext,'  ',num2str(n),'/',num2str(length(imglist))]);
    [img, R] = geotiffread(fullfile(input_dir,imgname_ext));
    [h,w,c] = size(img);
    % construct an RGB image from the 13 channels tiff image
    img_rgb = zeros(h,w,3);
    img_rgb(:,:,1) = img(:,:,1);
    img_rgb(:,:,2) = img(:,:,4);
    img_rgb(:,:,3) = img(:,:,3);
    % normalize each channel to be 0-1 by minmax form
    for i=1:3
        M = double(img_rgb(:,:,i));
        maxval = max(max(M));
        tmp = reshape(M,[w*h,1]);
        tmp(find(tmp<=0)) = [];
        minval = min(tmp);
        M = (M-minval)./(maxval-minval);
        M(find(M<0))=0;
        img_rgb(:,:,i) = double(M);
    end
    % generate random x,y corordinates
    rectboxes = generate_boxes(img_rgb,stride,patch_w,patch_h);
    if visualize
        imshow(img_rgb)
        for i=1:size(rectboxes,1)
            rectangle('Position',rectboxes(i,:),'LineWidth',2,'EdgeColor','r');
        end
    end
    % read geoinfo
    geoinfo = geotiffinfo(fullfile(input_dir,imgname_ext));
    
    cur_samples_dir = fullfile(samples_dir,imgname_ext(1:end-4));
    if ~exist(cur_samples_dir,'dir')
        mkdir(cur_samples_dir);
    end
    num = 0;
    for i=1:size(rectboxes,1)
        [lat,lon] = pix2latlon(geoinfo.RefMatrix, rectboxes(i,2), rectboxes(i,1));
        if lat >= 0 && lat < 90 && lon >= 0 && lon < 90 % C1 Zone, remove images with latitude larger than 45
            top_left = [90,0];
            x1 = round((lon-top_left(2))*240);
            y1 = round((top_left(1)-lat)*240);
            [lat2,lon2] = pix2latlon(geoinfo.RefMatrix, rectboxes(i,2)+patch_h-1, rectboxes(i,1)+patch_w-1);
            x2 = round((lon2-top_left(2))*240);
            y2 = round((top_left(1)-lat2)*240);
            if out_of_img(im_ref_C1,x1,x2,y1,y2)
                num = num + 1;
                disp(['Ignore ',num2str(num),' boxes']);
                continue;
            end
            patch_modis = img_rgb(rectboxes(i,2):rectboxes(i,2)+patch_h-1,rectboxes(i,1):rectboxes(i,1)+patch_w-1,:);
            patch_ref = im_ref_C1(y1:y2,x1:x2,:);
            image_pair = cat(2,uint8(patch_modis.*255),patch_ref);
            imwrite(image_pair,fullfile(cur_samples_dir,[num2str(i),'.jpeg']));
%             figure
%             imshow(image_pair)
%             rectangle('Position',[x1,y1,x2-x1+1,y2-y1+1],'LineWidth',2,'EdgeColor','y');
        end
        if lat >= 0 && lat < 90 && lon >= 90 && lon < 180 % D1 Zone
            top_left = [90,90];
            x1 = (lon-top_left(2))*240;
            y1 = (top_left(1)-lat)*240;
            [lat2,lon2] = pix2latlon(geoinfo.RefMatrix, rectboxes(i,2)+patch_h-1, rectboxes(i,1)+patch_w-1);
            x2 = (lon2-top_left(2))*240;
            y2 = (top_left(1)-lat2)*240;
            if out_of_img(im_ref_D1,x1,x2,y1,y2)
                num = num + 1;
                disp(['Ignore ',num2str(num),' boxes']);
                continue;
            end
            patch_modis = img_rgb(rectboxes(i,2):rectboxes(i,2)+patch_h-1,rectboxes(i,1):rectboxes(i,1)+patch_w-1,:);
            patch_ref = im_ref_D1(y1:y2,x1:x2,:);
            image_pair = cat(2,uint8(patch_modis.*255),patch_ref);
            imwrite(image_pair,fullfile(cur_samples_dir,[num2str(i),'.jpeg']));
%             figure
%             imshow(patch_ref)
%             rectangle('Position',[x1,y1,x2-x1+1,y2-y1+1],'LineWidth',2,'EdgeColor','y');
        end
    end
end


