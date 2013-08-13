from measure import confumat

def calibrate_scores(fold_path, fig_name, window, sub_window):
    cancer, HGD, LGD = [0, 1, 2]
    k = len(fold_path)
    if k < 10:
        return # not enough results_*
    for type in [cancer, HGD, LGD]:
        for i, p in enumberate(fold_path):
            predictor = platt.PredictorGenerator(
                    platt.SigmoidTrain(valid_scores, valid_Y_binary))
            


def experiment(typeString, window, sub_window):
    exp_folder = "%s/*_%02d_%02d/" %(typeString, window, sub_window)
    file_name = "%s/rocs/%02d_%02d.pdf" %(typeString, window, sub_window)
    print file_name
    exp_files = glob.glob(exp_folder)
    if len(exp_files) == 0:
        return
    fold_files = glob.glob(exp_files[0]+'result_*')
    calibrate_scores(fold_files, file_name, window, sub_window)

#windows = [11, 21, 31, 41, 51, 61, 71]
#sub_windows = [3, 5, 7, 9, 13]
#for i in windows:
#    for j in sub_windows:
#        experiment('/home/wyli/shared/experiments/randomfeatures', i, j)
#experiment('/home/wyli/shared/experiments/randomfeatures', 21, 13)
