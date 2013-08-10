import glob
import scipy.io
from scipy import interp
import numpy as np
import pdb as debug
from itertools import groupby
#import pylab as pl

from sklearn.metrics import roc_curve, auc


def calc_roc(result_file, pos):
    result_mat = scipy.io.loadmat(result_file, struct_as_record=True)
    scores = np.asmatrix(result_mat['scores'])
    labels = np.asmatrix(result_mat['testY'])
    list_labels = result_mat['testY'].tolist()
    prior = list_labels.count([pos+1])

    fpr, tpr, thresholds = roc_curve(labels, scores[:, pos], pos_label=pos+1)
    return fpr, tpr, prior

def vertical_averaged_ROC(fold_path):
    cancer, HGD, LGD = 0, 1, 2
    mean_fpr = np.linspace(0, 1, 5000)
    mean_tpr = np.zeros((5000, 3))
    priors = [0, 0, 0]

    for type in [cancer, HGD, LGD]:
        for p in fold_path:
            mat_file = "%s/out.mat" % p
            fpr, tpr, prior = calc_roc(mat_file, type)
            priors[type] += prior
            mean_tpr[:, type] += interp(mean_fpr, fpr, tpr)
    mean_tpr /= len(fold_path)
    mean_tpr[0, :] = 0.0 # dirty end of interpolations
    mean_tpr[-1, :] = 1.0

    avg_auc = 0.0
    for i, type in enumerate(['ICA', 'HGD', 'LGD']):
        mean_auc = auc(mean_fpr, mean_tpr[:,i])
        avg_auc += priors[i] * mean_auc
        print mean_auc
        #pl.plot(mean_fpr, mean_tpr[:,i], lw=1,
        #        label = "type: %s,  mean auc: %0.2f" %(type, mean_auc))
    avg_auc /= np.sum(priors)
    print avg_auc

def experiment(typeString, window, sub_window):
    exp_folder = "%s/*_%02d_%02d/" %(typeString, window, sub_window)
    exp_files = glob.glob(exp_folder)
    fold_files = glob.glob(exp_files[0]+'result_*')
    vertical_averaged_ROC(fold_files)

experiment('/home/wyli/shared/experiments/randomfeatures', 21, 9)
