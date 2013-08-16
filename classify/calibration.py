import glob
import scipy.io
import numpy as np
import pdb
import platt
from measure import confumat
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as pl

def load_validation_set(result_file, type):
    result_mat = scipy.io.loadmat(result_file, struct_as_record=True)
    scores = np.asmatrix(result_mat['valid_scores'])
    test_scores = np.asmatrix(result_mat['scores'])
    labels = np.asmatrix(result_mat['validY'])
    test_labels = np.asmatrix(result_mat['testY'])

    scores = [s for sublist in scores[:,type].tolist()
            for s in sublist]
    test_scores = [s for sublist in test_scores[:,type].tolist()
            for s in sublist]
    labels = [1 if i == type+1 else -1
            for sublist in labels.tolist() for i in sublist]
    test_labels = [i-1
            for sublist in test_labels.tolist() for i in sublist]
    return scores, labels, test_scores, test_labels
    

def calibrate_scores(fold_path, fig_name, window, sub_window):
    cancer, HGD, LGD = [0, 1, 2]
    k = len(fold_path)
    if k < 10:
        return # not enough results_*
    c_mat = np.zeros((3,3))
    for i, p in enumerate(fold_path):
        probs = np.array([])
        for type in [cancer, HGD, LGD]:
            valid_scores, valid_Y_binary, test_scores, test_Y_binary = \
                    load_validation_set("%s/out_valid.mat" % p, type)
            predictor = platt.PredictorGenerator(
                    platt.SigmoidTrain(valid_scores, valid_Y_binary))
            prob = [predictor(i) for i in test_scores]
            if probs.size == 0:
                probs = np.array(prob)
                pl.hist(probs, bins=100)
                pl.savefig('/home/wyli/shared/experiments/test.pdf')
                pl.clf()
                return
            else:
                probs = np.vstack([probs, prob])
        probs = np.transpose(probs)
        pre = np.argmax(probs, axis=1)
        for i, j in zip(test_Y_binary, pre):
            c_mat[i,j] += 1
    print c_mat


def experiment(typeString, window, sub_window):
    exp_folder = "%s/*_%02d_%02d/" %(typeString, window, sub_window)
    file_name = "%s/rocs/%02d_%02d.pdf" %(typeString, window, sub_window)
    print file_name
    exp_files = glob.glob(exp_folder)
    if len(exp_files) == 0:
        return
    fold_files = glob.glob(exp_files[0]+'result_*')
    calibrate_scores(fold_files, file_name, window, sub_window)

# windows = [11, 21, 31, 41, 51, 61, 71]
# sub_windows = [3, 5, 7, 9, 13]
# for i in windows:
#     for j in sub_windows:
#         experiment('/home/wyli/shared/experiments/randomfeatures', i, j)
# experiment('/home/wyli/shared/experiments/randomfeatures', 21, 13)
