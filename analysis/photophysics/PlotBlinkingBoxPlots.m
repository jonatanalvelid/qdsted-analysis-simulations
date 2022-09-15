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


%print mowiol results
figure(1)

% % Create the box groups
allblinking = [brsm'; brrm'; brqrm'];
% % Create a grouping variable that assigns the same value to rows that correspond to the same vector in x. For example, the first five rows of g have the same value, First, because the first five rows of x all come from the same vector, x1.
g1 = repmat({'1 line x 200 µs'},length(brsm),1);
g2 = repmat({'10 lines x 20 µs'},length(brrm),1);
g3 = repmat({'100 lines x 2 µs'},length(brqrm),1);
g = [g1; g2; g3];
% Create the box plots.
boxplot(allblinking,g)

ylabel('Blinking pixel ratio [arb.u.]')
yticks([0 0.25 0.5 0.75 1])


% print mowiol vs PBS results
figure(2)

% % Create the box groups
allblinking = [brsm'; brsp'];
% % Create a grouping variable that assigns the same value to rows that correspond to the same vector in x. For example, the first five rows of g have the same value, First, because the first five rows of x all come from the same vector, x1.
g1 = repmat({'Mowiol'},length(brsm),1);
g2 = repmat({'PBS'},length(brsp),1);
g = [g1; g2];
% Create the box plots.
boxplot(allblinking,g)

ylabel('Blinking pixel ratio [arb.u.]')
yticks([0 0.25 0.5 0.75 1])


mean(brsm)
mean(brrm)
mean(brqrm)
mean(brsm)
mean(brsp)