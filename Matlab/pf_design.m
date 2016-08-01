% Partial factor based design to get the mean resistance
%
% simple:   EC0, Eq. (6.10)
% advanced: EC0, Eq. (6.10a) (6.10b)
%
%   

function Probvar = pf_design(Probvar, Design)

G_k         = Probvar.G.char;
Q_k         = Probvar.Q.char;
C_Q_k       = Probvar.C_Q.char;

% % K_E_k       = Probvar.K_E.char;
% % K_R_k       = Probvar.K_R.char;

gamma_Q     = Design.gamma_Q;
gamma_G     = Design.gamma_G;
gamma_R     = Design.gamma_R;
R_bias      = Design.R_bias;
load_combi  = Design.load_combi;

switch lower(load_combi)
    case 'simple'
        % simple load combination for persistent, transient situation
        % EC0, Eq. (6.10),  
% %         R_k     = K_E_k*(gamma_G*G_k + gamma_Q*C_Q_k*Q_k)*gamma_R/K_R_k;
        R_k     = (gamma_G*G_k + gamma_Q*C_Q_k*Q_k)*gamma_R;
    case {'alternative', 'alt', 'advanced', 'adv'}
        error('Advanced (EC0, Eq. (6.10a) (6.10b)) combination rule is not yet implemented!')
%         
%         % needed only here, WARNING it true only for a single variable action!
%         ksi         = Design.ksi;
%         psi_Q0      = Design.psi_Q0;
%         
%         % more sophisticated load combination for persistent, transient situation
%         % EC0, Eq. (6.10a) (6.10b)
%         Rk_1    = (gamma_G*G_k + psi_Q0*gamma_Q*Q_k)*gamma_R;
%         Rk_2    = (ksi*gamma_G*G_k + gamma_Q*Q_k)*gamma_R;
%         
%         R_k     = max(Rk_1, Rk_2);
end
% x0 = [max(0, R_k*(1 - 5*Probvar.R.cov)/R_bias), R_k*(1 + 5*Probvar.R.cov)*R_bias];
x0 = R_k;
R_m             = fzero(@(R_mean) (lognorminv(0.05, R_mean*R_bias, Probvar.R.cov) - R_k), x0);
% R_k2m           = R_m/R_k;

Probvar.R.char  = R_k;
Probvar.R.mean  = R_m;
Probvar.R.bias  = R_bias;
Probvar.R.std   = R_m*Probvar.R.cov;

end