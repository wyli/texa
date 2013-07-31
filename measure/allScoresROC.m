function avgAUC = allScoresROC(windowSize, typeString)

base_dir = 'F:/experiments/%s/';
exp_dir = sprintf(base_dir, typeString);
search_dir = sprintf([exp_dir '*%02d_%02d'], windowSize(1), windowSize(2));
a = ls(search_dir);
if isempty(a)
    fprintf('dir not found\n');
    return;
else
    resultSet = [exp_dir a '/'];
    fprintf([resultSet '\n']);
end

results = dir([resultSet 'result*']);
allScores = [];
Y = [];
for k = 1:length(results)

    x = load([resultSet results(k).name '/out']);
    allScores = [allScores; x.scores];
    Y = [Y; x.testY];
end
avgAUC = 0;
for c = 1:3
    [a, b, ~, auc] = perfcurve(double(Y==c), allScores(:,c), '1');
    plot(a,b); hold on;
    avgAUC = avgAUC + auc * (sum(Y==c) / length(Y));
end
end
