function [] = classifyFeatures(files, feaSet, resultSet, trainInd, testInd)

addpath('U:/archives/liblinear-1.93/matlab/'); % warning windows binary bugs
fprintf('classify features\n');

[trainX, trainY] = loadFeatures(feaSet, trainInd, files);
trainX = sparse(trainX);
%save('features.mat');

[classifier, valid_scores, validY] = oneRestSVM(trainY, trainX);
validY = int8(validY);
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
testY = int8(testY);
valid_scores = single(valid_scores);
scores = single(scores);
save([resultSet, '/out_valid'], 'aucs', 'scores', 'testY', 'valid_scores', 'validY');
save([resultSet, '/classifier_valid'], 'classifier');
end
