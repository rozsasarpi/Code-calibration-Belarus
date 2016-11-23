% Comparison of fractile calculations - exact vs approximate

clearvars
close all
clc

P = 0.98;
% v = 0.3;
v = 0.1:0.01:0.8;

% mean/quantile

% exact, derived from the defintion of lognormal distribution
X1 = sqrt(1+v.^2).*exp(-norminv(P).*sqrt(log(1+v.^2)));

% approximation suggested by Mirek
X2 = 1./exp(1.645*v);

plot(v, X1)
hold on
plot(v, X2)
legend('exact', 'approx')

