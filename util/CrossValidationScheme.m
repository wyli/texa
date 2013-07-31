function [testScheme, allInd] = CrossValidationScheme(...
        k, foldSize, xmlSet, patchSet)

% assumed k*foldSize == length(L_ind) + length(H_ind) + length(C_ind)   
% assumed file names format (ddd.xml and ddd.mat)
%%% 10-fold cross validation scheme
k = 10;
foldSize = 9;
testScheme = eye(k, 'int8');

% read class labels
files = dir([xmlSet, '/*.xml']);
L_ind = [];
H_ind = [];
C_ind = [];
for i = 1:length(files)
    rec = VOCreadxml([xmlSet '/' files(i).name]);
    files(i).name = files(i).name(1:3);
    if strcmp(rec.annotation.type, 'LGD')
        L_ind(end+1) = i;
    elseif strcmp(rec.annotation.type, 'HGD')
        H_ind(end+1) = i;
    else
        C_ind(end+1) = i;
    end
end

% generate balanced scheme
valid = -1; 
repeat = 1;
while valid < 0 && repeat < 100

    schemeMat = randomSplit(L_ind, H_ind, C_ind, k, foldSize);
    for i = 1:length(schemeMat)
        if ~exist([patchSet '/' files(schemeMat(i)).name '.mat'], 'file')
            fprintf('missing patch set: %s\n',...
                [patchSet '/' files(schemeMat(i)).name]);
            schemeMat(i) = 0; % no patche from some images due to large window size
        end
    end
    allInd = reshape(schemeMat, foldSize, []);
    for f = 1:k
        testInd = allInd(:, f);
        testLabels = repmat([1; 2; 3], [3, 1]);
        classLabels = testLabels(testInd > 0);
        if length(unique(classLabels)) < 3
            valid = -1;
            break;
        else
            valid = 1;
        end
    end
    repeat = repeat + 1;
end
if valid < 0
    err = MException('cross validation: bad folds splitting.',...
        'not balanced instances for 10-fold cross validation.\n');
    throw(err);
end
allInd = reshape(schemeMat, foldSize, []);
end

function [schemeMat] = randomSplit(L_ind, H_ind, C_ind, k, foldSize)
L_ind = L_ind(randperm(size(L_ind, 2)));
H_ind = H_ind(randperm(size(H_ind, 2)));
C_ind = C_ind(randperm(size(C_ind, 2)));
schemeMat = zeros(1, k*foldSize);
schemeMat(1, 1:3:end) = L_ind;
schemeMat(1, 2:3:end) = H_ind;
schemeMat(1, 3:3:end) = C_ind;
end
