clc
clear
close all

root_dir = '/home/bwt/Modis_Data/mosaic_modis';
DATE = '01-JUN-16';
cd(root_dir)

%% config input and output directories
% input directory
test_data_dir = fullfile(root_dir,'../test_rect/09-JUN-16-Reproj');
refimg_dir = fullfile(root_dir,'../refmap');
refimg_prefix = 'world.topo.bathy.200406.3x21600x21600';

% set up output directory
output_dir = fullfile(root_dir,'../testdata');
if ~exist(output_dir,'dir')
    mkdir(output_dir)
end
modis_patch_dir = fullfile(output_dir,'modis_patches');
if ~exist(modis_patch_dir,'dir')
    mkdir(modis_patch_dir)
end
nasa_patch_dir = fullfile(output_dir,'nasa_patches');
if ~exist(nasa_patch_dir,'dir')
    mkdir(nasa_patch_dir)
end

% generate input modis images list file
imglist = dir(fullfile(test_data_dir,'*.tif'));
imglist = struct2cell(imglist);
imglist = imglist(1,:)';

%% generate china rectangle grid and patches
% 67.8W 57N 138.6E 16.6S
% 136E,54N,73E,3N , China
NorthWest = [73, 54];
SouthEast = [136, 3];
% 360/86400=0.004167
cellsize = 0.004212; 
patchsize = 512;
step = (patchsize*cellsize);

nx = ceil((SouthEast(1) - NorthWest(1))/step);
ny = ceil((NorthWest(2) - SouthEast(2))/step);
[GridX,GridY] = meshgrid(NorthWest(1):step:NorthWest(1)+nx*step, NorthWest(2):-step:NorthWest(2)-ny*step);
% grided patches, 720x4
PatchSets = [];
for i=1:ny
    for j=1:nx
        x1 = GridX(i,j); y1 = GridY(i,j);
        x2 = GridX(i+1,j+1); y2 = GridY(i+1,j+1);
        PatchSets = cat(1,PatchSets,[x1,y1,x2,y2]);
    end
end

%% read reference NASA images
t1 = tic();
im_ref_C1 = imread(fullfile(refimg_dir,[refimg_prefix,'.C1.png']));
im_ref_D1 = imread(fullfile(refimg_dir,[refimg_prefix,'.D1.png']));
time = toc(t1);
fprintf('Reference images are read successfully, time: %.3d s.', num2str(time));


%% generate patches from nasa reference images
% slice_id = get_slice_id(NorthWest(2), NorthWest(1));
% NASA_China = zeros(ny*patchsize,nx*patchsize,3);
top_left = [90,0];
x1 = round((NorthWest(1)-top_left(2))*240);
y1 = round((top_left(1)-NorthWest(2))*240);
top_left = [90,90];
x2 = round((SouthEast(1)-top_left(2))*240);
y2 = round((top_left(1)-SouthEast(2))*240);
col_left = size(im_ref_C1,2)-x1+1;
% NASA_China(:,1:col_left,:) = im_ref_C1(y1:y2,x1:end,:);
% NASA_China(:,col_left+1:end,:) = im_ref_D1(y1:y2,1:x2,:);
NASA_China = cat(2,im_ref_C1(y1:y2,x1:end,:),im_ref_D1(y1:y2,1:x2,:));
NASA_China = imresize(NASA_China,[ny*patchsize,nx*patchsize],'bilinear');
% imshow(NASA_China);
% split the whole image into nx*ny patches
t2 = tic();
for i=1:ny
    for j=1:nx
        x1 = (j-1)*patchsize+1;
        y1 = (i-1)*patchsize+1;
        x2 = j*patchsize;
        y2 = i*patchsize;
        nasa_patch = NASA_China(y1:y2,x1:x2,:);
        patch_tag = sprintf('R%02dC%02d',i,j);
        imwrite(nasa_patch,fullfile(nasa_patch_dir,['patch_',patch_tag,'_nasa.png']));
    end
end
time = toc(t2);
fprintf('Reference NASA images patches are generated successfully, time: %.3d s.', num2str(time));

