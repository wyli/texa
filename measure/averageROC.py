import os
import glob
import scipy.io
from scipy import interp
import numpy as np
import pdb as debug
#import pylab as pl

from sklearn.metrics import roc_curve, auc


def calc_roc(result_file, pos):
    result_mat = scipy.io.loadmat(result_file, struct_as_record=True)
    scores = np.asmatrix(result_mat['scores'])
    labels = np.asmatrix(result_mat['testY'])

    fpr, tpr, thresholds = roc_curve(labels, scores[:, pos], pos_label=pos+1)
    return fpr, tpr

def vertical_averaged_ROC(fold_path):
    cancer, HGD, LGD = 0, 1, 2
    mean_fpr = np.linspace(0, 1, 5000)
    mean_tpr = np.zeros((5000, 3))

    for type in [cancer, HGD, LGD]:
        for p in fold_path:
            mat_file = "%s/out.mat" % p
            fpr, tpr = calc_roc(mat_file, type)
            mean_tpr[:, type] += interp(mean_fpr, fpr, tpr)
            mean_tpr[0, type] = 0.0
    mean_tpr /= len(fold_path)
    mean_tpr[-1] = 1.0
    print auc(mean_fpr, mean_tpr[:,0])

def experiment(typeString, window, sub_window):
    exp_folder = "%s/*_%02d_%02d/" %(typeString, window, sub_window)
    exp_files = glob.glob(exp_folder)
    fold_files = glob.glob(exp_files[0]+'result_*')
    vertical_averaged_ROC(fold_files)

experiment('/home/wyli/shared/experiments/randomfeatures', 21, 9)
