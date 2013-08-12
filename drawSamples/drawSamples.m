function [] = drawSamples(imgSet, xmlSet, outputSet, windowSize, maxSizePerFile)
% usage: 
% >> drawSamples('~/desktop/OPTmix', '~/desktop/description', '~/desktop/cuboidset', 21);
fprintf('%s drawing samples.\n', datestr(now));
fprintf('windowSize: %d\n', windowSize);

% input
xmlFiles = dir([xmlSet '/*.xml']);
segImgSet = '%s/Annotation/%s%s';
oriImgSet = '%s/Image/%s%s';

% output
outputSet = sprintf('%s/cuboid_%d', outputSet, windowSize);
fprintf('output: %s\n', outputSet);
mkdir(outputSet);

% parameters
window3d = windowSize * ones(1,3);
step3d = window3d;

for i = 1:size(xmlFiles, 1)

    cuboid = {};
    rec = VOCreadxml([xmlSet '/' xmlFiles(i).name]);
    name = rec.annotation.index;

    for p = 1:size(rec.annotation.part, 2)

        if size(rec.annotation.part, 2) == 1
            part = rec.annotation.part;
        else
            part = rec.annotation.part{p};
        end

        segFile = sprintf(segImgSet, imgSet, name, part);
        oriFile = sprintf(oriImgSet, imgSet, name, part);
        fprintf('input: %s\n', segFile);
        fprintf('input: %s\n', oriFile);
        [cubPart, location] = img2Cub(oriFile, segFile,...
            window3d, step3d, maxSizePerFile);
        if ~isempty(location)
            cubPart(2, :) = location;
            cuboid = [cuboid, cubPart];
        end
    end

    for j = 1:size(cuboid, 2)
        cuboid{3, j} = rec.annotation;
    end

    if isempty(cuboid)
        fprintf('no cuboid from this file.\n');
        continue;
    end
    badIndex = cellfun(@isempty, cuboid(1, :));
    cuboid(:, badIndex) = [];
    cuboidSet = sprintf('%s/%s', outputSet, name);
    fprintf('size: %dx%d saving at: %s\n', size(cuboid), cuboidSet);
    save(cuboidSet, 'cuboid');
end
end % end of function
