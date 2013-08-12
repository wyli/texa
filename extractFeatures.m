function [] = extractFeatures(...
        baseSet, cuboidSet, feaSet, ...
        windowSize, subSize, step, randMat)

fprintf('%s build histogram for each cuboid\n', datestr(now));

% input
clusterSet = [baseSet, '/clusters.mat'];
% output
feaSet = [feaSet '/%s'];

% parameter
p = 0;
len = 0;
while p < (windowSize-subSize+1)
    p = p + step;
    len = len + 1;
end

tempclusters = load(clusterSet);
clusters = tempclusters.clusters;
listFiles = dir(sprintf(cuboidSet, '*.mat'));
for i = 1:size(listFiles, 1)
    fprintf('%s **** %s\n', datestr(now), listFiles(i).name);

    cuboidFile = sprintf(cuboidSet, listFiles(i).name);
    temp = load(cuboidFile);
    cuboid = temp.cuboid;

    locations = cuboid(2,:);
    CHL = cuboid(3,:);

    histograms = cell(1, size(cuboid,2));
    for index = 1:length(histograms)
        histograms{index} = cuboid2Hist(...
            cuboid{1, index}, clusters, subSize, randMat, step, len);
    end
    %clear rMat repClusters cuboid;
    X_features = cell2mat(histograms');
    X_features = int16(X_features');
    featureFile = sprintf(feaSet, listFiles(i).name);
    save(featureFile, 'X_features', 'CHL', 'locations');
    clear X_features histograms CHL locations;
end
end

function histogram = cuboid2Hist(image3d, clusters, wSize, projMat, step, len)

localCuboid = im3col(double(image3d), [wSize, wSize, wSize], [step,len]);
localCuboid = localCuboid'*projMat';
[~, nearest] = min(dist2(localCuboid, clusters), [], 2);
%D = dist2(localCuboid, clusters);
%[~, nearest] = min(D, [], 2);
histogram = histc(nearest', 1:size(clusters,1));
end
