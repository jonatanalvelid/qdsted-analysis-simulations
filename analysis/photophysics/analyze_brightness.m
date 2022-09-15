function [I_STED_510, I_STEDonly] = analyze_brightness(heads, radius, pixel_size)
%ANALYZE_BRIGHTNESS Provides an analysis of the brightness/reexcitation
%   Integrates the intensity of each maxima in a circular area of the given
%   radius. The output is two arrays containing all the values for both the
%   STED+510 and the STEDonly images
%
%NOTE: suggested radius (that should be expressed in metric unities) is the HWHM

%% transform the radius in pixels units
radius = radius/pixel_size;

%% eliminate the peaks which are not fully contained in the image and count
% how many of them you are going to analyze
n_max = 0;
for i = 1:length(heads)
    [height, width] = size(heads(i).mask);
    %eliminate the outer frame
    heads(i).mask(1:round(radius), :) = 0;
    heads(i).mask((height-round(radius)):height, :) = 0;
    heads(i).mask(:, 1:round(radius)) = 0;
    heads(i).mask(:, (width-round(radius)):width) = 0;
    %create the new list of maxima
    [heads(i).y, heads(i).x] = find(heads(i).mask==1);
    %update the cardinality of the maxima
    n_max = n_max + length(heads(i).x);
end

%% analysis of the brightness
% preallocation of the memory
I_STED_510 = zeros(1, n_max);
I_STEDonly = zeros(1, n_max);

n = 0;  %overall index of scanned maxima

for i = 1:length(heads)
%     disp(i)
    %read the maxima of the image
    for j = 1:length(heads(i).x)
%         disp(j)
        %update the index
        n = n + 1;
        %create circular mask
        mask = insertShape(zeros(size(heads(i).STEDonly)),'filledcircle',...
            [heads(i).x(j),heads(i).y(j), radius], 'LineWidth', 1, 'color', 'white');
        mask = rgb2gray(mask);
        mask = imbinarize(mask, 0);
        
        %integrate signal and subtract estimated background
%         n_pixel = sum(sum(mask));
%         bkg = n_pixel*heads(i).av_bkg_STED_510;
%         I_STED_510(n) = sum(sum(heads(i).STED_510(mask))) - bkg;
%         bkg = n_pixel*heads(i).av_bkg_STEDonly;
%         I_STEDonly(n) = sum(sum(heads(i).STEDonly(mask))) - bkg;
        
        %CHANGE: Put negative pixels to 0 before summing brightness.
        imgSTED = heads(i).STED_510(mask) - heads(i).av_bkg_STED_510;
        imgSTED(imgSTED < 0) = 0;
        imgSTEDonly = heads(i).STEDonly(mask) - heads(i).av_bkg_STEDonly;
        imgSTEDonly(imgSTEDonly < 0) = 0;
        I_STED_510(n) = sum(sum(imgSTED));
        I_STEDonly(n) = sum(sum(imgSTEDonly));
        
        %print specific brightness values of QDs of interest
        if i == 5 && j == 3 || i==1 && j==31 || i==1 && j==4 || i==10 && j==21  % PBS, single
%         if i == 1 && j == 65 || i==2 && j==32 || i==2 && j==71 || i==2 && j==34  % Mowiol, single
%         if i == 3 && j == 9 || i==3 && j==40 || i==1 && j==42 || i==3 && j==24  % Mowiol, repeated
%         if i == 4 && j == 15 || i==1 && j==14 || i==1 && j==20 || i==4 && j==11  % Mowiol, quick repeated  
            disp(n)
            disp(i)
            disp(j)
            disp(I_STED_510(n))
            disp(heads(i).x(j))
            disp(heads(i).y(j))
            disp('...')
        end
    end
end


end

