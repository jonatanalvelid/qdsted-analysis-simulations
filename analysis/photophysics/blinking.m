function [blink,heads] = blinking(heads,f,radius1,radius2,pixel_size,varargin)
%BLINKING Returns an analysis of the blinking of the dots
%   It fits all the lines of all the dots of all the frames and determines
%   the blinking pixels. The mask contains the full information about the
%   blinking.
%   f:  cfit variable containing psf informations
%   radius1:	radius used for fitting window
%   radius2:    radius used for circular mask  
%   varargin contains all the possible optional parameters as specified in
%   the first paragraph

%assign the optional variables
l=length(varargin);

if l<1 || isempty(varargin{1})
    confidence = 0.99;    %default. another suggestion = 0.99
else
    confidence = varargin{1};
end

%transformation in pixel coordinates
radius1_p = round(radius1/pixel_size);
radius2_p = radius2/pixel_size;

%structure containing information about blinking
blink = struct('mask',[],'n_scanned',[],'n_blink',[],'blinkratio',[]);

%fitting function
coeff = coeffvalues(f);
% gauss2_custom = sprintf('%f*a*exp(-((x-b)/%f)^2)+a*exp(-((x-b)/%f)^2)', coeff(1)/coeff(2), coeff(4), coeff(5));
% lorgauss_custom = sprintf('%f*a/(((x-b)/(0.5*%f))^2+1)+a*exp(-((x-b)/%f)^2)+d', coeff(1)/coeff(2), coeff(4), coeff(5));
% lorgauss_custom_new = sprintf('%f*a/(((k1*(x-b))/(0.5*%f))^2+1)+a*exp(-((k2*(x-b))/%f)^2)+d', coeff(1)/coeff(2), coeff(4), coeff(5));
lorgauss_custom_new_nobkg = sprintf('%f*a/(((k*(x-b))/(0.5*%f))^2+1)+a*exp(-((k*(x-b))/%f)^2)', coeff(1)/coeff(2), coeff(4), coeff(5));
func = lorgauss_custom_new_nobkg;

% spno = 1;
%for i=1:lastimageno
for i=1:length(heads)
    fprintf('Frame number:   %i\n', i);
    %initialize variables
    blink(i).mask = zeros(size(heads(i).STED_510));
    blink(i).n_scanned = 0;
    blink(i).n_blink = 0;
    
    %create background mask
    [bkg_av, bkg_std, mask_bkg] = bkg(heads(i).STED_510, heads(i).x, heads(i).y, radius1, pixel_size);
        
    %determination of the threshold with custom distribution
    [prob_bkg, ~] = histcounts(heads(i).STED_510(mask_bkg), -0.5:1:(max(max(heads(i).STED_510(mask_bkg))) + 0.5), 'Normalization', 'probability');
    thresh_bkg = custom_thres(prob_bkg, confidence) - heads(i).av_bkg_STED_510;
    
    %exclude maxima near the border (eliminate the outer frame)
    [height,width]=size(heads(i).mask);
    heads(i).mask(1:radius1_p,:)=0;
    heads(i).mask((height-radius1_p):height,:)=0;
    heads(i).mask(:,1:radius1_p)=0;
    heads(i).mask(:,(width-radius1_p):width)=0;
    
    %exclude maxima that are not separated enough
    for m=1:(length(heads(i).x)-1)
        for n=(m+1):length(heads(i).x)
            %calculate distance in metric unities
            distance=sqrt((heads(i).x(m)-heads(i).x(n))^2+(heads(i).y(m)-heads(i).y(n))^2);
            %check if we are under the threshold
            if distance<(2*radius2_p)
                %delete the two maxima
                heads(i).mask(heads(i).y(m),heads(i).x(m))=0;
                heads(i).mask(heads(i).y(n),heads(i).x(n))=0;
            end
        end
    end
    
    %create the new list of maxima
    [heads(i).y,heads(i).x]=find(heads(i).mask==1);

    %subtract background
    heads(i).STED_510=heads(i).STED_510-heads(i).av_bkg_STED_510*ones(size(heads(i).STED_510));
    
