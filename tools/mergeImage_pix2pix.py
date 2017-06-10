# merger patches to China.bmp
import os
import cv2
import numpy as np

input_dir = "./patches_translate2"
dest_file = "ModisChina2.bmp"
patchsize = 512
patchnum_x = 30
patchnum_y = 24
#ModisChina = cv2.CreateImage((patchnum_x*patchsize, patchnum_y*patchsize),8,3)
Modischina = np.zeros([patchnum_y*patchsize, patchnum_x*patchsize, 3])

fileIDs = list("h%02dv%02d"%(i,j) for i in range(patchnum_x) for j in range(patchnum_y))
image_list = os.listdir(input_dir)

for fileid in fileIDs:
    #print fileid
    # get the row and colunm index of Modischina
    col = int(fileid[1:3])
    row = int(fileid[4:6])
    filename = "patch_%s_trans.png"%fileid
    if filename not in image_list:
        print("PNG file: %s is missing!\n"%fileid)
        patch = np.zeros([3,patchsize,patchsize])
    print fileIDs.index(fileid)

    imagefile = os.path.join(input_dir,filename)
    patch = cv2.imread(imagefile)

    Modischina[row*patchsize:(row+1)*patchsize, col*patchsize:(col+1)*patchsize,:] = patch

cv2.imwrite(dest_file,Modischina)
print("Done!")