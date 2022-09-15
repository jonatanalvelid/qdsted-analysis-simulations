%%% Check the distance to the nearest something through a distance map
function [distance] = distanceMapCheck(xcoord, ycoord, imgDist)
    % ycoord in a normal image means the row number in MATLAB, i.e. the
    % first coordinate of a matrix. Thus x and y are flipped.
    if xcoord ~= 0 && ycoord ~= 0
        distance = imgDist(round(ycoord), round(xcoord));
    else
        distance = NaN;
    end
end