%     figure()
%     m = 1;
    %scan maxima
    radius2_p_allj = 0;
    for j = 1:length(heads(i).x)
        x_cornerlow = heads(i).x(j)-radius1_p;
        x_cornerhigh = heads(i).x(j)+radius1_p;
        y_cornerlow = heads(i).y(j)-radius1_p;
        y_cornerhigh = heads(i).y(j)+radius1_p;
        %Check the distance from the center coordinate of the QD to the
        %furthest bright pixel (int > bkg_av + bkg_std) and only look at
        %the circular region going out that far. We cannot say anything
        %about the things outside of this realistically. Then we can set
        %everything inside this as bright initially, and assign pixels to
        %blinking if they do not pass the fitting tests and so on. 
        square = heads(i).STED_510(y_cornerlow:y_cornerhigh, x_cornerlow:x_cornerhigh);
        markersquare = zeros(size(square));
        markersquare(square > thresh_bkg) = 1;
        sizesquare = size(markersquare);
        longdist = 0;
        for n = 1:sizesquare(1)
            for m = 1:sizesquare(1)
                if markersquare(n,m) == 1
                    dist = sqrt((n - radius1_p)^2 + (m - radius1_p)^2);
                    if dist > longdist
                        longdist = dist;
                    end
                end
            end
        end
        radius2_p_new = max(round(longdist)-1, 2);
        radius2_p_allj = [radius2_p_allj, radius2_p_new];
        % nopixelsyet = 0;
        %scan lines
        for h = 0:2*radius1_p
            %disp(h)
            %take line on height h (from top to bottom of QD), from end to
            %end in x of the radius defined in the function inputs
            x_corner = heads(i).x(j)-radius1_p;
            y_corner = heads(i).y(j)-radius1_p;
            line = heads(i).STED_510(y_corner+h,x_corner:(x_corner+2*radius1_p));
            line(line < 0) = 0;  % Clear up the line for any unphysical values, put negative values to 0. 
            
            linemax = max(line);
            % thresh = max([thresh_bkg, mean(line)]);
%             exclude = find(line < bkg_av);  % DO NOT DO THIS, INSTEAD
%             ENTER THE FITTING THE FIRST TIME, AND SEE WHICH OF THE POINTS
%             ARE EXPECTED TO BE BASICALLY BACKGROUND AND WHICH ARE NOT.
%             THEN EXCLUDE POINTS BASED ON THAT. SINCE POINTS TOWARDS THE
%             ENDS OF THE LINE SHOULD BE BACKGROUND BASICALLY. Only do
%             this if basically the whole line is below the background,
%             then all should be considered blinking. 
            exclude = [];
            left = left_positions(length(line), exclude);
            done = 0;
            marker = 2*ones(size(line));    %all points are considered bright in the beginning: MARKER FOR BRIGHT = 2
            
            %CHANGE: try instead to put all pixels to zero in the
            %beginning, then keep it that way if no pixels are brighter
            %than 
            %%%
%             if ~nopixelsyet
%                 marker = zeros(size(line));  % Put all pixels in the line to background.
%                 if max(line) > bkg_av + bkg_std
%                     marker(line > bkg_av + bkg_std) = 2;
%                     nopixelsyet = 1;
%                 else
%                     done = 1;
%                 end
%             else
%                 marker = 2*ones(size(line));  % Put all pixels in the line to bright.
%             end
            %%%
            
            %CHANGE: do not mark points as blinking
            %just because they are dark outside the center of the
            %donut, this is exactly what we should have, and we
            %cannot tell that there is any blinking event there
            %because of this. Instead, mark every pixel that comes
            %before the first and after the last bright pixel as
            %background. This is obviously not completely correct
            %either, but helps a bit in fitting differently sized
            %lines, and if a line on the outside of the dot has
            %only background. 
%             if line(1) < thresh
%                 marker(1:find(line > thresh, 1) - 1) = 0;  %MARKER FOR BACKGROUND = 0
%                 % exclude = [exclude, 1:find(line < thres, 1)];
%             end
% 
%             if line(end) < thresh
%                 marker(find(line > thresh, 1, 'last') + 1:end) = 0;  %MARKER FOR BACKGROUND = 0
%             end
%             marker(line < (bkg_av - bkg_std)) = 1;  %MARKER FOR BLINKED
%             marker(line < thresh_bkg) = 1;  %MARKER FOR BLINKED

            if sum(line < (bkg_av + bkg_std)) == length(line)
                marker(1:length(line)) = 1;
                done = 1;
            end
            %%%% EXCLUDE THESE POINTS ABOVE.
            while ~done
                %check if we have enough points
                    
%                 if (length(line) - length(exclude)) < 4
%                     %mark points that are not above as blinking (OR
%                     %BACKGROUND???)
%                     marker(line < bkg_av) = 1;  %MARKER FOR BLINKED
%                     done = 1;
%                 else
                    %disp('hey')
                if (length(line) - length(exclude)) > 2
%                     line_fit = fit((1:length(line))', double(line'), func, 'Exclude', exclude,...
%                                                 'start', [linemax/2, (length(line)+1)/2, bkg_av],...
%                                                 'lower', [linemax/4, (length(line)+1)/2.1, 0],...
%                                                 'upper', [linemax*2, (length(line)+1)/1.9, bkg_av*2]);
                    %NEW for lorentian_custom_new
                    line_fit = fit((1:length(line))', double(line'), func, 'Exclude', exclude,...
                                                'start', [linemax/2, (length(line)+1)/2, 1],...
                                                'lower', [linemax/4, (length(line)+1)/2.1, 0.8],...
                                                'upper', [linemax*2, (length(line)+1)/1.9, 1.2]);
