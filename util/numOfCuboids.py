import os
import fnmatch
import scipy.io
import numpy as np

def countCuboids(fileString):
    files = os.listdir(fileString)
    CHL = [0, 0, 0]
    imgCHL = [0, 0, 0]
    for file in files:

        mat = scipy.io.loadmat(fileString + '/' + file, struct_as_record=True)

        l = np.shape(mat['cuboid'])[1]
        obj = mat['cuboid'][2,0][0,0][1]
        if obj[0] == 'LGD':

            CHL[2] = CHL[2] + l
            imgCHL[2] = imgCHL[2] + 1
        elif obj[0] == 'Cancers':

            CHL[0] = CHL[0] + l
            imgCHL[0] = imgCHL[0] + 1
        elif obj[0] == 'HGD':

            CHL[1] = CHL[1] + l
            imgCHL[1] = imgCHL[1] + 1
        else:
            print 'no! ' + file
            raise SystemExit

    print 'Cancers - image: %d, patch: %d' % (imgCHL[0], CHL[0])
    print 'HGD:    - image: %d, patch: %d' % (imgCHL[1], CHL[1])
    print 'LGD:    - image: %d, patch: %d' % (imgCHL[2], CHL[2])
    print 'Total:  - image: %d, patch: %d' % (np.sum(imgCHL), np.sum(CHL))

#index = range(11, 102, 10)
index = [11]
for i in index:
    fileString = "/home/wyli/data/cuboid_%d" %(i)
    print fileString
    files = os.listdir(fileString)
    countCuboids(fileString)
