function main(windowSize, subWindow, subStep, randFeatureLength)
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
id = '';
if isempty(id)
    id = datestr(now, 30);
    id = sprintf('%s', id);
end
out_dir = 'F:/experiments/randomfeatures';
out_dir = sprintf('%s/%s_%02d_%02d', out_dir, id, windowSize, subWindow);
mkdir(out_dir);
diary off;
diary([out_dir '/exp.log']);

%%% input patches
patchSet = 'F:/cuboid_%d';
patchSet = sprintf(patchSet, windowSize);
xmlSet = 'C:/OPT_dataset/Description';

%%% flags
generate_scheme = 1;
new_random_matrix = 1;
do_kmeans = ones(10, 1);
do_extract_features = 1;
do_classification = 1;
fprintf('at: %s\n', datestr(now));
fprintf('%s: %d\n', 'generate testing scheme', generate_scheme);
fprintf('%s: %d\n', 'new random matrix      ', new_random_matrix);
fprintf('%s: %d\n', 'do kmeans on training  ', do_kmeans(1));
fprintf('%s: %d\n', 'extract features on all', do_extract_features);
fprintf('%s: %d\n', 'do classification      ', do_classification);
fprintf('\n\n');
% end of flags

%%% 10-fold cross validation scheme
k = 10;
foldSize = 9;
files = dir([xmlSet, '/*.xml']);
L_ind = [];
H_ind = [];
C_ind = [];
for i = 1:length(files)
    rec = VOCreadxml([xmlSet '/' files(i).name]);
    if strcmp(rec.annotation.type, 'LGD')
        L_ind(end+1) = i;
    elseif strcmp(rec.annotation.type, 'HGD')
        H_ind(end+1) = i;
    else
        C_ind(end+1) = i;
    end
end
L_ind = L_ind(randperm(size(L_ind, 2)));
H_ind = H_ind(randperm(size(H_ind, 2)));
C_ind = C_ind(randperm(size(C_ind, 2)));
allInd = zeros(1, k*foldSize);
allInd(1, 1:3:end) = L_ind;
allInd(1, 2:3:end) = H_ind;
allInd(1, 3:3:end) = C_ind;
clear L_ind H_ind C_ind;
if generate_scheme
    allInd = randsample(k*foldSize, k*foldSize);
    allInd = reshape(allInd, foldSize, []);
    testScheme = eye(k, 'int8');
    save([out_dir '/exparam'], 'testScheme', 'allInd');
else
    temp = load([out_dir '/exparam']);
    testScheme = temp.testScheme;
    allInd = temp.allInd;
    clear temp
end

%%% random matrix for projection (global)
if new_random_matrix
    randMat = randn(randFeatureLength, subWindow^3);
    save([out_dir, '/randMat'], 'randMat');
end
clear files rec i k foldSize new_random_matrix generate_scheme randFeatureLength

for f = 1:length(testScheme)

    % output dir
    resultSet = sprintf('%s/result_%02d', out_dir, f);
    mkdir(resultSet);

    % selecting f(th) testing schemes
    trainInd = allInd(:, ~testScheme(f, :));
    trainInd = trainInd(:);
    testInd = allInd(:, f);

    if do_kmeans(f)

        kcenters = 200;
        samplePerFile = 100;

        temp = load([out_dir, '/randMat']);
        randMat = temp.randMat;
        clear temp;

        trainBases(...
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
        % classify features
        feaSet = [resultSet, '/fea'];
        classifyFeatures(feaSet, resultSet, trainInd, testInd);
    end
end
diary off;
end