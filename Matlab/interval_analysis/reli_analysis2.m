% Reliability analysis for interval analysis
%
%SYNOPSYS
% b = RELI_ANALYSIS2(x, Model, Probvar, partial_f, lead_action_idx, limit_state_idx, load_ratio_idx)
%
%
% Assumes that all bias factors are 1.0!! 
%
% simple_gfun(Q, C_Q, G, K_E, R, K_R)
% WARNING!
% x(1)          Q   (cov) + 98% rule
% x(2)          G   (cov) + 50% rule; G_k is determined by load ratio, khi
% x(3)          R   (cov) + 2% rule; R_k is determined by partial factor-based design
% x(4:5)        K_R (k2m, cov)


function b = reli_analysis2(x, Model, Probvar, partial_f, lead_action_idx, limit_state_idx, load_ratio_idx)

%==========================================================================
% INITIALIZATION - assign variables
%==========================================================================

ii                  = lead_action_idx;
jj                  = limit_state_idx;
kk                  = load_ratio_idx;

% Probvar             = Results.Probvar;
% .........................................................................
% Probvar
% .........................................................................
Probvar.Q.cov       = x(1);

Probvar.G.cov       = x(2);

Probvar.R.cov       = x(3);

Probvar.K_R.k2m     = x(4);
Probvar.K_R.cov     = x(5);

% partial_f           = Results.partial_f;
% .........................................................................
% Model
% .........................................................................
gamma_Q_type        = Model.gamma_Q_type;
khi                 = Model.khi(kk,jj,ii);

n_gamma_Q           = Model.n_gamma_Q;
t_ref               = Model.t_ref;

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
Q_t_cov             = (1/Probvar.Q.cov - sqrt(6)/pi*log(t_ref/Probvar.Q.t))^(-1);
Q_t_mean            = fzero(@(x) gumbelinvcdf(Probvar.Q.P_rep, x, Q_t_cov*x, 'moments') - Q_k, Q_k);
Q_t_std             = Q_t_cov*Q_t_mean;

Probvar.Q.mean      = Q_t_mean + sqrt(6)/pi*log(t_ref/Probvar.Q.t)*Q_t_std;
Probvar.Q.cov       = Q_t_std/Probvar.Q.mean;
Probvar.Q.std       = Q_t_std;
Probvar.Q.char      = Q_k;

C_Q_k               = Probvar.C_Q.char;

G_k                 = (Probvar.C_Q.char*Probvar.Q.char)*(1/khi - 1); % not interval! to have fixed khi
Probvar.G.char      = G_k; 
Probvar.G.mean      = Probvar.G.char; % 50% rule (normally distributed)
Probvar.G.std       = Probvar.G.cov*Probvar.G.mean;

Probvar.K_R.mean    = Probvar.K_R.char*Probvar.K_R.k2m; % test this!
% Probvar.K_R.char    = Probvar.K_R.mean/Probvar.K_R.k2m; % seemingly equivalent formulation, but this way the mean is not interval thus leads to narrower beta interval
Probvar.K_R.std     = Probvar.K_R.mean*Probvar.K_R.cov;

% .........................................................................
% PARTIAL FACTOR BASED DESIGN -> RESISTANCE
% .........................................................................
R_k                 = (gamma_G*G_k + gamma_Q*C_Q_k*Q_k)*gamma_R;
Probvar.R.char      = R_k;
Probvar.R.mean      = fzero(@(x) (lognorminv(0.02, x, Probvar.R.cov) - R_k), R_k);
Probvar.R.std       = Probvar.R.mean*Probvar.R.cov;

% .........................................................................
% RELIABILITY ANALYSIS -> BETA
% .........................................................................
b                   = form_wrapper(Probvar);

end