%% generate patches from modis images
for n=1:size(PatchSets,1)
    fprintf('Process image patch : %d/%d, ',n,size(PatchSets,1));
    box = PatchSets(n,:);
    % Sinusoidal projection, the central meridian is -180
    x1 = (box(1))*cos(box(2)/180*pi);
    y1 = box(2);
    x2 = (box(3))*cos(box(4)/180*pi);
    y2 = box(4);
    % get tile id, start from 0, stepped by 10 degree
    h1 = 17 + ceil(x1/10);
    v1 = floor((90-y1)/10);
    h2 = 17 + ceil(x2/10);
    v2 = floor((90-y2)/10);
    % get image patch from corresponding hdf tile
    RID = ceil(n/nx);
    CID = n - (RID-1)*nx;
    if h1==h2 && v1==v2
        th = tic();
        file_tag = sprintf('h%02dv%02d',h1,v1);
        ind = ~cellfun(@isempty,strfind(imglist,file_tag));
        ind = find(ind==1);
        % read GeoTiff image, signed int 16 bit
        [img, R] = geotiffread(fullfile(test_data_dir,imglist{ind}));
        % read geoinfo
        geoinfo = geotiffinfo(fullfile(test_data_dir,imglist{ind}));
        img_rgb = subsetRGB_envi(img);
        % convert lattitude and longitude to row and column in image
        [r1,c1] = latlon2pix(geoinfo.RefMatrix, box(2), box(1));
        r1 = round(r1); c1 = round(c1);
        [r2,c2] = latlon2pix(geoinfo.RefMatrix, box(4), box(3));
        r2 = round(r2); c2 = round(c2);
        % get image patch from modis images
        img_patch = img_rgb(r1:r2-1,c1:c2-1,:);
        patch_tag = sprintf('R%02dC%02d',RID,CID);
        imwrite(img_patch,fullfile(modis_patch_dir,['patch_',patch_tag,'_modis.png']));
        time = toc(th);
        fprintf('Inner Patch, time: %.3f s\n',time);
    else
        th = tic();
        % get tag matrix
        [X, Y] = meshgrid(box(1):cellsize:box(3)-cellsize,box(2):-cellsize:(box(4)+cellsize));
        tag_patch = cell(patchsize,patchsize);
        H = 17 + ceil(X.*cos(Y./180*pi)./10);
        V = floor((90 - Y)./10);
        f = @(h,v)sprintf('h%02dv%02d',h,v);
        tag_patch = arrayfun(f,H,V,'UniformOutput',false);
        tag_patch_unique = unique(tag_patch);
        img_patch = zeros(patchsize,patchsize,3);
        for i=1:length(tag_patch_unique)
            res = strcmp(tag_patch,tag_patch_unique{i});
            [rows,cols] = find(res==1);
            % get the corresponding image tile
            ind = ~cellfun(@isempty,strfind(imglist,tag_patch_unique{i}));
            ind = find(ind==1);
            [img, R] = geotiffread(fullfile(test_data_dir,imglist{ind}));
            geoinfo = geotiffinfo(fullfile(test_data_dir,imglist{ind}));
            img_rgb = subsetRGB_envi(img);
            for j=1:length(rows)
                [r,c] = latlon2pix(geoinfo.RefMatrix, Y(rows(j),cols(j)), X(rows(j),cols(j)));
                r = round(r); c = round(c);
                if r>size(img_rgb,1) || c>size(img_rgb,2)
                    continue; % bug!!
                end
                img_patch(rows(j),cols(j),:) = img_rgb(r,c,:);
            end
        end
        patch_tag = sprintf('R%02dC%02d',RID,CID);
        imwrite(img_patch,fullfile(modis_patch_dir,['patch_',patch_tag,'_modis.png']));
        time = toc(th);
        fprintf('Boundary Patch, time: %.3f s\n',time);
    end
    
end


% get image patch from refeerence nasa images
TL_slice_id = get_slice_id(box(2), box(1));
BR_slice_id = get_slice_id(box(2), box(1));
if strcmp(TL_slice_id,BR_slice_id)
    % the whole box locates in C1 or D1
    switch(TL_slice_id)
        case 'C1'
            top_left = [90,0];
            x1 = round((box(1)-top_left(2))*240);
            y1 = round((top_left(1)-box(2))*240);
            x2 = round((box(3)-top_left(2))*240);
            y2 = round((top_left(1)-box(4))*240);
            patch_ref = im_ref_C1(y1:y2,x1:x2,:);
        case 'D1'
            top_left = [90,90];
            x1 = round((box(1)-top_left(2))*240);
            y1 = round((top_left(1)-box(2))*240);
            x2 = round((box(3)-top_left(2))*240);
            y2 = round((top_left(1)-box(4))*240);
            patch_ref = im_ref_D1(y1:y2,x1:x2,:);
        otherwise
            fprintf('Invalid latitude and longitude!\n');
    end
else
    % The top left point locates in C1, and bottom right point
    % locates in D1

end


