function [] = classifyFeatures(files, feaSet, resultSet, trainInd, testInd)

addpath('U:/archives/liblinear-1.93/matlab/'); % warning window binary bugs
fprintf('classify features\n');

[trainX, trainY] = loadFeatures(feaSet, trainInd, files);
trainX = sparse(trainX);
%save('features.mat');

classifier = oneRestSVM(trainY, trainX);
clear trainY trainX;

[testX, testY] = loadFeatures(feaSet, testInd, files);
testX = sparse(testX);

aucs = zeros(3, 1);
scores = zeros(length(testY), 3);
for k = 1:3
    testY_k = double(testY == k);
    [~, ~, s] = predict(testY_k, testX, classifier{k});
    s(isnan(s)) = 0;
    if classifier{k}.Label(1) == 0
        s = -s;
    end
    try
        [~, ~, ~, auc] = perfcurve(testY_k, s, 1);
    catch err
        err
        auc = 0;
    end
    aucs(k) = auc;
    scores(:, k) = s;
end
save([resultSet, '/out'], 'aucs', 'scores', 'testY');
end
