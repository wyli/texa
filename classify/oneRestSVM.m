function [classifier, valid_scores, validY] = oneRestSVM(labels, features)
    %sparse

    classifier = cell(3, 1);
    folds = fold_k_partition(labels, 3); % 3-fold validation sets
    assert(length(folds) == 3)

    temp = cell2mat(folds);
    validY = labels(temp(:));
    clear temp;
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

            [~, ~, s] = predict(validY_cf, sparse(valid_fea), classifier{c});
            if isempty(s)
                f
                c
                size(valid_fea)
                size(validY_cf)
                assert(~isempty(s));
            end
            clear validY_cf, valid_fea;

            valid_scores(from:from+length(s)-1,c) = s;
            from = from+length(s);
        end
    end
end

function [bestcmd] = searchParam(Y, X, folds)
    
    fprintf('choose parameters on svm\n');
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
        if (acc >= accnow && sum(modelnow.w) ~= 0)
            bestcmd = cmd;
            fprintf('best acc now: %.2f\n', acc/3.0);
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
