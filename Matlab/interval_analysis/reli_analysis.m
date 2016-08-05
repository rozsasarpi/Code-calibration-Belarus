% Reliability analysis for interval analysis
%
%SYNOPSYS
% [b_int, b_calibr] = RELI_ANALYSIS(x, Model, partial_f, lead_action_idx, limit_state_idx, load_ratio_idx)
%
%
% Assumes that all bias factors are 1.0!! 
%
% simple_gfun(Q, C_Q, G, K_E, R, K_R)
% WARNING!
% x(1:2)        Q   (k2m, cov)
% x(3:4)        G   (k2m, cov) G_k is determined by load ratio, khi
% x(5:6)        R   (k2m, cov) R_k is determined by partial factor-based design
% x(7:8)        K_R (k2m, cov)


function b = reli_analysis(x, Model, Results, lead_action_idx, limit_state_idx, load_ratio_idx)

%==========================================================================
% INITIALIZATION - assign variables
%==========================================================================

ii                  = lead_action_idx;
jj                  = limit_state_idx;
kk                  = load_ratio_idx;

Probvar             = Results.Probvar;
% .........................................................................
% Probvar
% .........................................................................
Probvar.Q.k2m       = x(1);
Probvar.Q.cov       = x(2);

Probvar.G.k2m       = x(3);
Probvar.G.cov       = x(4);

Probvar.R.k2m       = x(5);
Probvar.R.cov       = x(6);

Probvar.K_R.k2m     = x(7);
Probvar.K_R.cov     = x(8);

partial_f           = Results.partial_f;
% .........................................................................
% Model
% .........................................................................
gamma_Q_type        = Model.gamma_Q_type;
khi                 = Model.khi(kk,jj,ii);

n_gamma_Q           = Model.n_gamma_Q;

E_by_G              = (1./khi - 1).^(-1); % C_k*Q_k/G_k !!


% WARNING!!
% should be in line with the obj_fun function in calibrate.m !!
% WARNING!!
switch lower(gamma_Q_type)
    case {'constant'} % fixed partial factor
        gamma_Q    = partial_f(1+min(n_gamma_Q-1,ii-1)); % little bit convoluted.. should be simplified
        gamma_G    = partial_f(2+(n_gamma_Q-1));
        gamma_R    = partial_f(2+(n_gamma_Q-1)+jj); %WARNING! (different partial factor per failure mode)
        
    case {'linear'} % partial factor linearly dependent on load ratio
        gamma_Q_a  = partial_f(1);
        gamma_Q_b  = partial_f(2);
        gamma_Q    = gamma_Q_a + E_by_G(kk,jj,ii)*gamma_Q_b;
        gamma_G    = partial_f(3);
        gamma_R    = partial_f(3+jj); %WARNING! (different partial factor per failure mode)

    otherwise
        error(['Unknown partial factor type: ', gamma_Q_type])
end

% gamma_Q
% gamma_G
% gamma_R
%==========================================================================
% ANALYSIS
%==========================================================================

% .........................................................................
% GET THE PROBABILISTIC MODELS & REPRESENTATIVE FRACTILES
% .........................................................................
% applied to t_ref reference period maxima
Q_k                 = 1; % not interval! to have fixed khi, its value does not affect the outcomes (tested)
Probvar.Q.char      = Q_k; 
Probvar.Q.mean      = Probvar.Q.char*Probvar.Q.k2m;
Probvar.Q.std       = Probvar.Q.mean*Probvar.Q.cov;

C_Q_k               = Probvar.C_Q.k2m;

G_k                 = (Probvar.C_Q.char*Probvar.Q.char)*(1/khi - 1); % not interval! to have fixed khi
Probvar.G.char      = G_k; 
Probvar.G.mean      = Probvar.G.char*Model.G.k2m;
Probvar.G.std       = Probvar.G.cov*Probvar.G.mean;

Probvar.K_R.mean    = Probvar.K_R.char*Probvar.K_R.k2m; % test this!
% Probvar.K_R.char    = Probvar.K_R.mean/Probvar.K_R.k2m; % seemingly equivalent formulation, but this way the mean is not interval thus leads to narrower beta interval
Probvar.K_R.std     = Probvar.K_R.mean*Probvar.K_R.cov;

% .........................................................................
% PARTIAL FACTOR BASED DESIGN -> RESISTANCE
% .........................................................................
R_k                 = (gamma_G*G_k + gamma_Q*C_Q_k*Q_k)*gamma_R;
Probvar.R.char      = R_k;
Probvar.R.mean      = Probvar.R.char*Probvar.R.k2m;
Probvar.R.std       = Probvar.R.mean*Probvar.R.cov;

% .........................................................................
% RELIABILITY ANALYSIS -> BETA
% .........................................................................
b                   = form_wrapper(Probvar);

end