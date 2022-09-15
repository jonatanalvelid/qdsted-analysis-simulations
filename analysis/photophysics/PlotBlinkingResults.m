%print results
% Makes no sense to have a QD with blinking ratio == 1, then it should
% never have been detected in the first place. Hence remove these values.
brsp = n_blinkratio_s_P(n_blinkratio_s_P ~= 1);  
brrp = n_blinkratio_r_P(n_blinkratio_r_P ~= 1);
brsm = n_blinkratio_s_m(n_blinkratio_s_m ~= 1);
brrm = n_blinkratio_r_m(n_blinkratio_r_m ~= 1);

y = [mean(brsp), 1 - mean(brsp);
    mean(brrp), 1 - mean(brrp);
    mean(brsm), 1 - mean(brsm);
    mean(brrm), 1 - mean(brrm)];
ystd = [std(brsp), 0;
    std(brrp), 0;
    std(brsm), 0;
    std(brrm), 0];
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