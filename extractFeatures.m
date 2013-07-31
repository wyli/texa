function [] = extractFeatures(...
        baseSet, cuboidSet, feaSet, ...
        windowSize, subSize, randMat)

global projMat
projMat = randMat;
fprintf('%s build histogram for each cuboid\n', datestr(now));

% input
clusterSet = [baseSet, '/clusters.mat'];
% output
feaSet = [feaSet '/%s'];

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
            cuboid{1, index}, clusters, subSize);
    end
    %clear rMat repClusters cuboid;
    X_features = cell2mat(histograms');
    X_features = int16(X_features');
    featureFile = sprintf(feaSet, listFiles(i).name);
    save(featureFile, 'X_features', 'CHL', 'locations');
    clear X_features histograms CHL locations;
end
end

function histogram = cuboid2Hist(image3d, clusters, wSize)
global projMat

localCuboid = im3col(double(image3d), [wSize, wSize, wSize]);
localCuboid = localCuboid'*projMat';
D = dist2(localCuboid, clusters);
[~, nearest] = min(D, [], 2);
bins = 1:size(clusters, 1);
histogram = histc(nearest', bins);
end
