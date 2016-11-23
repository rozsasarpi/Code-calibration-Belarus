% minimal example to check the effect of chanign reference period in reliability analysis
% calibrating partial factors
%
% * same annual target reliability -> different t_ref target reliabilities
% * same t_ref target reliability -> different annual target reliabilities


clearvars
close all
clc

t_ref       = [50, 15];
beta_1_t    = 3;
beta_t      = norminv(normcdf(beta_1_t).^(t_ref));

Q_1_mean    = 1;
Q_1_cov     = 0.6;
Q_char      = gumbelinvcdf(0.98, Q_1_mean, Q_1_mean*Q_1_cov, 'mom');

% R           = 3;

Q_mean      = Q_1_mean + sqrt(6)/pi*log(t_ref)*Q_1_mean*Q_1_cov;
Q_cov       = Q_1_cov;


R_req1      = gumbelinvcdf(normcdf(beta_t), Q_mean, Q_mean*Q_cov, 'mom');

disp('same annual target reliability')
t_ref
beta_t
R_req1
R_req1./Q_char

disp('same t_ref target reliabilities (reduced for shorter t_ref)')
R_req2      = gumbelinvcdf(normcdf(beta_t(1)*ones(1,2)), Q_mean, Q_mean*Q_cov, 'mom');

R_req2
R_req2./Q_char