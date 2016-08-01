% Model specification for code calibration
%
%SYNOPSYS
% Model = MODEL_SPEC(Model)
%
% The basic element of model representation is a 3D array.
%
% Structuring of main arrays:
% dim1 (height)     load ratio, E_by_G
% dim2 (width)      limit state, [LS1, LS2, ...] format
% dim3 (depth)      lead action, [snow, imposed, wind] order is used
%
%
%
%
% k2m               characteristic value to mean; char/mean
% bias              (mean of experimental results/observations)/(mean of prob model)
%                   > 1 typically for resistance related variables
%                   mean of prob model is obtained from the characteristic value
%                   and coefficient of variation (and known distribution type) using
%                   the 5% and 98% rule of Eurocode for characteristic value for
%                   resistances and actions respectively
%                   Bias is needed to be introduced due to the naive approach of resarchers
%                   to introduce safety into codes.
%                   In reliability analysis we need the unbiased probabilistic models, while in
%                   partial factor based design the biased representation is needed.
%                   Explicit bias factor is used for: R, S_1, I_1, W_1, for which the 5% or 98%
%                   rules are used.
%                   For other random variables it is assumed that the bias is incorporated 
%                   into the k2m factor.
%

function Model = model_spec(Model)

load_ratio_idx      = Model.load_ratio_idx;
limit_state_idx     = Model.limit_state_idx;
lead_action_idx     = Model.lead_action_idx;

n_load_ratio        = length(load_ratio_idx);
n_limit_state       = length(limit_state_idx);
n_lead_action       = length(lead_action_idx);

%==========================================================================
% POTENTIALLY VARYING PARAMETERS
%==========================================================================
%..........................................................................
% FULL MODEL SPECIFICATION - select from this accoring to inputs
%..........................................................................
% lead action
lead_action_label   = {'snow', 'imposed', 'wind'};

% limit state
% apply for each load ratio and lead action!
                      %LS1      LS2     LS3
R_cov               = [0.065,    0.07,   0.07];
R_bias              = [1.00,    1.00,   1.00].^(-1);

K_R_mean            = [1.00,    1.00,   1.00];
K_R_k2m             = [1.075,   1.00,   1.15].^(-1);
K_R_cov             = [0.075,   0.07,   0.10];
                      
                      %for all actions
K_E_mean            = 1.00;
K_E_k2m             = 1.00;
K_E_cov             = 0.10;

                      %snow     %imp    %wind
C_Q_mean            = [1.00,    1.00,   1.00];
C_Q_k2m             = [1.00,    1.00,   1.25];
C_Q_cov             = [0.15,    0.10,   0.30];

% load ratio
% apply for each limit state and lead action
khi                 = [0.10;
                       0.20;
                       0.30;
                       0.40;
                       0.50;
                       0.60;
                       0.70;
                       0.80;
                       0.90]; 

% weigths for objective function
% apply for each lead action
% [Ellingwood et al. (1980). A58. Table 5.2b steel] - overwritten yb Vitalij's suggestion!
                      %LS1      LS2     LS3
w_snow              = [5,       5,      5;
                       10,      10,     10;
                       10,      10,     10;
                       10,      10,     10;
                       10,      10,     10;
                       15,      15,     15;
                       20,      20,     20;
                       15,      15,     15;
                       5,       5,      5];

% [Ellingwood et al. (1980). A58. Table 5.2a steel] - overwritten yb Vitalij's suggestion!
w_imp              =  [5,       5,      5;
                       5,       5,      5;
                       15,      15,     15;
                       15,      15,     15;
                       20,      20,     20;
                       15,      15,     15;
                       15,      15,     15;
                       5,       5,      5;
                       5,       5,      5];

% n                   = length(khi);                  
% w_wind              = repmat(100/n,size(w_imp)); %???
w_wind              = w_snow;
                   
%..........................................................................
% FILTER FULL MODEL & EXPAND TO 3D ARRAYS
%..........................................................................
tmp                 = cell(n_load_ratio, n_limit_state, n_lead_action);
% loop over lead actions
for ii = 1:n_lead_action
    tmp(:,:,ii)     = repmat(lead_action_label(lead_action_idx(ii)), n_load_ratio, n_limit_state);
end
lead_action         = tmp;

R_cov               = R_cov(limit_state_idx);
R_cov               = repmat(R_cov, n_load_ratio, 1, n_lead_action);
R_bias              = R_bias(limit_state_idx);
R_bias              = repmat(R_bias, n_load_ratio, 1, n_lead_action);

