% linux branch 
clc
clear
close all

root_dir = '/home/bwt/Modis_Data/mosaic_modis/';
cd(root_dir)

test_data_dir = fullfile(root_dir,'../test_rect/09-JUN-16-Reproj');
% cmd_str = ['dir /B ' test_data_dir '\*.tif >' test_data_dir '\imagelist.txt'];
% system(cmd_str);
% imglist = textread(fullfile(test_data_dir,'imagelist.txt'),'%s');
imglist = dir(fullfile(test_data_dir,'*.tif'));
imglist = struct2cell(imglist);
imglist = imglist(1,:)';

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

%%
image_china = zeros(patchsize*ny,patchsize*nx,3);
slice_num = 0;
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
    if h1==h2 && v1==v2
        th = tic();
        file_tag = sprintf('h%02dv%02d',h1,v1);
        ind = ~cellfun(@isempty,strfind(imglist,file_tag));
        ind = find(ind==1);
        % read GeoTiff image, signed int 16 bit
        [img, R] = geotiffread(fullfile(test_data_dir,imglist{ind}));
        % read geoinfo
        geoinfo = geotiffinfo(fullfile(test_data_dir,imglist{ind}));
        img_rgb = subsetRGB(img);
        % convert lattitude and longitude to row and column in image
        [r1,c1] = latlon2pix(geoinfo.RefMatrix, box(2), box(1));
        r1 = round(r1); c1 = round(c1);
        [r2,c2] = latlon2pix(geoinfo.RefMatrix, box(4), box(3));
        r2 = round(r2); c2 = round(c2);
        % patch_w and patch_h should be identical to patchsize(512)
        patch_w = c2-c1;
        patch_h = r2-r1;
        img_patch = img_rgb(r1:r2-1,c1:c2-1,:);
        time = toc(th);
        fprintf('Inner Patch, time: %.3f s\n',time);
%         imshow(img_patch)
%         rectbox = [c1,r1,c2-c1+1,r2-r1+1];
%         imshow(img_rgb)
%         rectangle('Position',rectbox,'LineWidth',2,'EdgeColor','r');
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
            img_rgb = subsetRGB(img);
            for j=1:length(rows)
                [r,c] = latlon2pix(geoinfo.RefMatrix, Y(rows(j),cols(j)), X(rows(j),cols(j)));
                r = round(r); c = round(c);
                if r>size(img_rgb,1) || c>size(img_rgb,2)
                    continue; % bug!!
                end
                img_patch(rows(j),cols(j),:) = img_rgb(r,c,:);
            end
        end
        time = toc(th);
        fprintf('Boundary Patch, time: %.3f s\n',time);
    end
    % mosaic china patches
    Row = ceil(n/nx); Col = n-(Row-1)*nx;
    image_china((Row-1)*patchsize+1:Row*patchsize,(Col-1)*patchsize+1:Col*patchsize,:) = img_patch;
    if mod(n,round(0.5*nx*ny))==0 
        slice_num = slice_num + 1;
        image_china_row = image_china((Row-0.5*ny)*patchsize+1:Row*patchsize,:,:);
        imwrite(image_china_row,sprintf('China_MOD09A1_Slice%d.bmp',num2str(slice_num)));
    end
end







