function [m] = return_mean_maxima(image,x_max,y_max,width,height)
%RETURN_MEAN_MAXIMA Returns the mean of the intensity
%   Returns the mean of the intensity in a specified rectangular region
%   around the given maximum

%create mask around the center (see function bkg)
mask=zeros(size(image));
mask=insertShape(mask,'filledrectangle',[x_max-width/2,y_max-height/2,width,height],...
    'LineWidth',1,'color','white');
%transform in BW
mask=rgb2gray(mask);
%transform in binary
mask=imbinarize(mask, 0);

m=mean(image(mask));

end