K_R_mean            = K_R_mean(limit_state_idx);
K_R_mean            = repmat(K_R_mean, n_load_ratio, 1, n_lead_action);
K_R_k2m             = K_R_k2m(limit_state_idx);
K_R_k2m             = repmat(K_R_k2m, n_load_ratio, 1, n_lead_action);
K_R_cov             = K_R_cov(limit_state_idx);
K_R_cov             = repmat(K_R_cov, n_load_ratio, 1, n_lead_action);

K_E_mean            = K_E_mean*ones(n_load_ratio, n_limit_state, n_lead_action);
K_E_k2m             = K_E_k2m*ones(n_load_ratio, n_limit_state, n_lead_action);
K_E_cov             = K_E_cov*ones(n_load_ratio, n_limit_state, n_lead_action);

clear tmp
tmp(1,1,1:3)        = C_Q_mean;
C_Q_mean            = tmp;
C_Q_mean            = C_Q_mean(lead_action_idx);
C_Q_mean            = repmat(C_Q_mean, n_load_ratio, n_limit_state, 1);

clear tmp
tmp(1,1,1:3)        = C_Q_k2m;
C_Q_k2m             = tmp;
C_Q_k2m             = C_Q_k2m(lead_action_idx);
C_Q_k2m             = repmat(C_Q_k2m, n_load_ratio, n_limit_state, 1);

clear tmp)
tmp(1,1,1:3)        = C_Q_cov;
C_Q_cov             = tmp;
C_Q_cov             = C_Q_cov(lead_action_idx);
C_Q_cov             = repmat(C_Q_cov, n_load_ratio, n_limit_state, 1);

khi              = khi(load_ratio_idx);
khi              = repmat(khi, 1, n_limit_state, n_lead_action);

w_snow              = w_snow(load_ratio_idx, limit_state_idx);

w_imp               = w_imp(load_ratio_idx, limit_state_idx);

w_wind              = w_wind(load_ratio_idx, limit_state_idx);

w                   = nan(size(w_snow));

for ii = 1:n_lead_action
    if lead_action_idx(ii) == 1
        w(:,:,ii) = w_snow;
    elseif lead_action_idx(ii) == 2
        w(:,:,ii) = w_imp;
    elseif lead_action_idx(ii) == 3
        w(:,:,ii) = w_wind;
    end
end

%==========================================================================
% FIXED PARAMETERS
%==========================================================================

% % Random variables' properties
% % geometric characteristic of cross-section, e.g. area, section modulus
% Z.mean              = 1;
% Z.cov               = 0.02;

% snow
S_1.mean            = 1.00;
S_1.bias            = 1.00;
S_1.cov             = 0.60;

% imposed action
I_1.mean            = 1.00;
I_1.bias            = 1.00;
I_1.cov             = 0.20;

% wind action
W_1.mean            = 1.00;
W_1.bias            = 1.00;
W_1.cov             = 0.40;

% permanent action
G.cov               = 0.08;
G.k2m               = 1/1.025;

%==========================================================================
% COLLECT PARAMETERS
%==========================================================================                
Model.lead_action   = lead_action;
Model.lead_action_label = lead_action_label;
Model.khi           = khi; 
Model.R.cov         = R_cov;
Model.R.bias        = R_bias;

Model.K_E.mean      = K_E_mean;
Model.K_E.k2m       = K_E_k2m;
Model.K_E.cov       = K_E_cov;
Model.K_R.mean      = K_R_mean;
Model.K_R.k2m       = K_R_k2m;
Model.K_R.cov       = K_R_cov;

Model.C_Q.mean      = C_Q_mean;
Model.C_Q.k2m       = C_Q_k2m;
Model.C_Q.cov       = C_Q_cov;

Model.w             = w;

Model.S_1           = S_1;
Model.I_1           = I_1;
Model.W_1           = W_1;
Model.G             = G;

% if ~all(all(all(isnan(R_k2m))))
%    warning('The characteristic to mean conversion ratio (R_k2m) for variable R will be overwritten by the 5% rule!') 
% end
% 
% if ~all(isnan([S_1.k2m, I_1.k2m, W_1.k2m]))
%    warning('The characteristic to mean conversion ratio (k2m) for variable Q(S,I,W) will be overwritten by the 98% rule!') 
% end

end