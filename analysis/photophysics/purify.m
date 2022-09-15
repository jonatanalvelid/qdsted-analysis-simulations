function [new_x_max,new_y_max,new_mask,av_bkg] = purify(image,x_max,y_max,mask,lambda,pixel_size,varargin)
%PURIFY Purifies the maxima list
%   Purifies the maxima list from the ones that is not good to consider. It
%   returns the updated list of maxima, a mask with informations regarding
%   the elimination reason and the average bkg in the image.

%% initialization
new_mask = mask;

%assign the optional variables
l = length(varargin);

if l<1 || isempty(varargin{1})
    confidence = 0.99;
else
    confidence = varargin{1};
end

if l<2 || isempty(varargin{2})
    ratio = 0.2;  %threshold for an acceptable ratio min/max
else
    ratio = varargin{2};
end

if l<3 || isempty(varargin{3})
    radius = lambda;      %radius used for the determination of background (lambda/2*2)
                            %another suggested value = lambda/2
else
    radius = varargin{3};
end

if l<4 || isempty(varargin{4})
    width_rep = 3;    %window size for the repositioning of the maxima
    height_rep = 3;
else
    width_rep = varargin{4}(1);
    height_rep = varargin{4}(2);
end

if l<5 || isempty(varargin{5})
    width_inten = 3;    %window size for the intensity check 
    height_inten = 3;
else
    width_inten = varargin{5}(1);
    height_inten = varargin{5}(2);
end

if l<6 || isempty(varargin{6})
    imgsort = sort(image(:),'descend');
    thresh_peak_factor = 0.005;  % was 0.002 originally. Changed 181210.
    thresh_peak = imgsort(ceil(length(imgsort) * thresh_peak_factor));
    %thresh_peak = max(max(image))/5;    %threshold for big cluster peaks to be removed
else
    thresh_peak = varargin{6};
end

%% repositioning of the maxima
for i = 1:length(x_max)
    [x_mean, y_mean] = return_mean_position(image, x_max(i), y_max(i), width_rep, height_rep);
    if ~isnan(x_mean) && ~isnan(y_mean)
        x_mean = round(x_mean);
        y_mean = round(y_mean);
        if (x_mean ~= x_max(i) || y_mean ~= y_max(i))
            %Change the position. MARKER=4
            new_mask(y_max(i), x_max(i)) = 4;
            new_mask(y_mean, x_mean) = 1;
        end
    end
end

%update maxima list and mask
[y_max, x_max] = find(new_mask == 1);

%% analysis of the background

%determination of the background characteristics
[~,~,mask_bkg] = bkg(image,x_max,y_max,radius,pixel_size);
%determination of the threshold with custom distribution
%thresh_bkg=poisson_thres(round(av_bkg),confidence);    %old one
%new one
% figure()
% imshow(mask_bkg, [0,1])
[prob_bkg,~] = histcounts(image(mask_bkg),-0.5:1:(max(max(image(mask_bkg)))+0.5),'Normalization','probability');
thresh_bkg = custom_thres(prob_bkg,confidence);

%% purification looking at the intensity of each peak
for i = 1:length(x_max)
    %integrate the signal in a ""reasonble"" neighbourhood
    if return_mean_maxima(image, x_max(i), y_max(i), width_inten, height_inten) < thresh_bkg
        %the maximum can be considered a fluctuation
        %exclude the maximum. MARKER = 2
        new_mask(y_max(i), x_max(i)) = 2;
    elseif return_mean_maxima(image, x_max(i), y_max(i), width_inten, height_inten) > thresh_peak
        %the maximum can be considered a big cluster
        %exclude the maximum. MARKER = 2
        new_mask(y_max(i), x_max(i)) = 2;
    end
end

%update background
%NOTE: we may insert here a control -> if the bkg changes too much, it is
%likely there is some error in the process (maybe we should adjust the
%parameters).
[av_bkg, ~, ~] = bkg(image, x_max, y_max, radius, pixel_size);

%update maxima list and mask
[y_max, x_max] = find(new_mask == 1);

%% purification looking at the distances between each peak
for i = 1:(length(x_max) - 1)
    for j = (i + 1):length(x_max)
        %calculate distance in metric unities
        distance = sqrt((x_max(i) - x_max(j))^2 + (y_max(i) - y_max(j))^2)*pixel_size;
        %check if we are under diffraction limit (lambda/2)
        %CHANGE: changed this to instead be below 0.8x the wavelength (lambda).
        %We do not want any analysis where two QDs are overlapping in any way.
        if distance < 0.7*lambda
            new_mask(y_max(i), x_max(i)) = 3;
            new_mask(y_max(j), x_max(j)) = 3;
        end 
    end
end

% %% purification looking at the distances and the profiles between each peak
% for i = 1:(length(x_max) - 1)
%     for j = (i + 1):length(x_max)
%         %calculate distance in metric unities
%         distance = sqrt((x_max(i) - x_max(j))^2 + (y_max(i) - y_max(j))^2)*pixel_size;
%         %check if we are under diffraction limit (lambda/2)
%         %CHANGE: changed this to instead be below 2x the wavelength (lambda).
%         %We do not want any analysis where two QDs are interfering.
%         if distance < 2*lambda
%             %check intensity profile 
%             %NOTE: WOULD BE NICE TO ADD HERE A SMART NEIGHBOURHOOD LINE PROFILE
%             profile = improfile(image, [x_max(i), x_max(j)], [y_max(i), y_max(j)]);
%             if max(min(profile), av_bkg) >= ratio*max(profile)  %can be changed with only min(profile)!!
%                 %delete the two peaks. MARKER=3
%                 new_mask(y_max(i), x_max(i)) = 3;
%                 new_mask(y_max(j), x_max(j)) = 3;
%             end
%         end 
%     end
% end

%update maxima list and mask (definitive)
[new_y_max,new_x_max] = find(new_mask==1);

end

