% Reliability-based calibration of partial factors
%
% Results = CALIBRATE(Model, partial_f)
%
% partial_f       if given, only the objective function is evaluated, no calibration performed
%                 this useful if multiple solutions are obtained and we would like to have all beta values or other paremeters for other then the selected minimum

function Results = calibrate(Model, partial_f)

if nargin < 2
    partial_f = [];
end

%==========================================================================
% INITIALIZATION
%==========================================================================

beta_target     = Model.beta_target;
obj_fun_type    = Model.obj_fun_type;
load_combi      = Model.load_combi;
gamma_Q_type    = Model.gamma_Q_type;
khi             = Model.khi;
R_bias          = Model.R.bias;
w               = Model.w;

n_gamma_Q       = Model.n_gamma_Q;

% E_by_G          = (1./khi - 1).^(-1); % C_k*Q_k/G_k !!

n_load_ratio    = size(khi,1);
n_limit_state   = size(khi,2);
n_lead_action   = size(khi,3);

% initial point of optimization
switch lower(gamma_Q_type)
    case {'constant'}
        %                     %gamma_Q                      gamma_G     gamma_R
        x0                  = [repmat(1.5,1,n_gamma_Q),     1.1         1.2*ones(1,n_limit_state)];
        nvar                = length(x0);
        lb                  = 0.8*ones(nvar,1);
        ub                  = 2.8*ones(nvar,1);
        lb(1) = 2.0;
        ub(1) = 2.0;
    case {'linear'}
        %                     %gamma_Q_a,   gamma_Q_b  gamma_G     gamma_R
        x0                  = [1.5          0.2        1.1         1.2*ones(1,n_limit_state)];
        
        nvar                = length(x0);
        lb                  = 0.8*ones(nvar,1);
        lb(2)               = 0;
        ub                  = 2.5*ones(nvar,1);
        ub(2)               = 1;
    otherwise
        error(['Unknown partial factor type: ', gamma_Q_type])
end

%==========================================================================
% OPTIMIZATION
%==========================================================================

% Calibration
if ~isempty(partial_f)
    n_pf = length(partial_f);
    n_x0 = length(x0);
    if length(x0) ~= length(partial_f)
       error(['Based on the given Model the number of partial factors should be ', num2str(n_x0), ' and not ', num2str(n_pf), ' !'])
    end
    O = obj_fun(partial_f);
else
%..........................................................................
% fminunc - unconstrained
% % options                     = optimoptions('fminunc');
% % options.Algorithm           = 'quasi-newton';
% % options.Display             = 'iter';
% % options.OptimalityTolerance = 1e-4;
% % options.StepTolerance       = 1e-4;

% % [partial_f, O]  = fminunc(@obj_fun, x0, options);

%..........................................................................
% fmincon - constrained
options                     = optimoptions('fmincon');
options.Algorithm           = 'sqp';
% options.Display             = 'iter';
options.OptimalityTolerance = 1e-4;
options.StepTolerance       = 1e-4;

% [partial_f, O]  = fmincon(@obj_fun, x0,[],[],[],[],lb,ub,[],options);

%..........................................................................
% fminsearch - unconstrained
% % options                     = optimset('fminsearch');
% % options.Display             = 'iter';
% % options.TolFun              = 1e-4;
% % options.TolX                = 1e-4;

% % [partial_f, O]  = fminsearch(@obj_fun, x0, options);

%..........................................................................
% Global Optimization Toolbox
problem = createOptimProblem('fmincon','objective',...
 @obj_fun,'x0',x0,'lb',lb,'ub',ub,'options',options);

% GlobalSearch
% % gs = GlobalSearch('Display', 'iter');
% % [partial_f, O] = run(gs,problem);

% MultiStart
ms = MultiStart('UseParallel',true,'Display','iter');
% ms = MultiStart('UseParallel',true);
% ms = MultiStart('Display','iter');
[partial_f, O, ~, ~, manymins] = run(ms,problem,20);
Results.manymins = manymins;

end

    function O = obj_fun(x)
        
        %..................................................................
        % PRE-PROCESS
        %..................................................................
        
        O                   = 0;
        Beta                = nan(n_load_ratio, n_limit_state, n_lead_action);
        R_k                 = Beta;
        % loop over leading actions
        for ii = 1:n_lead_action
            
            % loop over limit states
            for jj = 1:n_limit_state
                
                % loop over load ratios
                for kk = 1:n_load_ratio
                    
                    switch lower(gamma_Q_type)
                        case {'constant'} % fixed partial factor
                            Design_o.gamma_Q    = x(1+min(n_gamma_Q-1,ii-1)); % little bit convoluted.. should be simplified
                            Design_o.gamma_G    = x(2+(n_gamma_Q-1));
                            Design_o.gamma_R    = x(2+(n_gamma_Q-1)+jj); %WARNING! (different partial factor per failure mode)
                            Design_o.R_bias     = R_bias(kk,jj,ii);
                            Design_o.load_combi = load_combi;
                            
                        case {'linear'} % partial factor linearly dependent on load ratio    
                            gamma_Q_a           = x(1);
                            gamma_Q_b           = x(2);
%                             Design_o.gamma_Q    = gamma_Q_a + E_by_G(kk,jj,ii)*gamma_Q_b;
                            Design_o.gamma_Q    = gamma_Q_a + khi(kk,jj,ii)*gamma_Q_b;
                            Design_o.gamma_G    = x(3);
                            Design_o.gamma_R    = x(3+jj); %WARNING! (different partial factor per failure mode)
                            Design_o.R_bias     = R_bias(kk,jj,ii);
                            Design_o.load_combi = load_combi;
                        otherwise
                            error(['Unknown partial factor type: ', gamma_Q_type])
                    end
                    
                    
                    %........................................................
                    % GET THE PROBABILISTIC MODELS & REPRESENTATIVE FRACTILES
                    %........................................................
                    Probvar_o           = prob_model(kk,jj,ii, Model);
                    
                    %........................................................
                    % PARTIAL FACTOR BASED DESIGN -> RESISTANCE
                    %........................................................
                    Probvar_o           = pf_design(Probvar_o, Design_o);
                    R_k(kk,jj,ii)       = Probvar_o.R.char;
                    %........................................................
                    % RELIABILITY ANALYSIS -> BETA
                    %........................................................
                    if all([kk,jj,ii] == [6,1,1])
%                        keyboard 
                    end
                    beta                = form_wrapper(Probvar_o);
                    Beta(kk,jj,ii)      = beta;
                    %........................................................
                    % OBJECTIVE FUNCTION
                    %........................................................
                    switch lower(obj_fun_type)
                        case {'sym'}
                            O                   = O + w(kk,jj,ii)*(beta_target - beta)^2;
                        case {'asym'}
                    % [Hansen & Sorensen: Reliability-based code calibration of partial safety factors]
                            c                   = 4.35;
                            O                   = O + w(kk,jj,ii)*(c*(beta - beta_target) + exp(-c*(beta - beta_target)) - 1);
                        otherwise
                            error(['Unknown obkective function type (obj_fun): ', obs_fun])
                    end
                end
            end
        end
        
    end

obj_fun(partial_f); % to get the correct beta, minimal computational cost
Results.beta        = Beta;
Results.partial_f   = partial_f;
Results.obj_fun_val = O;
Results.R_k         = R_k;
% only the last is saved but still contains useful information
Results.Probvar     = Probvar_o;

end