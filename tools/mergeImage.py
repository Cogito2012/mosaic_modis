# merger patches to China.bmp
import os
import cv2
import numpy as np
import argparse
import re


def main():
    parser = argparse.ArgumentParser('merge all image patches into a whole image.')
    parser.add_argument("--input_dir", dest="input_dir", required=True, help="input image patches path")
    parser.add_argument("--dest_file", dest="dest_file", required=True, help="the result merged image file")
    args = parser.parse_args()

    patchsize = 512
    patchnum_x = 30
    patchnum_y = 24

    Modischina = np.zeros([patchnum_y*patchsize, patchnum_x*patchsize, 3])

    fileIDs = list("R%02dC%02d"%(i+1,j+1) for i in range(patchnum_y) for j in range(patchnum_x))
    image_list = os.listdir(args.input_dir)

    for fileid in fileIDs:
        #print fileid
        # get the row and colunm index of Modischina
        row = int(fileid[1:3])
        col = int(fileid[4:6])
        #filename = "patch_%s_trans.png"%fileid
        filename = re.findall('\\w*{}\\w*'.format(fileid),','.join(image_list))[0]
        filename = filename+'.png'
        if not filename:
            print("PNG file: %s is missing!\n"%fileid)
            patch = np.zeros([3,patchsize,patchsize])
        idx = fileIDs.index(fileid)
        if (idx+1)%patchnum_x == 0:
            print "finished the %d/%d rows"%(idx/patchnum_x+1, patchnum_y)

        imagefile = os.path.join(args.input_dir,filename)
        patch = cv2.imread(imagefile)

        Modischina[(row-1)*patchsize:row*patchsize, (col-1)*patchsize:col*patchsize,:] = patch

    cv2.imwrite(args.dest_file,Modischina)
    print("Done!")

if __name__ == "__main__":
    main()