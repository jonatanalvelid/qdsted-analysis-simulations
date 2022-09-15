pixelsize = 30;

%% read and purify
% heads_single_mowiol = read_data('D:\Data analysis\QDs\QD - Characterization\Data\Mowiol\181207\Single_Analysis', 'ms');
% heads_single_mowiol = purify_heads(heads_single_mowiol,510,pixelsize,1);

% heads_rep_mowiol = read_data('D:\Data analysis\QDs\QD - Characterization\Data\Mowiol\181207\Rep_Analysis', 'mr');
% heads_rep_mowiol = purify_heads(heads_rep_mowiol,510,pixelsize,1);

heads_single_PBS = read_data('D:\Data analysis\QDs\QD - Characterization\Data\PBS\181207\Single_Analysis', 'ps');
heads_single_PBS = purify_heads(heads_single_PBS,510,pixelsize,1);

% heads_rep_PBS = read_data('D:\Data analysis\QDs\QD - Characterization\Data\PBS\181207\Rep_Analysis', 'pr');
% heads_rep_PBS = purify_heads(heads_rep_PBS,510,pixelsize,1);

%% analyze brightness

radiusBrightness = 510/6;
% [Is5_s_m, Iso_s_m] = analyze_brightness(heads_single_mowiol, radiusBrightness, pixelsize);
% [Is5_r_m, Iso_r_m] = analyze_brightness(heads_rep_mowiol, radiusBrightness, pixelsize);
[Is5_s_P, Iso_s_P] = analyze_brightness(heads_single_PBS, radiusBrightness, pixelsize);
% [Is5_r_P, Iso_r_P] = analyze_brightness(heads_rep_PBS, radiusBrightness, pixelsize);

%show
figure();
histogram(Is5_s_P,'displayname','PBS','normalization','pdf','binwidth',30);
hold on;
histogram(Is5_s_m,'displayname','Mowiol','normalization','pdf','binwidth',60);
legend('show');
title('STED + 510 Single Comparison PBS vs Mowiol');

figure();
histogram(Is5_r_P,'displayname','PBS','normalization','pdf','binwidth',30);
hold on;
histogram(Is5_r_m,'displayname','Mowiol','normalization','pdf','binwidth',60);
legend('show');
title('STED + 510 Repeated Comparison PBS vs Mowiol');

figure();
histogram(Is5_s_m,'displayname','Single','normalization','pdf','binwidth',90);
hold on;
histogram(Is5_r_m,'displayname','Repeated','normalization','pdf','binwidth',90);
legend('show');
title('STED + 510 Comparison Mowiol');

figure();
histogram(Is5_s_P,'displayname','Single','normalization','pdf','binwidth',30);
hold on;
histogram(Is5_r_P,'displayname','Repeated','normalization','pdf','binwidth',30);
legend('show');
title('STED + 510 Comparison PBS');

figure();
histogram(Iso_s_m,'displayname','Single','normalization','pdf','binwidth',30);
hold on;
histogram(Iso_r_m,'displayname','Repeated','normalization','pdf','binwidth',30);
legend('show');
title('STED only Comparison Mowiol');

figure();
histogram(Iso_s_P,'displayname','Single','normalization','pdf','binwidth',10);
hold on;
histogram(Iso_r_P,'displayname','Repeated','normalization','pdf','binwidth',10);
legend('show');
title('STED only Comparison PBS');

% Show the reexcitation of the QDs
figure();
histogram(Iso_s_m./Is5_s_m,'displayname','Single','normalization','pdf','binwidth',0.05);
hold on;
histogram(Iso_r_m./Is5_r_m,'displayname','Repeated','normalization','pdf','binwidth',0.05);
legend('show');
title('STED reexcitation comparison - Mowiol');

figure();
histogram(Iso_s_P./Is5_s_P,'displayname','Single','normalization','pdf','binwidth',0.05);
hold on;
histogram(Iso_r_P./Is5_r_P,'displayname','Repeated','normalization','pdf','binwidth',0.05);
legend('show');
title('STED reexcitation comparison - PBS');

%% analyze blinking

radiusFit = 510/2; %CHANGE: Consider a much smaller radius.

%fit
[f_s_P, area_s_P, psf_s_P] = gaussian2_psf(heads_single_PBS, radiusFit, pixelsize);
[x, y] = meshgrid([1:length(area_s_P)], [1:length(area_s_P)]);
figure();
surf(x, y, area_s_P)
% figure()
% plot(f_s_P,1:length(psf_s_P),psf_s_P)
title('Single PBS');

[f_r_P, area_r_P, ~] = gaussian2_psf(heads_rep_PBS,radiusFit,pixelsize);
[x, y] = meshgrid([1:length(area_r_P)], [1:length(area_r_P)]);
figure();
surf(x,y,area_r_P);
title('Repeated PBS');

[f_s_m, area_s_m, ~] = gaussian2_psf(heads_single_mowiol,radiusFit,pixelsize);
figure();
surf(x,y,area_s_m);
title('Single Mowiol');

[f_r_m, area_r_m, psf_r_m] = gaussian2_psf(heads_rep_mowiol,radiusFit,pixelsize);
[x, y] = meshgrid([1:length(area_r_m)], [1:length(area_r_m)]);
figure();
surf(x,y,area_r_m);
% figure()
% plot(f_r_m,1:length(psf_r_m),psf_r_m)
title('Repeated Mowiol');

