import confumat as cf
import averageROC as rc
windows = [11, 21, 31, 41, 51, 61, 71]
sub_windows = [3, 5, 9, 13]
for i in windows:
    for j in sub_windows:
        cf.experiment('/home/wyli/shared/experiments/randomfeatures_surs', i, j)
        rc.experiment('/home/wyli/shared/experiments/randomfeatures_surs', i, j)
#rc.experiment('/home/wyli/shared/experiments/randomfeatures', 21, 13)
#cf.experiment('/home/wyli/shared/experiments/randomfeatures', 21, 13)
