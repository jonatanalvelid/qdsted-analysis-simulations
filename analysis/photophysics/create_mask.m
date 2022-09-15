function [mask] = create_mask(x,y,size)
%CREATE_MASK creates a mask of the points with the given coordinates
%   Creates a mask of the given size (=[height,width]) where the bright
%   points are the SINGLE pixels contained in x and y
%   NOTE: the values of x and y should be consistent with MATlab
%   coordinate system

mask = zeros(size,'uint8');
for i=1:length(x)
    mask(y(i),x(i))=1;
end

end

