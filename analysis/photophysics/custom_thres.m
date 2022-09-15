function [threshold] = custom_thres(prob_bkg,confidence)
%CUSTOM_THRES gives the threshold with a certain confidence
%   Analyze the cumulative distribution created using the actual background histogram.
%   It returns the threshold ensuring the given confidence

cumulative = zeros(size(prob_bkg));
cumulative(1) = prob_bkg(1);
for i = 2:length(prob_bkg)
    cumulative(i) = cumulative(i-1) + prob_bkg(i);
end
% disp(cumulative)
threshold = find(cumulative > confidence, 1) - 0.5;
end

