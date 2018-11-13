clear;

f2 = figure;
hold on; grid on;
plot(accuracyTest*100,'r-','LineWidth',1);
axis([1 numRepeats 0 100]);
xlabel('Repetition(n)');
ylabel('Accuracy of prediction(%)');
title(['Feature number is ',num2str(feature_dim)],'Fontsize',16);


% test_2(500);
% test_2(1000);
% test_2(1500);
% test_2(1800);
% test_2(2000);
% test_2(2300);
test_2(1540);
