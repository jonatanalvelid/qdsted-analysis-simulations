function [ A, flag ] = getaffinematrix( x, x_prime )
%AFFINEMATRIX Gets affine transformation matrix from a set of transformed
%points.
%   x is the input points, x_prime is the transformed points, in two-column
%   row matrixes for x,y coordinates.
% THIS MATRIX A TRANSFORMS A COORDINATE IN THE UNREGISTERED SECOND STEDONLY
% IMAGE OF THE QDS TO THE COORDINATE IN THE REGISTERED IMAGE, I.E. TO THE
% COORDINATE IN THE VESICLE STED IMAGE. SEEMS ALL CORRECT AS OF TEST
% PERFORMED 181214 ON A TEST IMAGE. 
flag = 0;
movingPoints = x;
fixedPoints = x_prime;
shift = sqrt((fixedPoints(1:3,1) - movingPoints(1:3,1)).^2 + (fixedPoints(1:3,2) - movingPoints(1:3,2)).^2);
if max(shift) < 25
    tform = fitgeotrans(movingPoints,fixedPoints,'NonreflectiveSimilarity');
    A = rot90(fliplr(tform.T));
else
    flag = 1;
    A = eye(3);
end
end

