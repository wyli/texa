function main(typeString, windowSize, subWindow, subStep, randFeatureLength)
%clear all; close all;
t = ceil(subWindow/2);
h = windowSize - t + 1;
if (length(t:subStep:h) < 2) || (randFeatureLength > windowSize^3)
    fprintf('bad parameters\n');
    return;
end
RandStream.setGlobalStream(RandStream('mt19937ar', 'Seed', 'shuffle'));
addpath(genpath('U:/github/texa')); %.git folder slow

%%% free parameters
%windowSize = 11;
%subWindow = 5;
%subStep = 2;
%randFeatureLength = 40;

%%% output directory
reclassify = 1;
if reclassify

    generate_scheme = 0;
    new_random_matrix = 0;
    do_kmeans = zeros(10, 1);
    do_extract_features = 0;
    do_classification = 1;
    draw_fig = 0;

    base = ['F:/experiments/', typeString];
    out_dir = sprintf('%s/*_%02d_%02d', base, windowSize, subWindow);
    x = dir(out_dir);
    if length(x) ~= 1
        fprintf('not existing or ambiguous directory %02d_%02d\n', windowSize, subWindow);
        return;
    end
    out_dir = sprintf('%s/%s', base, x(1).name);
    fprintf('valid directory. %s\n', out_dir);
    diary off;
    diary([out_dir '/exp_valid.log']);
else
    generate_scheme = 1;
    new_random_matrix = 1;
    do_kmeans = ones(10, 1);
    do_extract_features = 1;
    do_classification = 1;
    draw_fig = 0;

    id = '';
    if isempty(id)
        id = datestr(now, 30);
        id = sprintf('%s', id);
    end
    out_dir = ['F:/experiments/', typeString];
    out_dir = sprintf('%s/%s_%02d_%02d', out_dir, id, windowSize, subWindow);
    mkdir(out_dir);
    diary off;
    diary([out_dir '/exp.log']);
end

%%% input patches
patchSet = 'F:/cuboid_%d';
patchSet = sprintf(patchSet, windowSize);
xmlSet = 'C:/OPT_dataset/Description';

%%% flags
fprintf('at: %s\n', datestr(now));
fprintf('%s: %d\n', 'generate testing schemellInd', generate_scheme);
fprintf('%s: %d\n', 'new random matrix      ', new_random_matrix);
fprintf('%s: %d\n', 'do kmeans on training  ', do_kmeans(1));
fprintf('%s: %d\n', 'extract features on all', do_extract_features);
fprintf('%s: %d\n', 'do classification      ', do_classification);
fprintf('\n\n');
% end of flags

% generate random splitting
if generate_scheme
    [testScheme, allInd, files] = CrossValidationScheme(...
        10, 9, xmlSet, patchSet);
    save([out_dir '/exparam'], 'testScheme', 'allInd', 'files');
else
    temp = load([out_dir '/exparam']);
    testScheme = temp.testScheme;
    allInd = temp.allInd;
    files = temp.files;
    clear temp
end


%%% random matrix for projection (global)
if new_random_matrix
    randMat = randn(randFeatureLength, subWindow^3);
    save([out_dir, '/randMat'], 'randMat');
end
clear i k foldSize new_random_matrix generate_scheme randFeatureLength

for f = 1:length(testScheme)

    % output dir
    resultSet = sprintf('%s/result_%02d', out_dir, f);
    mkdir(resultSet);

    % selecting f(th) testing schemes
    trainInd = allInd(:, ~testScheme(f, :));
    trainInd = trainInd(:);
    trainInd = trainInd(trainInd > 0);
    testInd = allInd(:, f);
    testInd = testInd(testInd > 0);

    if do_kmeans(f)

        kcenters = 200;
        samplePerFile = 100;

        temp = load([out_dir, '/randMat']);
        randMat = temp.randMat;
        clear temp;

        trainBases(files,...
            resultSet, patchSet, trainInd,...
            windowSize, subWindow, subStep, kcenters, randMat, samplePerFile);
    end

    if do_extract_features

        temp = load([out_dir, '/randMat']);
        randMat = temp.randMat;
        clear temp;

        mkdir([resultSet, '/fea']);
        cuboidInput = [patchSet, '/%s'];
        feaOutput = [resultSet, '/fea'];

        extractFeatures(...
            resultSet, cuboidInput, feaOutput,...
            windowSize, subWindow, subStep, randMat);
    end

    if do_classification

        feaSet = [resultSet, '/fea'];
        classifyFeatures(files, feaSet, resultSet, trainInd, testInd);
    end
end
if draw_fig
    avgAUC = AveragedMultiClassAUC([windowSize, subWindow], typeString)
    avgAUC = allScoresROC([windowSize, subWindow], typeString)
end
diary off;
end
