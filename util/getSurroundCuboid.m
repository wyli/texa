function [cuboid] = getSurroundCuboid(image3d, point3d, sizeOfCuboid)
% Get the cuboid centred at the given 3d point.
% RETURN the cuboid(3d image patch)
% Tue 24 Apr 2012 20:31:29 BST
% Wenqi Li

if sum(sizeOfCuboid > 2) < 3
    cuboid = [];
    return;
end

sizeOfCuboid = floor(sizeOfCuboid ./ 2);
iStart = uint16(point3d - sizeOfCuboid); % starting index of x y z
iEnd = uint16(point3d + sizeOfCuboid); % ending index of x y z:w

try
    cuboid = uint8(image3d(...
        iStart(1):iEnd(1), iStart(2):iEnd(2), iStart(3):iEnd(3)));
catch error
    warning('OPT:rejectLocation', error.identifier);
    fprintf('p: %d %d %d\n', point3d(1), point3d(2), point3d(3));
    fprintf('w: %d %d %d\n', sizeOfCuboid(1), sizeOfCuboid(2), sizeOfCuboid(3));
    cuboid = [];
end
end % end of function
