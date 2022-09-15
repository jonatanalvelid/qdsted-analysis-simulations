% Testing to plot some Mowiol images, and finding good QDs to use
pause on
singleQDsize = 8;
m = 1;
save = 1;

% cons = heads_single_PBS;
% consblink = blink_s_P;

% cons = heads_single_mowiol;
% consblink = blink_s_m;

% cons = heads_rep_mowiol;
% consblink = blink_r_m;

cons = heads_quick_rep_mowiol;
consblink = blink_qr_m;

noimages = length(cons);

fig = figure(1);
set(gcf, 'Position', [300, 300, 800, 800]);
while m <= noimages
    noQDs = length(cons(m).x);
    i = 1;
    while i <= noQDs
        fullSTEDim = cons(m).STED_510;
        [ysize,xsize] = size(fullSTEDim);
        xc = cons(m).x(i);
        yc = cons(m).y(i);
        xmin = max(1,xc-singleQDsize);
        xmax = min(xc+singleQDsize,xsize);
        ymin = max(1,yc-singleQDsize);
        ymax = min(yc+singleQDsize,ysize);
        STEDim = cons(m).STED_510(ymin:ymax,xmin:xmax);
        STEDoim = cons(m).STEDonly(ymin:ymax,xmin:xmax);
        maskim = consblink(m).mask(ymin:ymax,xmin:xmax);
        subim = STEDim-STEDoim;
        subim(subim < 0) = 0;
        
        if save
            file_name_mask = sprintf('Image_%d_QD_%d-mask.tif', m, i);
            file_name_STEDsub = sprintf('Image_%d_QD_%d-STEDsub.tif', m, i);
            
            imwrite(mat2gray(maskim),file_name_mask)
            imwrite(mat2gray(subim),file_name_STEDsub)
        end
        
        subplot(2,2,1)
        imshow(STEDim,[0 max(STEDim(:))])
        title(strcat('Image number: ', num2str(m), ', QD number: ', num2str(i)))
        subplot(2,2,2)
        imshow(STEDoim,[0 max(STEDoim(:))])
        subplot(2,2,3)
        imshow(subim,[0 max(subim(:))])
        subplot(2,2,4)
        imshow(maskim,[])

    %     pause(2) % Sleep for x seconds until showing the next one. 

        was_a_key = waitforbuttonpress;
        if was_a_key && strcmp(get(fig, 'CurrentKey'), 'leftarrow')
          i = i - 1;
          if i == 0
              i = 1;
          end
        elseif was_a_key && strcmp(get(fig, 'CurrentKey'), 'downarrow')
          i = i - 10;
          if i <= 0
              i = 1;
          end
        elseif was_a_key && strcmp(get(fig, 'CurrentKey'), 'uparrow')
          i = i + 10;
        elseif was_a_key && strcmp(get(fig, 'CurrentKey'), 'rightarrow')
          i = i + 1;
        end
    end
    m = m + 1;
end