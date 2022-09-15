function [threshold] = poisson_thres(mean,confidence,x)
%POISSON_THRES gives the threshold with a certain confidence
%   Analyzes the poisson cumulative distribution and returns the threshold
%   ensuring the given confidence

if nargin<3
    x=0;
end

if poisscdf(x+1,mean)>=confidence
    threshold=x+0.5;
else
    threshold=poisson_thres(mean,confidence,x+1);
end
end

