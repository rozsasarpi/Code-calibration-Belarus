% Prepare probabilistic model & establish connection between representative fractiles and random variables
%
% SYNOPSYS
% Probvar = PROB_MODEL(kk,jj,ii, Model)
%
%
%
% distribution types (following FERUM):
% 1     Normal
% 2     Lognormal
% 11    Gumbel

function Probvar = prob_model(kk,jj,ii, Model)

lead_action = Model.lead_action(kk,jj,ii);
khi         = Model.khi(kk,jj,ii);
t_ref       = Model.t_ref;

R_cov       = Model.R.cov(kk,jj,ii);
R_bias      = Model.R.bias(kk,jj,ii);
K_R_mean    = Model.K_R.mean(kk,jj,ii);
K_R_k2m     = Model.K_R.k2m(kk,jj,ii);
K_R_cov     = Model.K_R.cov(kk,jj,ii);

K_E_mean    = Model.K_E.mean(kk,jj,ii);
K_E_k2m     = Model.K_E.k2m(kk,jj,ii);
K_E_cov     = Model.K_E.cov(kk,jj,ii);

C_Q_mean    = Model.C_Q.mean(kk,jj,ii);
C_Q_k2m     = Model.C_Q.k2m(kk,jj,ii);
C_Q_cov     = Model.C_Q.cov(kk,jj,ii);

%==========================================================================
% EFFECT
%==========================================================================


switch lower(lead_action{:})
    case {'s', 'snow'}
        %..................................................................
        % Q, snow action, annual maxima
        % annual
        Q_1.mean    = Model.S_1.mean;
        Q_1.bias    = Model.S_1.bias;
        Q_1.cov     = Model.S_1.cov;
        Q_1.std     = Q_1.cov*Q_1.mean;
        Q_1.dist    = 11;
        
    case {'i', 'imposed'}
        %..................................................................
        % Q, imposed action, annual maxima
        % annual
        Q_1.mean    = Model.I_1.mean;
        Q_1.bias    = Model.I_1.bias;
        Q_1.cov     = Model.I_1.cov;
        Q_1.std     = Q_1.cov*Q_1.mean;
        Q_1.dist    = 11;
        
    case {'w', 'wind'}
        %..................................................................
        % W, wind action, annual maxima
        % annual
        Q_1.mean    = Model.W_1.mean;
        Q_1.bias    = Model.W_1.bias;
        Q_1.cov     = Model.W_1.cov;
        Q_1.std     = Q_1.cov*Q_1.mean;
        Q_1.dist    = 11;        
        
    otherwise
        error(['Unknown leading action (lead_action): ', lead_action])
end

% get characteristic value & transform distribution from 1-year to t_ref reference period
if Q_1.dist == 11
    Probvar.Q       = Q_1;
    
    % get characteristic value
    Probvar.Q.char  = gumbelinvcdf(0.98, Q_1.mean*Q_1.bias, Q_1.std, 'mom');
%     Probvar.Q.k2m   = Q_1.mean/Probvar.Q.char;
    
    % transform from 1-year to t_ref reference period
    Probvar.Q.mean  = Q_1.mean + sqrt(6)/pi*log(t_ref)*Q_1.std;
    Probvar.Q.cov   = Probvar.Q.std/Probvar.Q.mean;
else
    error('Reference period conversion is only implemented for Gumbel distribution yet.')
end

%..........................................................................
% C_Q, time-invariant component of variable action
Probvar.C_Q.mean    = C_Q_mean;
Probvar.C_Q.k2m     = C_Q_k2m;
Probvar.C_Q.cov     = C_Q_cov;
Probvar.C_Q.std     = Probvar.C_Q.cov*Probvar.C_Q.mean;
Probvar.C_Q.dist    = 1;
Probvar.C_Q.char    = C_Q_mean/C_Q_k2m;

%..........................................................................
% G, permanent load
% load ratio defined with mean values
% Probvar.G.mean      = (Probvar.C_Q.mean*Probvar.Q.mean)*(1/khi - 1);
% Probvar.G.char      = Probvar.G.mean/Model.G.k2m
% load ratio defined with characteristic values
Probvar.G.char      = (Probvar.C_Q.char*Probvar.Q.char)*(1/khi - 1); % WARNING!!!
Probvar.G.mean      = Probvar.G.char*Model.G.k2m;

Probvar.G.k2m       = Model.G.k2m;
Probvar.G.cov       = Model.G.cov;
Probvar.G.std       = Probvar.G.cov*Probvar.G.mean;
Probvar.G.dist      = 1;


%..........................................................................
% K_E, effect model uncertainy
Probvar.K_E.mean    = K_E_mean;
Probvar.K_E.k2m     = K_E_k2m;
Probvar.K_E.cov     = K_E_cov;
Probvar.K_E.std     = Probvar.K_E.cov*Probvar.K_E.mean;
Probvar.K_E.dist    = 2;
Probvar.K_E.char    = K_E_mean/K_E_k2m;

%==========================================================================
% RESISTANCE
%==========================================================================
%..........................................................................
% R, resistance
Probvar.R.mean      = NaN;
Probvar.R.bias      = R_bias;
Probvar.R.cov       = R_cov;
Probvar.R.std       = Probvar.R.cov*Probvar.R.mean;
Probvar.R.dist      = 2;
Probvar.R.char      = NaN;

%..........................................................................
% K_R, resistance model uncertainty
Probvar.K_R.mean    = K_R_mean;
Probvar.K_R.k2m     = K_R_k2m;
Probvar.K_R.cov     = K_R_cov;
Probvar.K_R.std     = Probvar.K_R.cov*Probvar.K_R.mean;
Probvar.K_R.dist    = 2;
Probvar.K_R.char    = K_R_mean/K_R_k2m;

end
