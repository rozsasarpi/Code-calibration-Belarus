% Illustration of interval uncertainty propagation 
%
% Comparison:
% (a) both cov and k2m = mu_X/X_k are intervals
% (b) only cov is interval and 98% rule is used
%
% Issue:
% - are cov and k2m intervals independent? I do not think so.
%   roughly speaking: approach (a) assumes independence, while approach (b) assumes full dependence
%


clearvars
close all
clc

%--------------------------------------------------------------------------
% INPUT
%--------------------------------------------------------------------------
% snow 1-year maxima
cov_int = [0.48, 0.62];
k2m_int = [0.34, 0.44];

q_char  = 1;

% 1000-year quantile is estimated
P       = 1-1/1000;
%--------------------------------------------------------------------------
% INPUT
%--------------------------------------------------------------------------

%..........................................................................
% approach (a)
m       = q_char*k2m_int(1);
s       = m*cov_int(1);
q_a(1)  = gumbelinvcdf(P, m, s, 'moments');
m_a(1)  = m;

m       = q_char*k2m_int(2);
s       = m*cov_int(1);
q_a(2)  = gumbelinvcdf(P, m, s, 'moments');
m_a(2)  = m;

m       = q_char*k2m_int(2);
s       = m*cov_int(2);
q_a(3)  = gumbelinvcdf(P, m, s, 'moments');
m_a(3)  = m;

m       = q_char*k2m_int(1);
s       = m*cov_int(2);
q_a(4)  = gumbelinvcdf(P, m, s, 'moments');
m_a(4)  = m;

%..........................................................................
% approach (b)
c       = cov_int(1);
m       = fzero(@(x) gumbelinvcdf(0.98, x, c*x, 'moments') - q_char, q_char);
s       = m*c;
q_b(1)  = gumbelinvcdf(P, m, s, 'moments');
m_b(1)  = m;

c       = cov_int(2);
m       = fzero(@(x) gumbelinvcdf(0.98, x, c*x, 'moments') - q_char, q_char);
s       = m*c;
q_b(2)  = gumbelinvcdf(P, m, s, 'moments');
m_b(2)  = m;

%..........................................................................
disp('approach (a)--------------------------------')
q_a_int = [min(q_a), max(q_a)]
m_a_int = [min(m_a), max(m_a)]

disp('approach (b)--------------------------------')
q_b_int = [min(q_b), max(q_b)]
m_b_int = [min(m_b), max(m_b)]


