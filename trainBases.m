function [] = trainBases(...
        baseDir, cuboidSet, trainInd, windowSize, subSize, step3d, k, randMat, samplePerFile)

fprintf('%s find %d clusters on small window %d\n', datestr(now), k, subSize);
% params
global numOfSubsamples
numOfSubsamples = 10;
% input
cuboidSet = [cuboidSet '/%s'];

% output
clusterFile = [baseDir, '/clusters_' int2str(samplePerFile) '.mat'];

localSet = [];
listFiles = dir(sprintf(cuboidSet, '*.mat'));
for j = 1:size(trainInd, 1)

    i = trainInd(j);

    cuboidFile = sprintf(cuboidSet, listFiles(i).name);
    temp = load(cuboidFile);
    cuboid = temp.cuboid;

    if(samplePerFile < size(cuboid, 2))
        cuboid = cuboid(:, 1:samplePerFile);
    end
    cuboid = cuboid(1, :);

    idMat = ones(1, size(cuboid, 2));
    repSize = mat2cell(idMat.*subSize, 1, idMat);
    repStep = mat2cell(idMat.*step3d, 1, idMat);
    localCells = cellfun(@sampleSubCuboids,...
        cuboid, repSize, repStep, 'UniformOutput', false);
    localMat = cell2mat(localCells');
    clear localCells cuboid temp;
    localSet = [localSet; localMat];
end
localSet = (randMat*localSet')';
%assert(size(localSet, 1) > 40000, '%d %d', size(localSet, 1), size(localSet, 2));
%r = randsample(size(localSet, 1), 40000);
%localSet = localSet(r, :);
fprintf('%s local patch set size: %dx%d\n', size(localSet));
prm.nTrial = 3;
prm.display = 1;
[~, clusters] = kmeans2(localSet, k, prm);
save(clusterFile, 'clusters');
end

function localCuboid = sampleSubCuboids(image3d, wSize, wStep)
global numOfSubsamples;
imgSize = size(image3d);
halfSize = ceil(wSize/2);

xs = halfSize:wStep:(imgSize(1) - halfSize);
%ys = halfSize:wStep:(imgSize(2) - halfSize);
%zs = halfSize:wStep:(imgSize(3) - halfSize);

xrec = min(length(xs), numOfSubsamples);
%yrec = min(length(ys), numOfSubsamples);
%zrec = min(length(zs), numOfSubsamples);

x = randsample(xs, xrec);
y = randsample(xs, xrec);
z = randsample(xs, xrec);
%ys = randsample(ys, yrec);
%zs = randsample(zs, zrec);

localCuboid = zeros(numel(x), wSize^3);
for i = 1:numel(x)
    sampleCell = getSurroundCuboid(...
        image3d, [x(i), y(i), z(i)], [wSize, wSize, wSize]);
    localCuboid(i, :) = sampleCell(:)';
end
end
