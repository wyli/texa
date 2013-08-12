function locations =...
        scanForSURSLocations(image3d, window3d, step)
% scanForCuboids looking for cuboids locations in the 3d image
% (only if central location of the patch is with in annotated region)
% RETURN 3d images and locations
% e.g.:
% [~, loc] = scanForCuboids('/cancer/annotation/73c', [21,21,11], [10,10,5]);
% 
% Mon Aug 12 15:07:40 BST 2013
% Wenqi Li

sizeOfImg = size(image3d);
index = find(image3d);
[~, ~, frameInx] = ind2sub(size(image3d), index);
frameInx = unique(frameInx);

locations = [];
window3d = floor(window3d./2);
for i = 1:size(frameInx,1);

    if (frameInx(i) - window3d(3) < 1) ||...
            (frameInx(i) + window3d(3) > sizeOfImg(3))
        continue;
    end

    startFrame = frameInx(i);
    [xs ys] = find(image3d(:,:,startFrame));
    xLow = max(min(xs), window3d(1)+1);
    xHigh = min(max(xs), sizeOfImg(1)-window3d(1));
    yLow = max(min(ys), window3d(2)+1);
    yHigh = min(max(ys), sizeOfImg(2)-window3d(2));

    for x = xLow:step(1):xHigh
        for y = yLow:step(2):yHigh
            try
                if image3d(x, y, startFrame) > 0
                    % locations of positive examples.
                    locations = [locations; [x y startFrame]];
                end
            catch e
                warning(e.identifier, 'In scanForPositiveSampleLocations');
            end
        end
    end
end

if isempty(locations)
    err = MException('OPT:nolocation',...
        'Cannot find any continuous annotations given the window size.');
    throw(err);
end
fprintf('total locations: %d, %d\n', size(locations, 1), size(locations, 2));
end % end of function

%% visualise ROI
%% works for 081C.mat
%figure();
%colormap(gray);
%imagesc(image3d(:,:,frameInx(10)));
%for i = 1:size(locations, 1)
%    l = locations(i,:);
%    if (l(3) == frameInx(10))
%        rectangle('Position',...
%           [l(2)-window3d(2), l(1)-window3d(1),window3d(2)*2, window3d(1)*2],'FaceColor', 'r');
%    end
%end
%
%clear i overlap;
%end
