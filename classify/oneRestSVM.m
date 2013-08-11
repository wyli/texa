function [classifier, valid_scores, validY] = oneRestSVM(labels, features)
    %sparse

    classifier = cell(3, 1);
    folds = fold_k_partition(trainY, 3); % 3-fold validation sets

    validY = labels(cell2mat(folds));
    valid_scores = zeros(length(labels), 3);

    for c = 1:3

        binary_y = double(labels==c);

        bestcmd = searchParam(binary_y, features, folds); 
        fprintf('best cmd: %s\n', bestcmd);

        from = 1;
        for f = 1:length(folds)

            trainY = binary_y;
            trainY(folds{f}) = [];
            trainX = features;
            trainX(folds{f}, :) = [];

            classifier{c} = train(trainY, sparse(trainX), bestcmd);
            clear trainY, trainX;

            validY_cf = binary_y(folds{f});
            valid_fea = features(folds{f}, :);

            [~, ~, s] = predict(validY_cf, sparse(valid_fea), classifier{f})
            clear validY_cf, valid_fea;

            valid_scores(from:from+length(s)-1,c) = s;
            from = from+length(s);
        end
    end
end

function [bestcmd] = searchParam(Y, X, folds)
    bestcmd = [];
    accnow = 0;

    for log10c = -5:5

        acc = 0;
        for f = 1:length(folds)
            trainY = Y;
            trainY(folds{f}) = [];
            trainX = X;
            trainX(folds{f}, :) = [];
            cmd = ['-s 2 -c ', num2str(10^log10c)];
            modelnow = train(trainY, sparse(trainX), [cmd ' -q']);
            clear trainY, trainX;
            validY = Y(folds{f});
            valid_fea = X(folds{f});
            [~, a, ~] = predict(validY, sparse(valid_fea), modelnow, ' -q');
            clear validY, valid_fea;
            acc = acc + a(1);
        end
        if acc > accnow
            bestcmd = cmd;
        end
    end
end

function [folds] = fold_k_partition(all_labels, k)

    % partition labels into k balanced folds
    % return k group indexes
    [sorted, ori_index] = sort(all_labels);
    [classes, pos, ~] = unique(sorted);
    pos = [0; pos];
    steps = diff(pos);

    select = [];
    for i = 1:classes
        select = [select; padarray([1:k]', steps(i)-k, 'circular', 'pre')];
    end

    folds = cell(k, 1);
    for f = 1:k
        folds{f} = ori_index(select==f);
    end

    % k = 3;
    %assert(length(select) == length(all_labels));
    %assert(length(classes)==3);
    %assert(length(pos)==4);
    %assert(all(diff(pos)>=3));
end
