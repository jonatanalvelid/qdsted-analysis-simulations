function [maxima] = find_fft_maxima(STEDimage, imtype)
    %FIND_FFT_MAXIMA Finds the maxima in the STED image with fft analysis
    %   Fourier transform the image, delete high frequency information, and
    %   inverse fourier transform it back to receive something like a
    %   "smoothed" image. Removes all blinking etc, and output looks like a
    %   perfect confocal image, but with a bit higher resolution. Find the
    %   maxima in this image. 
    
    % Make the thresholding factor depending on what the images are. This
    % has to be tested for every single type of image, and probably changed
    % for different experiments, if the samples don't look very similar.
    % Also the QD density in the images affect this. 
    
    if imtype == 'ms'
        thresh_val_factor = 0.2;
    elseif imtype == 'mr'
        thresh_val_factor = 0.1;
    elseif imtype == 'mq'
        thresh_val_factor = 0.1;
    elseif imtype == 'ps'
        thresh_val_factor = 0.04;
    elseif imtype == 'pr'
        thresh_val_factor = 0.04;
    end
    
    pixelsize = 10/333;

    fftSTEDimage = fftshift(fft2(STEDimage));
    origin = [round((size(fftSTEDimage,2)-1)/2+1) round((size(fftSTEDimage,1)-1)/2+1)]; % "center" of the matrix
    radius = 0.150 / pixelsize * 10; % radius for a circle that has the cutoff frequency around the confocal resolution
    [xx,yy] = meshgrid((1:size(fftSTEDimage,2))-origin(1),(1:size(fftSTEDimage,1))-origin(2)); % create x and y grid
    fftSTEDimage(sqrt(xx.^2 + yy.^2) >= radius) = 0; % set points inside the radius equal to one
    spatSTEDimage = ifft2(fftSTEDimage);  % fourier transform back to spatial domain
    spatSTEDimage = abs(spatSTEDimage);  % image that you get back is complex valued
    
    imgsort = sort(spatSTEDimage(:), 'descend');
    thresh_val = imgsort(ceil(length(imgsort) * thresh_val_factor));

    spatSTEDimage(spatSTEDimage < thresh_val) = 0;  % remove background from image to only get real peaks
    maximumimg = imregionalmax(spatSTEDimage);  % Find all the peaks
    [ypositions, xpositions] = find(maximumimg);  % Find all the ones in the image
    
    maxima(:,1) = xpositions;
    maxima(:,2) = ypositions;

end
