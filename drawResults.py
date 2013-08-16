import measure.averageROC as rc
import measure.confumat as cf
import classify.calibration as ca

windows = [11, 21, 31, 41, 51, 61, 71]
sub_window = [3, 5, 9, 13]
for i in windows:
    for j in sub_window:
        rc.experiment('/home/wyli/shared/experiments/randomfeatures', i, j)
        cf.experiment('/home/wyli/shared/experiments/randomfeatures', i, j)
# ca.experiment('/home/wyli/shared/experiments/randomfeatures', 21, 13)
# rc.experiment('/home/wyli/shared/experiments/randomfeatures', 21, 13)
