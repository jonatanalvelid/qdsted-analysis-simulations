function [new_heads] = purify_clusters_heads(heads,radius,pixel_size,threshold)
%PURIFY_CLUSTERS_HEADS Exludes the maxima over a certain threshold
%   Integrates the intensity of each maxima in a circular area of the given
%   radius. It excludes the maxima which are too bright (supposed to be clusters)
%   The output is a new header
%
%NOTE: the radius should be the one used for the threshold

%% initialization
%transform the radius in pixels units
radius = radius/pixel_size;

%initialize new_heads
new_heads = heads;

%% eliminate the peaks which are not fully contained in the image
for i=1:length(heads)
    [height,width] = size(heads(i).mask);
    %eliminate the outer frame
    heads(i).mask(1:round(radius),:) = 0;
    heads(i).mask((height-round(radius)):height,:) = 0;
    heads(i).mask(:,1:round(radius)) = 0;
    heads(i).mask(:,(width-round(radius)):width) = 0;
    %create the new list of maxima
    [heads(i).y, heads(i).x] = find(heads(i).mask == 1);
end

%% analysis of the brightness
for i = 1:length(heads)
    %read the maxima of the image
    for j = 1:length(heads(i).x)
        %create circular mask
        mask = insertShape(zeros(size(heads(i).STEDonly)), 'filledcircle',...
            [heads(i).x(j), heads(i).y(j), radius], 'LineWidth', 1, 'color', 'white');
        mask = rgb2gray(mask);
        mask = imbinarize(mask, 0);
        %integrate signal and subtract estimated background
        n_pixel = sum(sum(mask));
        bkg = n_pixel*heads(i).av_bkg_STED_510;
        %check intensity
        if (sum(sum(heads(i).STED_510(mask))) - bkg) > threshold
            %delete maxima. MARKER=5
            new_heads(i).mask(heads(i).y(j), heads(i).x(j)) = 5;
        end
    end
    %update the list of the maxima
    [new_heads(i).y, new_heads(i).x] = find(new_heads(i).mask == 1);
    %NOTE: the background has not to be updated because clusters are bright
    %structures!
end

end