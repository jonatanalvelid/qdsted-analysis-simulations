function [x_mean, y_mean] = return_mean_position(image, x_max, y_max, width, height)
%RETURN_MEAN_POSITION Returns the mean position
%   Returns the mean position in a specified rectangular region
%   around the given maximum. The weight factor is the intensity.

%create mask around the center (see function bkg)
mask = zeros(size(image));
mask = insertShape(mask, 'filledrectangle', [x_max - width / 2, y_max - height / 2, width, height],...
    'LineWidth', 1, 'color', 'white');
%transform in BW
mask = rgb2gray(mask);
%transform in binary
mask = imbinarize(mask, 0);

c = sum(sum(image .* mask));    %normalization factor

%determination of the x
temp = sum(image .* mask);  %marginal sum of the columns
x_mean = 0;
for i = 1:length(temp)
    x_mean = x_mean + i * temp(i);
end
x_mean = x_mean / c;

%determination of the y
temp = sum(image .* mask, 2);    %marginal sum of the rows
y_mean = 0;
for i = 1:length(temp)
    y_mean = y_mean + i * temp(i);
end
y_mean = y_mean / c;

end