% determine blinking and show first frame for check
radiusFit = 510/3;
radiusMask = 510/6; %CHANGE: Consider a much smaller radius, 510/4 --> 510/6.
minInt = 1;
maxInt = 30;

[blink_s_P, heads_single_PBS] = blinking(heads_single_PBS, f_s_P, radiusFit, radiusMask, pixelsize, 0.99);
figure();
subplot(1,2,1);
imshow(blink_s_P(1).mask, [0,2]);
subplot(1,2,2);
imshow(heads_single_PBS(1).STED_510, [minInt, maxInt]);
suptitle('Single PBS');

[blink_r_P, heads_rep_PBS] = blinking(heads_rep_PBS, f_r_P, radiusFit, radiusMask, pixelsize, 0.99);
figure();
subplot(1,2,1);
imshow(blink_r_P(1).mask,[0,2]);
subplot(1,2,2);
imshow(heads_rep_PBS(1).STED_510, [minInt,maxInt]);
suptitle('Repeated PBS');

[blink_s_m, heads_single_mowiol] = blinking(heads_single_mowiol,f_s_m,radiusFit,radiusMask,pixelsize, 0.99);
figure();
subplot(1,2,1);
imshow(blink_s_m(1).mask,[0,2]);
subplot(1,2,2);
imshow(heads_single_mowiol(1).STED_510, [minInt,maxInt]);
suptitle('Single Mowiol');

[blink_r_m, heads_rep_mowiol] = blinking(heads_rep_mowiol,f_r_m,radiusFit,radiusMask,pixelsize, 0.99);
figure();
subplot(1,2,1);
imshow(blink_r_m(1).mask,[0,2]);
subplot(1,2,2);
imshow(heads_rep_mowiol(1).STED_510, [minInt,maxInt]);
suptitle('Repeated Mowiol');


%blinking statistics
n_blinkratio_s_P = blink_s_P(1).blinkratio;
for i = 2:length(blink_s_P)
    n_blinkratio_s_P = [n_blinkratio_s_P blink_s_P(i).blinkratio];
end

n_blinkratio_r_P = 0;
for i=2:length(blink_r_P)
    n_blinkratio_r_P = [n_blinkratio_r_P blink_r_P(i).blinkratio];
end

n_blinkratio_s_m = 0;
for i=2:length(blink_s_m)
    n_blinkratio_s_m = [n_blinkratio_s_m blink_s_m(i).blinkratio];
end

n_blinkratio_r_m = 0;
for i=2:length(blink_r_m)
    n_blinkratio_r_m = [n_blinkratio_r_m blink_r_m(i).blinkratio];
end

clear i

[blinking_s_P, bright_s_P] = analyze_brightness_blinking(heads_single_PBS, blink_s_P);
[blinking_r_P, bright_r_P] = analyze_brightness_blinking(heads_rep_PBS, blink_r_P);
[blinking_s_m, bright_s_m] = analyze_brightness_blinking(heads_single_mowiol, blink_s_m);
[blinking_r_m, bright_r_m] = analyze_brightness_blinking(heads_rep_mowiol, blink_r_m);

%print results
y = [mean(n_blinkratio_s_P), 1 - mean(n_blinkratio_s_P);
    mean(n_blinkratio_r_P), 1 - mean(n_blinkratio_r_P);
    mean(n_blinkratio_s_m), 1 - mean(n_blinkratio_s_m);
    mean(n_blinkratio_r_m), 1 - mean(n_blinkratio_r_m)];
ystd = [std(n_blinkratio_s_P), 0;
    std(n_blinkratio_r_P), 0;
    std(n_blinkratio_s_m), 0;
    std(n_blinkratio_r_m), 0];
names={'Single PBS','Repeated PBS','Single Mowiol','Repeated Mowiol'};
figure();
subplot(1,2,1);
h = bar(y,'stacked');
hold on
he = errorbar(cumsum(y')',ystd,'.k');
l{1}='Blinking'; l{2}='Bright';
legend(h,l,'show');
set(gca,'xticklabel',names);
title('Blinking Ratio');
clear y names l h
y1 = [blinking_s_P.av, blinking_r_P.av, blinking_s_m.av, blinking_r_m.av];
std1 = [blinking_s_P.std, blinking_r_P.std, blinking_s_m.std, blinking_r_m.std];
y2 = [bright_s_P.av, bright_r_P.av, bright_s_m.av, bright_r_m.av];
std2 = [bright_s_P.std, bright_r_P.std, bright_s_m.std, bright_r_m.std];
names = {'Single PBS','Repeated PBS','Single Mowiol','Repeated Mowiol'};
subplot(1,2,2);
errorbar(y1,std1,'o','displayname','Blinking','linewidth',1.5);
hold on;
errorbar(y2,std2,'o','displayname','Bright','linewidth',1.5);
lim=ylim();
set(gca,'xtick',[1:4],'xticklabel',names,'ylim',[0,lim(2)]);
legend('show');
title('Blinking Brightness');
clear y1 std1 y2 std2 names lim
