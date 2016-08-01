clearvars
close all
clc

c   = 4.35;
b_t = 3.8;

b   = 3:0.03:6;
b_n = b/b_t;

M1  = (b - b_t).^2;
M2  = c*(b - b_t) + exp(-c*(b - b_t)) - 1;

plot(b_n, M1)
hold on
plot(b_n, M2)

hl = legend('symmetric', 'asymmetric');
hl.Interpreter = 'LaTeX';
hl.Box = 'off';
box off

xlabel('$\beta/\beta_\mathrm{t}$', 'Interpreter', 'LaTeX')
ylabel('$O$', 'Interpreter', 'LaTeX')

xlim([0.8, 1.5])
set(gca,'TickLabelInterpreter', 'LaTeX')