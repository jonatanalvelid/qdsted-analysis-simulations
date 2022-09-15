function [new_heads] = purify_heads(heads,lambda,pixel_size,varargin)
%PURIFY_HEADS Creates new_heads, which is an array of purified images structs

%% initialization
%initialize the output
new_heads = heads;

%assign the optional variables
l=length(varargin);

if l<1 || isempty(varargin{1})
    check_clusters=1;
else
    check_clusters=varargin{1};
end

if l<2 || isempty(varargin{2})
    radius1=lambda/2;   %radius used for updating the background in the STEDonly images
                        %NOTE: even if it's not suggested, this could be a different value than the one used in the "purify" function
else
    radius1=varargin{2};
end

if l<3 || isempty(varargin{3})
    radius2=lambda/4;   %radius used in the cluster purification algorithm
else
    radius2=varargin{3};
end

%% purification
for i = 1:length(new_heads)
    fprintf('Frame number:   %i\n', i);
    %update x, y, mask, av_bkg_STED_510
    [new_heads(i).x, new_heads(i).y, new_heads(i).mask, new_heads(i).av_bkg_STED_510] = ...
        purify(new_heads(i).STED_510, new_heads(i).x, new_heads(i).y,...
        new_heads(i).mask, lambda, pixel_size);
%     [new_heads(i).xalt,new_heads(i).yalt, new_heads(i).maskalt, new_heads(i).av_bkg_STED_510] = ...
%         purify(new_heads(i).STED_510, new_heads(i).xalt, new_heads(i).yalt,...
%         new_heads(i).maskalt, lambda, pixel_size);
    %update av_bkg_STEDonly 
    [x, y] = find(heads(i).mask==1 | heads(i).mask==3);
    [new_heads(i).av_bkg_STEDonly, ~, ~] = bkg(new_heads(i).STEDonly, x, y, radius1, pixel_size);
end

%% check for clusters (and purification)
if check_clusters
    
    fprintf('Deleting clusters...\n');
    
    %determine threshold for clusters
    done = 0;
    threshold = Inf;
    [I_STED_510, ~] = analyze_brightness(new_heads, radius2, pixel_size);
    while ~done
        %calculate upper whisker for extreme outliers
        IQ = quantile(I_STED_510(I_STED_510 < threshold), 0.75) - quantile(I_STED_510(I_STED_510 < threshold), 0.25);
        new_threshold = quantile(I_STED_510, 0.75) + 3*IQ;
        if sum(I_STED_510(I_STED_510 < threshold) > new_threshold) == 0
            %we have no more outliers
            done = 1;
        else
            threshold = new_threshold;
        end
    end
    
    %purify the maxima again (radius as defined for analyze_brightness)
    new_heads = purify_clusters_heads(new_heads, radius2, pixel_size, threshold);

end
