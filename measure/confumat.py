import glob
import math
import numpy as np
import scipy.io
from scipy import interpolate
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

from sklearn.metrics import roc_curve, auc
import pdb as debug

def calc_roc(result_file, pos):
    c_mat = np.zeros((3, 3))
    result_mat = scipy.io.loadmat(result_file, struct_as_record=True)
    scores = result_mat['scores']
    labels = result_mat['testY']
    labels = [item-1 for sublist in labels.tolist() for item in sublist]
    pre = [np.argmax(rows) for rows in scores]
    
    for i, j in zip(labels, pre):
        c_mat[i,j] += 1
    return c_mat

def vertical_averaged_ROC(fold_path, fig_name, window, sub_window):
    cancer, HGD, LGD = 0, 1, 2
    k = len(fold_path)

    all_mat = np.zeros((3, 3))
    for i, p in enumerate(fold_path):
        mat_file = "%s/out.mat" % p
        all_mat += calc_roc(mat_file, type)

    norm_conf = []
    for i in all_mat.tolist():
        a = 0
        tmp_arr = []
        a = sum(i, 0)
        for j in i:
            tmp_arr.append(float(j)/float(a))
        norm_conf.append(tmp_arr)
    fig = plt.figure()
    plt.clf()
    ax = fig.add_subplot(111)
    ax.set_aspect(1)
    res = ax.imshow(np.array(norm_conf), cmap = plt.cm.gray,
            interpolation='nearest')

    width = len(all_mat)
    height = len(all_mat[0])

    for x in xrange(width):
        for y in xrange(height):
            ax.annotate("%d"%all_mat[x][y], xy=(y, x),
                    horizontalalignment='center',
                    verticalalignment='center',
                    color='green', fontsize=24)

    print all_mat
    cb = fig.colorbar(res)
    classes = 'LHC'
    plt.xticks(range(3), ['ICA', 'HGD', 'LGD'])
    plt.yticks(range(3), ['ICA', 'HGD', 'LGD'])
    plt.xlim(-0.5, 2.5)
    plt.ylim(2.5, -0.5)
    plt.ylabel('Targets')
    plt.xlabel('Predicted')
    plt.savefig(fig_name, format='pdf')

def experiment(typeString, window, sub_window):
    exp_folder = "%s/*_%02d_%02d/" %(typeString, window, sub_window)
    file_name = "%s/conf_mat/%02d_%02d.pdf" %(typeString, window, sub_window)
    print file_name
    exp_files = glob.glob(exp_folder)
    if len(exp_files) == 0:
        return
    fold_files = glob.glob(exp_files[0]+'result_*')
    vertical_averaged_ROC(fold_files, file_name, window, sub_window)


#windows = [21, 31, 41, 51, 61, 71]
#sub_windows = [3, 5, 9, 13]
#for i in windows:
#    for j in sub_windows:
#        experiment('/home/wyli/shared/experiments/randomfeatures', i, j)
experiment('/home/wyli/shared/experiments/randomfeatures', 21, 3)
