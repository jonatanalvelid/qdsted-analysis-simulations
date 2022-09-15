function [blinking, bright] = analyze_brightness_blinking(heads, blink)
%ANALYZE_BRIGHTNESS_BLINKING Provides an analysis of the
%   brightness/reexcitation of the blinking process
%   The output is two structures containing the mean and the std of the
%   brightness of the pixels (blinking or bright) in the STED+510 image
%   NOTE: it automatically subtracts the average background in each frame

blink_array = [];
bright_array = [];
for i = 1:length(blink)
    add = heads(i).STED_510(blink(i).mask == 1)';
    bkg = heads(i).av_bkg_STED_510 * ones(size(add));
    blink_array = [blink_array, (add-bkg)];
    add = heads(i).STED_510(blink(i).mask == 2)';
    bkg = heads(i).av_bkg_STED_510 * ones(size(add));
    bright_array = [bright_array, add-bkg];
end

blinking.av = mean(blink_array);
blinking.std = std(blink_array);

bright.av = mean(bright_array);
bright.std = std(bright_array);

end

