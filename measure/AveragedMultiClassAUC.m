function avgAUC = AveragedMultiClassAUC(windowSize, typeString)
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
avgAUC = zeros(length(results), 1);
for k = 1:length(results)
    x = load([resultSet results(k).name '/out']);

    p = zeros(3, 1);
    for c = 1:3
        p(c) = sum(x.testY==c) / length(x.testY);
        avgAUC(k) = avgAUC(k) + p(c) * x.aucs(c);
    end
end
sum(avgAUC)/length(avgAUC)
end
