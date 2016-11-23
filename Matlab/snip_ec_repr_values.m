% calculate the approximate probability associated with SNiP representative values

clearvars
close all
clc

disp('------ SNOW ------')
% snow cov
cv          = 0.55;
ratio       = 0.83; % based on Vitalij's analysis


ec_p        = 0.98;
ec_rep      = gumbelinvcdf(ec_p, 1, cv, 'mom');

snip_rep    = ratio*ec_rep;
snip_p      = gumbelcdf(snip_rep, 1, cv)


disp('------ WIND ------')
% wind cov
cv          = 0.40;
ratio       = 0.65; % based on Vitalij's analysis

ec_rep      = gumbelinvcdf(ec_p, 1, cv, 'mom');

snip_rep    = ratio*ec_rep;
snip_p      = gumbelcdf(snip_rep, 1, cv)