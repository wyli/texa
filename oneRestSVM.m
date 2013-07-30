function [classifier] = oneRestSVM(trainY, trainX)

classifier = cell(3, 1);
for k = 1:3

    trainY_k = double(trainY==k);
    r = randsample(size(trainY, 1), floor(.3*(size(trainY, 1))));
    bestcmd = searchParam(trainY_k(r, 1), trainX(r, :));
    classifier{k} = train(trainY_k, trainX, bestcmd);
    fprintf('best cmd: %s\n', bestcmd);
end
end

function [bestcmd] = searchParam(Y, X)

bestcmd = [];
aucnow = 0;
for log10c = -5:5
%for log10e = 5:-1:4

    %cmd = ['-c ', num2str(10^log10c), ' -e ', num2str(10^log10e)];
    cmd = ['-s 2 -c ', num2str(10^log10c)];
    modelnow = train(Y, X, [cmd ' -q']);
    [~, ~, scores] = predict(Y, X, modelnow, ' -q');
    scores(isnan(scores)) = 0;
    if modelnow.Label(1) == -1
        scores = -scores;
    end
    [~, ~, ~, auc] = perfcurve(Y, scores, 1);
    if(auc > aucnow && sum(modelnow.w) ~= 0)
        bestcmd = cmd;
    end
%end
end
end
