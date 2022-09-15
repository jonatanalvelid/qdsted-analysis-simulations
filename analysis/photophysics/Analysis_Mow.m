pixelsize = 30;

%% read and purify
heads_single_mowiol = read_data('D:\Data analysis\QDs\QD - Characterization\Data\Mowiol\181207\Single_Analysis', 'ms');
heads_single_mowiol = purify_heads(heads_single_mowiol,510,pixelsize,1);

% heads_rep_mowiol = read_data('D:\Data analysis\QDs\QD - Characterization\Data\Mowiol\181207\Rep_Analysis', 'mr');
% heads_rep_mowiol = purify_heads(heads_rep_mowiol,510,pixelsize,1);

% heads_quick_rep_mowiol = read_data('D:\Data analysis\QDs\QD - Characterization\Data\Mowiol\190108\QuickRep_Analysis', 'mq');
% heads_quick_rep_mowiol = purify_heads(heads_quick_rep_mowiol,510,pixelsize,1);
%% analyze brightness

radiusBrightness = 510/6;
[Is5_s_m, Iso_s_m] = analyze_brightness(heads_single_mowiol, radiusBrightness, pixelsize);
% [Is5_r_m, Iso_r_m] = analyze_brightness(heads_rep_mowiol, radiusBrightness, pixelsize);
% [Is5_qr_m, Iso_qr_m] = analyze_brightness(heads_quick_rep_mowiol, radiusBrightness, pixelsize);

%show
figure();
histogram(Is5_s_m,'displayname','Single','normalization','pdf','binwidth',90);
hold on;
histogram(Is5_r_m,'displayname','Repeated','normalization','pdf','binwidth',90);
histogram(Is5_qr_m,'displayname','Repeated','normalization','pdf','binwidth',90);
legend('show');
title('STED + 510 Comparison Mowiol');

figure();
histogram(Iso_s_m,'displayname','Single','normalization','pdf','binwidth',30);
hold on;
histogram(Iso_r_m,'displayname','Repeated','normalization','pdf','binwidth',30);
histogram(Iso_qr_m,'displayname','Repeated','normalization','pdf','binwidth',30);
legend('show');
title('STED only Comparison Mowiol');

% Show the reexcitation of the QDs
figure();
histogram(Iso_s_m./Is5_s_m,'displayname','Single','normalization','pdf','binwidth',0.05);
hold on;
histogram(Iso_r_m./Is5_r_m,'displayname','Repeated','normalization','pdf','binwidth',0.05);
histogram(Iso_qr_m./Is5_qr_m,'displayname','Repeated','normalization','pdf','binwidth',0.05);
legend('show');
title('STED reexcitation comparison - Mowiol');

%% analyze blinking

radiusFit = 510/2; %CHANGE: Consider a much smaller radius.

%fit
[f_s_m, area_s_m, ~] = gaussian2_psf(heads_single_mowiol,radiusFit,pixelsize);
[x,y] = meshgrid([1:length(area_s_m)], [1:length(area_s_m)]);
figure();
surf(x,y,area_s_m);
title('Single Mowiol');

[f_r_m, area_r_m, psf_r_m] = gaussian2_psf(heads_rep_mowiol,radiusFit,pixelsize);
[x,y] = meshgrid([1:length(area_r_m)], [1:length(area_r_m)]);
figure();
surf(x,y,area_r_m);
title('Repeated Mowiol');

[f_qr_m, area_qr_m, psf_qr_m] = gaussian2_psf(heads_quick_rep_mowiol,radiusFit,pixelsize);
[x,y] = meshgrid([1:length(area_qr_m)], [1:length(area_qr_m)]);
figure();
surf(x,y,area_qr_m);
title('Quick Repeated Mowiol');

% determine blinking and show first frame for check
radiusFit = 510/3;
radiusMask = 510/6; %CHANGE: Consider a much smaller radius, 510/4 --> 510/6.
minInt = 1;
maxInt = 30;

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

[blink_qr_m, heads_quick_rep_mowiol] = blinking(heads_quick_rep_mowiol,f_qr_m,radiusFit,radiusMask,pixelsize, 0.99);
figure();
subplot(1,2,1);
imshow(blink_qr_m(1).mask,[0,2]);
subplot(1,2,2);
imshow(heads_quick_rep_mowiol(1).STED_510, [minInt,maxInt]);
suptitle('Quick Repeated Mowiol');

%%
%blinking statistics
[blinking_s_m, bright_s_m] = analyze_brightness_blinking(heads_single_mowiol, blink_s_m);
[blinking_r_m, bright_r_m] = analyze_brightness_blinking(heads_rep_mowiol, blink_r_m);
[blinking_qr_m, bright_qr_m] = analyze_brightness_blinking(heads_quick_rep_mowiol, blink_qr_m);

brsm = blink_s_m.blinkratio;
brrm = blink_r_m.blinkratio;
brqrm = blink_qr_m.blinkratio;

% Makes no sense to have a QD with blinking ratio == 1, then it should
% never have been detected in the first place. Hence remove these values.
brsm = brsm(brsm ~= 1);
brrm = brrm(brrm ~= 1);
brqrm = brqrm(brqrm ~= 1);

%print results
y = [mean(brsm), 1 - mean(brsm);
    mean(brrm), 1 - mean(brrm);
    mean(brqrm), 1 - mean(brqrm)];
ystd = [std(brsm), 0;
    std(brrm), 0;
    std(brqrm), 0];
names = {'Single Mowiol','Repeated Mowiol','Quick Repeated Mowiol'};
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
y1 = [blinking_s_m.av, blinking_r_m.av, blinking_qr_m.av];
std1 = [blinking_s_m.std, blinking_r_m.std, blinking_qr_m.std];
y2 = [bright_s_m.av, bright_r_m.av, bright_qr_m.av];
std2 = [bright_s_m.std, bright_r_m.std, bright_qr_m.std];
names={'Single Mowiol','Repeated Mowiol','Quick Repeated Mowiol'};
subplot(1,2,2);
errorbar(y1,std1,'o','displayname','Blinking','linewidth',1.5);
hold on;
errorbar(y2,std2,'o','displayname','Bright','linewidth',1.5);
lim=ylim();
set(gca,'xtick',[1:3],'xticklabel',names,'ylim',[0,lim(2)]);
legend('show');
title('Blinking Brightness');
clear y1 std1 y2 std2 names lim
