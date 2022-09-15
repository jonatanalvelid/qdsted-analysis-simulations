function [av,std_dev,mask_bkg] = bkg(image,x_max,y_max,radius,pixel_size)
%BKG Analyzes the background of an image
%   Returns as an output the average and the standard deviation for the
%   background plus a mask of the analyzed region. 
%   The function excludes a circular region around the maxima according to the given radius

%transform radius in pixel units
radius = radius/pixel_size;

mask_bkg = zeros(size(image));
%draw all the circles in the image
mask_bkg = insertShape(mask_bkg, 'filledcircle', [x_max, y_max, radius*ones(size(x_max))],...
    'LineWidth', 1, 'color', 'white');
%transform in BW
mask_bkg = rgb2gray(mask_bkg);
%transform in binary
mask_bkg = imbinarize(mask_bkg, 0);
%label with 1 the region outside the FWHM
mask_bkg = ~mask_bkg;

%perform average and standard deviation
av = mean(image(mask_bkg));
std_dev = std(image(mask_bkg));

end