%                                                 'start', [linemax/2, (length(line)+1)/2, bkg_av, 1, 1],...
%                                                 'lower', [linemax/4, (length(line)+1)/2.1, 0, 0.9, 0.9],...
%                                                 'upper', [linemax*2, (length(line)+1)/1.9, bkg_av*2, 1.1, 1.1]);


                    %coeffvalues(line_fit)
                    residuals = line-line_fit(1:length(line))';
                    error = sqrt(line_fit(1:length(line))'); %CHANGE: Instead of the poissonian noise, take 2x the poissonian noise. OR NOT! Instead add a rule that if the pixel is brigther than certain value, consider the pixel to be BRIGHT anyway.
                    if sum(residuals(left) > error(left)) ~= 0 %Check if there is still some points in the line which deviates from the fitted line by more than the poissonian noise.
                        %the fitting is not good
                        %delete the most negative residual
                        exclude = [exclude, find(residuals == min(residuals(left)))];
                        left = left_positions(length(line), exclude);
                    else
                        %the fitting is good
                        %CHANGE: add a second check here below, in case the
                        %pixel is still very bright, line > linemax/1.5, it
                        %should not be marked as blinking, as it still
                        %contains a lot of information for us and we do not
                        %really care. 
                        marker(residuals < -error & line < linemax/1.5 & marker ~= 0) = 1;  %MARKER FOR BLINKED = 1
                        % marker(line_fit(1:length(line))' < bkg_std) = 0;    %MARKER FOR BACKGROUND = 0
                        % marker(line_fit(1:length(line))' < bkg_av*2) = 0;    %MARKER FOR BACKGROUND = 0

                        % disp('FINALLY')
                        done = 1;
                        
                        fitcheck = 0;
                        if fitcheck
                            % Outputs to check if the fitting is good
                            subplot(5,5,spno)
                            spno = spno+1;
                            if spno == 26
                                spno = 1;
                                figure()
                            end
                            try
                                plot(line_fit,(1:length(line)),double(line),exclude)
                                hold on
                                plot(1:length(line),marker*max(line)/max(marker))
                            catch err
                            end
                            b = gca;
                            legend(b,'off')
                            line_fit
                        end
                    end
                else
                    done = 1;
                end
            end     %end fitting line

%             % Outputs to check if the fitting is good
%             marker
%             exclude
%             subplot(5,5,m)
%             x = (1:length(line))';
%             plot(x, line)
%             hold on
%             if exist('line_fit','var') == 1
%                 plot(line_fit)
%             end
%             m = m+1;
            %update the blinking mask
            blink(i).mask(y_corner+h, x_corner:(x_corner + 2 * radius1_p)) = marker;
        end     %end scanning lines
        % Figure out how much of the QD is blinking, in terms of pixels,
        % i.e. the blinking ratio
    end     %end scanning maxima of a frame
    
    %prettify the frame transforming the squares in circular regions
    mask_circles = zeros(size(heads(i).STED_510));
    for j = 1:length(heads(i).x)
        mask_circles = insertShape(mask_circles, 'filledcircle',...
            [heads(i).x(j), heads(i).y(j), min(radius2_p_allj(j), radius2_p)], 'LineWidth', 1, 'color', 'white');
        mask_circles_single = zeros(size(mask_circles));
        mask_circles_single = insertShape(mask_circles_single, 'filledcircle',...
            [heads(i).x(j), heads(i).y(j), min(radius2_p_allj(j), radius2_p)], 'LineWidth', 1, 'color', 'white');
        mask_circles_single = rgb2gray(mask_circles_single);
        mask_circles_single = imbinarize(mask_circles_single, 0);
        singleqdmask = blink(i).mask .* mask_circles_single;
        heads(i).npixelsblinkmask(j) = nnz(singleqdmask);
        heads(i).nbrightpx(j) = nnz(singleqdmask == 2);
        heads(i).nblinkpx(j) = nnz(singleqdmask == 1);
    end
    mask_circles = rgb2gray(mask_circles);
    mask_circles = imbinarize(mask_circles, 0);
    blink(i).mask = blink(i).mask .* mask_circles;
%     %update the blinking values
%     blink(i).n_scanned = sum(sum(blink(i).mask ~= 0));
%     blink(i).n_blink = sum(sum(blink(i).mask == 1));
    %update the blinking values
    blink(i).n_scanned = heads(i).npixelsblinkmask;
    blink(i).n_blink = heads(i).nblinkpx;
    blink(i).blinkratio = heads(i).nblinkpx ./ heads(i).npixelsblinkmask;
end     %end scanning frames
end
                