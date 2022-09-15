% Generate the right data to plot
brsm = [], brrm = [], brqrm = [], brsp = [];

for i = 1:length(blink_s_m)
    brsm = [brsm, blink_s_m(i).blinkratio];
end
for i = 1:length(blink_r_m)
    brrm = [brrm, blink_r_m(i).blinkratio];
end
for i = 1:length(blink_qr_m)
    brqrm = [brqrm, blink_qr_m(i).blinkratio];
end
for i = 1:length(blink_s_P)
    brsp = [brsp, blink_s_P(i).blinkratio];
end

% Makes no sense to have a QD with blinking ratio == 1, then it should
% never have been detected in the first place. Hence remove these values.
brsm = brsm(brsm ~= 1);
brrm = brrm(brrm ~= 1);
brqrm = brqrm(brqrm ~= 1);
brsp = brsp(brsp ~= 1);

% %print mowiol results
figure(1)
hsm = histogram(brsm);
hold on
hrm = histogram(brrm);
hqrm = histogram(brqrm);

hsm.Normalization = 'pdf';
hrm.Normalization = 'pdf';
hqrm.Normalization = 'pdf';

hsm.BinWidth = 0.1;
hrm.BinWidth = 0.1;
hqrm.BinWidth = 0.1;

names = {'1 line x 200 µs','10 lines x 20 µs','100 lines x 2 µs'};
legend([hsm,hrm,hqrm],names,'show');
xlabel('Blinking pixel ratio [arb.u.]')
ylabel('Norm. frequency [arb.u.]')
xticks([0 0.2 0.4 0.6 0.8 1])


% print mowiol vs PBS results
figure(2)

hsm = histogram(brsm);
hold on
hsp = histogram(brsp);

hsm.Normalization = 'pdf';
hsp.Normalization = 'pdf';

hsm.BinWidth = 0.1;
hsp.BinWidth = 0.1;

names = {'Mowiol','PBS'};
legend([hsm,hsp],names,'show');
xlabel('Blinking pixel ratio [arb.u.]')
ylabel('Norm. frequency [arb.u.]')
xticks([0 0.2 0.4 0.6 0.8 1])


mean(brsm)  % Single mowiol
mean(brrm)  % 10x mowiol
mean(brqrm)  % 100x mowiol
mean(brsp)  % Single PBS