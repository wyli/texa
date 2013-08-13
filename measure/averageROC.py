import glob
import math
import numpy as np
import scipy.io
from scipy import interpolate
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as pl

from sklearn.metrics import roc_curve, auc
import pdb as debug

def mean_confidence_interval(data, confidence=0.95):
    a = 1.0 * np.array(data)
    n = len(a)
    m, se = np.mean(a), np.std(a, ddof=1)
    h = se * scipy.stats.norm._ppf((1+confidence)/2.) / np.sqrt(n-1)
    return [m, m-h, m+h]

def calc_roc(result_file, pos):
    result_mat = scipy.io.loadmat(result_file, struct_as_record=True)
    scores = np.asmatrix(result_mat['scores'])
    labels = np.asmatrix(result_mat['testY'])
    list_labels = result_mat['testY'].tolist() #nested results
    prior = list_labels.count([pos+1])

    fpr, tpr, thresholds = roc_curve(labels, scores[:, pos], pos_label=pos+1)
    return fpr, tpr, prior

def vertical_averaged_ROC(fold_path, fig_name, window, sub_window):
    cancer, HGD, LGD = 0, 1, 2
    k = len(fold_path)

    # ROC curves are functions with fpr as variable
    num_samples = 8000
    mean_fpr = np.linspace(0, 1, num_samples)
    mean_tpr = np.zeros((num_samples, 3, k))
    priors = [0, 0, 0]

    for type in [cancer, HGD, LGD]:
        for i, p in enumerate(fold_path):
            mat_file = "%s/out_valid.mat" % p
            fpr, tpr, prior = calc_roc(mat_file, type)
            priors[type] += prior
            f = interpolate.interp1d(fpr, tpr)
            #mean_tpr[:, type, i] = interp(mean_fpr, fpr, tpr)
            mean_tpr[:, type, i] = f(mean_fpr)

    mean_tpr[0, :, :] = 0.0
    mean_tpr[-1, :, :] = 1.0
    tpr_list = mean_tpr.tolist()
    overall_auc = 0.0
    colors = ['#aaaaff', '#aaffaa', '#ffaaaa']
    for i, type in enumerate(['ICA', 'HGD', 'LGD']):
        tpr_v  = [mean_confidence_interval(row[i]) for row in tpr_list]
        tpr_v = np.array(tpr_v)
        mean_auc = auc(mean_fpr, tpr_v[:,0])
        print mean_auc
        print type

        pl.plot(mean_fpr, tpr_v[:,0], lw=1,
                label="%s (class auc: %0.2f)" % (type, mean_auc))
        pl.gca().fill_between(mean_fpr, tpr_v[:, 1], tpr_v[:,2], color=colors[i], alpha=0.2)

        overall_auc += priors[i] * mean_auc
    overall_auc /= np.sum(priors)
    print overall_auc
    pl.legend(loc="lower right")
    pl.xlim([0.0, 1.0])
    pl.ylim([0.0, 1.0])
    pl.xlabel('False Positive Rate')
    pl.ylabel('True Positive Rate')
    pl.title("ROC of Random Features - window %d - sub_window %d - averaged auc %0.2f" 
            % (window, sub_window, overall_auc))
    pl.savefig(fig_name, format='pdf')
    pl.clf()

def experiment(typeString, window, sub_window):
    exp_folder = "%s/*_%02d_%02d/" %(typeString, window, sub_window)
    file_name = "%s/rocs/%02d_%02d.pdf" %(typeString, window, sub_window)
    print file_name
    exp_files = glob.glob(exp_folder)
    if len(exp_files) == 0:
        return
    fold_files = glob.glob(exp_files[0]+'result_*')
    vertical_averaged_ROC(fold_files, file_name, window, sub_window)


#windows = [11, 21, 31, 41, 51, 61, 71]
#sub_windows = [3, 5, 7, 9, 13]
#for i in windows:
#    for j in sub_windows:
#        experiment('/home/wyli/shared/experiments/randomfeatures', i, j)
experiment('/home/wyli/shared/experiments/randomfeatures', 21, 13)
