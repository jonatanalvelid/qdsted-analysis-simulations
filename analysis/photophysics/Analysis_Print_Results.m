%print mowiol results
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
