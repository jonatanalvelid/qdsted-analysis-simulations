function [singleBool] = singleQDCheck(imgQDSonly, xpos, ypos, pixelsize)
    %----PARAMETERS TO TWEAK----
    numval = 9;
    thratio = 8; 
    bkgthfactor = 2;
    bkgcirclemaskradius = 1.0; % um
    diamavg = 0.600;
    diamcenter = 0.125;
    %---------------------------

    pxradavg = round(diamavg/2/pixelsize);
    pxradcenter = round(diamcenter/2/pixelsize);
    singleBool = zeros(size(xpos));

    maxim = max(imgQDSonly(:));
    imgQDSonly = imgQDSonly/maxim;
    [bkg_av, bkg_std, ~] = bkg(imgQDSonly,xpos,ypos,bkgcirclemaskradius,pixelsize);
    thbkg = bkg_av + bkg_std;

    numcircles = size(xpos);
    if ~isempty(xpos)
        for n = 1:numcircles
            [xgrid, ygrid] = meshgrid(1:size(imgQDSonly,2), 1:size(imgQDSonly,1));
            maskcenter = ((xgrid-xpos(n)).^2 + (ygrid-ypos(n)).^2) <= pxradcenter.^2;
            maskcircle = ((xgrid-xpos(n)).^2 + (ygrid-ypos(n)).^2) <= pxradavg.^2;
            centerval = sort(imgQDSonly(maskcenter),'ascend');
            circleval = sort(imgQDSonly(maskcircle),'descend');

            mincenter = mean(centerval(1:numval));
            maxcircle = mean(circleval(1:numval));

            if maxcircle/mincenter > thratio || maxcircle < thbkg
                singleBool(n) = 1;
            end
        end
    end
end