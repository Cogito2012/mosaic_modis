clc
clear
close all

root_dir = 'I:\RSData\MOD09A1_CHINA_JUN2SEP_DAY\code';
samples_dir = fullfile(root_dir,'../pairs');
datasets_dir = fullfile(root_dir,'../datasets');

% DATE = {'01-JUN-16','09-JUN-16','17-JUN-16'};
DATE = {'01-JUN-16'};

train_ratio = 0.6;
val_ratio = 0.2;
train_dir = fullfile(datasets_dir,'train');
val_dir = fullfile(datasets_dir,'val');
test_dir = fullfile(datasets_dir,'test');
if ~exist(datasets_dir,'dir')
    mkdir(train_dir);
    mkdir(val_dir);
    mkdir(test_dir);
end

n_train = 1; n_val = 1; n_test = 1;
for d = 1:length(DATE)
    tile_foders = dir(fullfile(samples_dir,DATE{d}));
    tile_foders(1:2) = [];
    for i=1:length(tile_foders)
        disp(['processing images in: ', tile_foders(i).name])
        tile_dir = fullfile(samples_dir,DATE{d},tile_foders(i).name);
        imgs = dir(tile_dir);
        imgs(1:2) = [];
        imgs = imgs(randperm(length(imgs)));
        train_num = round(length(imgs)*train_ratio);
        val_num = round(length(imgs)*val_ratio);
        test_num = length(imgs) - train_num - val_num;
        for j=1:train_num
            imgfile = fullfile(tile_dir,imgs(j).name);
            train_file = fullfile(train_dir,[num2str(n_train),'.jpeg']);
            copyfile(imgfile,train_file);
            n_train = n_train + 1;
        end
        for j=train_num+1:train_num+val_num
            imgfile = fullfile(tile_dir,imgs(j).name);
            val_file = fullfile(val_dir,[num2str(n_val),'.jpeg']);
            copyfile(imgfile,val_file);
            n_val = n_val + 1;
        end
        for j=train_num+val_num+1:length(imgs)
            imgfile = fullfile(tile_dir,imgs(j).name);
            test_file = fullfile(test_dir,[num2str(n_test),'.jpeg']);
            copyfile(imgfile,test_file);
            n_test = n_test + 1;
        end
    end

end




