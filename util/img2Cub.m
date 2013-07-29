function  [cuboid, location] = img2Cub(...
    imgFile, segFile, windowSize, step, numOfSamples)

% load images and segmentations.
load(imgFile);
load(segFile);

% get interesting locations
try
    locations3d = scanForPositiveSampleLocations(...
        segImg, windowSize, step);
catch e
    fprintf('%s\n', e.identifier);
end
randIndex = randsample(size(locations3d,1), min(size(locations3d,1), numOfSamples));
fprintf('%d locations found, Randomly choose %d locations.\n ',...
    length(locations3d), min(size(locations3d,1), numOfSamples));

locations3d = locations3d(randIndex, :);
cuboid = cell(1, size(randIndex,1));
location = cell(1, size(randIndex,1));

for loc = 1:size(randIndex,1)

    cuboid{1,loc} = getSurroundCuboid(...
        oriImg, locations3d(loc,:), windowSize);
    location{1,loc} = locations3d(loc,:);
end	
end % end of function
