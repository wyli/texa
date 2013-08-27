import confumat as cf
import averageROC as rc
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as pl
#from mpl_toolkits.mplot3d import axes3d, Axes3D

windows = [11, 21, 31, 41, 51, 61, 71]
sub_windows = [3, 5, 9, 13]
aucs = np.zeros((len(windows), len(sub_windows)))
for i in range(0, len(windows)):
    for j in range(0, len(sub_windows)):
        try:
            # cf.experiment('/home/wyli/shared/experiments/randomfeatures_surs', i, j)
            # rc.experiment('/home/wyli/shared/experiments/randomfeatures_surs', i, j)
            cf.experiment('/home/wyli/shared/experiments/randomfeatures_surs', windows[i], sub_windows[j])
            aucs[i,j] = rc.experiment('/home/wyli/shared/experiments/randomfeatures_surs', windows[i], sub_windows[j])
        except:
            print "error %d %d" % (i, j)
np.savetxt('auc_mat.txt', aucs, fmt='%.4f')
#pl.clf()
#fig = pl.figure()
#ax = Axes3D(fig)
#for c, z in zip(['r', 'g', 'b', 'y'], [3, 2, 1, 0]):
#    xs = np.arange(len(windows))
#    ys = aucs[:, z]
#    ax.bar(xs, ys, zs=z, zdir='y', alpha=0.8)
#ax.set_xlabel('X')
#ax.set_xlabel('Y')
#ax.set_xlabel('Z')
#pl.savefig('auc_bar.pdf')

#rc.experiment('/home/wyli/shared/experiments/randomfeatures', 21, 13)
#cf.experiment('/home/wyli/shared/experiments/randomfeatures', 21, 13)
