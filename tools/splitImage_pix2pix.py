import os
import cv2


input_image = './result2.bmp'
dest_dir = './patches2'
if not os.path.isdir(dest_dir):
    os.makedirs(dest_dir)	

subimg_size = 512

image = cv2.imread(input_image)
height = image.shape[0]
width = image.shape[1]

patchnum_x = int(width/subimg_size)
patchnum_y = int(height/subimg_size)


cnt = 1
for i in range(patchnum_y):
    for j in range(patchnum_x):
        x = j*subimg_size
        y = i*subimg_size
        patch = image[y:y+subimg_size,x:x+subimg_size,:]
        patch_name = 'patch_h%02dv%02d.png'%(j,i)
        print patch_name
        cv2.imwrite(os.path.join(dest_dir,patch_name),patch)
        cnt += 1

