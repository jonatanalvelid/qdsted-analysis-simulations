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

% print mowiol vs PBS results
figure(2)
hsm = histogram(Is5_s_m);
hold on;
hsp = histogram(Is5_s_P);
% alpha(0.5)
length(Is5_s_m)
length(Is5_s_P)

hsm.Normalization = 'pdf';
hsp.Normalization = 'pdf';

hsm.BinWidth = 50;
hsp.BinWidth = 50;

% hsm.FaceColor = colLightGray;
% hsp.FaceColor = colDarkGray;
% 
% hsm.FaceAlpha = 0.5;
% hsp.FaceAlpha = 0.5;

names = {'Mowiol','PBS'};
legend([hsm,hsp],names,'show');
xlabel('Summed brightness [photon count]')
ylabel('Norm. frequency [arb.u.]')
xlim([0 3000])
xticks([0 1000 2000 3000 4000 5000])

% % Testing bar graph to get histogram side-by-side instead. 
% figure(3)
% edges = 0:150:3000;
% h1 = histcounts(Is5_s_m,edges, 'Normalization', 'pdf');
% h2 = histcounts(Is5_r_m,edges, 'Normalization', 'pdf');
% h3 = histcounts(Is5_qr_m,edges, 'Normalization', 'pdf');
% bar(edges(1:end-1),[h1; h2; h3]')


mean(Is5_s_m)
mean(Is5_r_m)
mean(Is5_qr_m)
mean(Is5_s_m)
mean(Is5_s_P)