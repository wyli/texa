function [features, labels] = loadFeatures(setpath, ind, files)
%lsFiles = dir([setpath '/*.mat']); % features.mat
features = [];
y = [];
for i = 1:length(ind)

    j = ind(i);
    temp = load([setpath, '/', files(j).name]);
    features = [features, temp.X_features];
    y = [y, temp.CHL(1,:)];
end
clear temp;

features = features';
labels = zeros(size(y))';
for i = 1:length(y)

    if strcmp(y{i}.type, 'Cancers')
        labels(i) = 1;
    elseif strcmp(y{i}.type, 'HGD')
        labels(i) = 2;
    else
        labels(i) = 3;
    end
end
features = double(features);
labels = double(labels);
end
