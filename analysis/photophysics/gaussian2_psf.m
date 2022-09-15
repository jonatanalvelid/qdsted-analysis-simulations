function [f,area,psf] = gaussian2_psf(heads,radius,pixel_size)
%GAUSSIAN2_PSF Returns a fitting of the psf in the x direction
%   Takes the average intensity distribution considering all the maxima in
%   all the frames. Returns a fit of the normalized average of the 3 central rows
%   using a double gaussian model

%transformation in pixel coordinates
radius = round(radius/pixel_size);

%% creation of the average bidimensional psf (without border maxima)
% NOTE: average bkg is substracted in this stage

area = zeros(2*radius + 1, 2*radius + 1);

n = 0;

for j = 1:length(heads)
    %purify maxima near the border
    [height, width] = size(heads(j).mask);
    %eliminate the outer frame
    heads(j).mask(1:radius, :) = 0;
    heads(j).mask((height-radius):height, :) = 0;
    heads(j).mask(:, 1:radius) = 0;
    heads(j).mask(:, (width-radius):width) = 0;
    %create the new list of maxima
    [heads(j).y, heads(j).x] = find(heads(j).mask == 1);
    
    bkg = heads(j).av_bkg_STED_510*ones(size(area));
    
    for i=1:length(heads(j).x)
        add = heads(j).STED_510(heads(j).y(i)-radius:heads(j).y(i)+radius,...
            heads(j).x(i)-radius:heads(j).x(i)+radius);
        area = area+add-bkg;
        n = n+1;
    end
end

area = area./n;

%% creation of the normalized monodimensional psf
psf = zeros(1, length(area));
imax = 2;
for i = 0:imax
    psf = psf + area(radius+i-round(imax/2),:)/max(area(radius+i-round(imax/2),:));
end
psf = psf/3;

%% fitting (double Gaussians)
% gauss2_custom = 'a1*exp(-((x-b)/c1)^2)+a2*exp(-((x-b)/c2)^2)';
% f = fit((1:length(psf))', double(psf'), gauss2_custom, 'start', [0.55, 0.45, radius+1, radius, radius]);

% %% fitting alternative (single Gaussian)
% gauss_custom = 'a*exp(-((x-b)/c)^2)';
% f = fit((1:length(psf))', double(psf'), gauss_custom, 'start', [0.55, radius+1, radius]);

%% fitting (Lorentzian + Gaussian)
lorgauss_custom = 'a1/(((x-b)/(0.5*c1))^2+1)+a2*exp(-((x-b)/c2)^2)+d';
f = fit((1:length(psf))', double(psf'), lorgauss_custom,...
                                'start', [0.8, 0.2, radius+1, radius/2, radius, 0.1],...
                                'lower', [0, 0, radius+1-2, 0, 0, 0],...
                                'upper', [1, 1, radius+1+2, radius, radius*2, 0.3]);

end

