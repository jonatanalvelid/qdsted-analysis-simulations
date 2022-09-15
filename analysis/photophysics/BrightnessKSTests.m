colDarkGray = 1/255*[100 100 100];
colLightGray = 1/255*[200 200 200];
colBlack = 1/255*[0 0 0];

%print mowiol results
figure(1)
hsm = histogram(Is5_s_m);
hold on;
hrm = histogram(Is5_r_m);
hqrm = histogram(Is5_qr_m);
length(Is5_s_m)
length(Is5_r_m)
length(Is5_qr_m)

hsm.Normalization = 'pdf';
hrm.Normalization = 'pdf';
hqrm.Normalization = 'pdf';

hsm.BinWidth = 150;
hrm.BinWidth = 150;
hqrm.BinWidth = 150;

% hsm.FaceColor = colLightGray;
% hrm.FaceColor = colDarkGray;
% hqrm.FaceColor = colBlack;
% 
% hsm.FaceAlpha = 0.5;
% hrm.FaceAlpha = 0.5;
% hqrm.FaceAlpha = 0.5;

names = {'1 line x 200 µs','10 lines x 20 µs','100 lines x 2 µs'};
legend([hsm,hrm,hqrm],names,'show');
xlabel('Summed brightness [photon count]')
ylabel('Norm. frequency [arb.u.]')
xlim([0 3000])
xticks([0 1000 2000 3000 4000 5000])

mean(Is5_s_m)
mean(Is5_r_m)
mean(Is5_qr_m)
mean(Is5_s_P)

% KS-Testing between the three different Mowiol distributions
[h1,p1]=kstest2(Is5_s_m,Is5_r_m)  % P-value: 0.0785 > 0.05 --> Same dist.
[h2,p2]=kstest2(Is5_s_m,Is5_qr_m)  % P-value: 3.27E-5 < 0.05 --> Diff. dist.
[h3,p3]=kstest2(Is5_r_m,Is5_qr_m)  % P-value: 1.94E-4 < 0.05 --> Diff. dist.
[h4,p4]=kstest2(Is5_s_m,Is5_s_P)  % P-value: 2.654E-240 < 0.05 --> Diff. dist.

[h5,p5]=kstest2(Is5_s_m,Is5_r_m,'tail','smaller')  % P-value: 0.0392
[h6,p6]=kstest2(Is5_s_m,Is5_qr_m,'tail','smaller')  % P-value: 1.64E-5
[h7,p7]=kstest2(Is5_r_m,Is5_qr_m,'tail','smaller')  % P-value: 9.69E-5
[h8,p8]=kstest2(Is5_s_m,Is5_s_P,'tail','smaller')  % P-value: 1.327E-240