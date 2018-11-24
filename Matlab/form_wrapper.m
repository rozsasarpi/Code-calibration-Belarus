function [beta, formresults] = form_wrapper(Probvar, diagnostic)

if nargin < 2
    diagnostic = 'no';
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DATA FIELDS IN 'PROBDATA'  %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Names of random variables. Default names are 'x1', 'x2', ..., if not explicitely defined.

probdata.name           = fieldnames(Probvar);


% Marginal distributions for each random variable
% probdata.marg =  [ (type) (mean) (stdv) (startpoint) (p1) (p2) (p3) (p4) (input_type); ... ];

n_rv                    = length(probdata.name);

marg                    = nan(n_rv,9);
for ii = 1:n_rv
    RV          = Probvar.(probdata.name{ii});
    marg(ii,:)  = [RV.dist, RV.mean, RV.std, RV.mean, NaN, NaN, NaN, NaN, 0];
end

probdata.marg           = marg;

% Correlation matrix 
probdata.correlation    = eye(length(probdata.marg));

probdata.transf_type    = 3;
probdata.Ro_method      = 1;
probdata.flag_sens      = 0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DATA FIELDS IN 'ANALYSISOPT'  %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
analysisopt.echo_flag            = 0;

analysisopt.multi_proc           = 1;        % 1: block_size g-calls sent simultaneously
                                             %    - gfunbasic.m is used and a vectorized version of gfundata.expression is available.
                                             %      The number of g-calls sent simultaneously (block_size) depends on the memory
                                             %      available on the computer running FERUM.
                                             %    - gfunxxx.m user-specific g-function is used and able to handle block_size computations
                                             %      sent simultaneously, on a cluster of PCs or any other multiprocessor computer platform.
                                             % 0: g-calls sent sequentially
analysisopt.block_size           = 10^4;   % Number of g-calls to be sent simultaneously

% FORM analysis options
analysisopt.i_max                = 500;      % Maximum number of iterations allowed in the search algorithm
analysisopt.e1                   = 0.001;    % Tolerance on how close design point is to limit-state surface
analysisopt.e2                   = 0.001;    % Tolerance on how accurately the gradient points towards the origin
analysisopt.step_code            = 0;        % 0: step size by Armijo rule, otherwise: given value is the step size
analysisopt.Recorded_u           = 1;        % 0: u-vector not recorded at all iterations, 1: u-vector recorded at all iterations
analysisopt.Recorded_x           = 1;        % 0: x-vector not recorded at all iterations, 1: x-vector recorded at all iterations

% FORM, SORM analysis options
analysisopt.grad_flag            = 'ffd';    % 'ddm': direct differentiation, 'ffd': forward finite difference
analysisopt.ffdpara              = 1000;     % Parameter for computation of FFD estimates of gradients - Perturbation = stdv/analysisopt.ffdpara;
                                             % Recommended values: 1000 for basic limit-state functions, 50 for FE-based limit-state functions
analysisopt.ffdpara_thetag       = 1000;     % Parameter for computation of FFD estimates of dbeta_dthetag
                                             % perturbation = thetag/analysisopt.ffdpara_thetag if thetag ~= 0 or 1/analysisopt.ffdpara_thetag if thetag == 0;
                                             % Recommended values: 1000 for basic limit-state functions, 100 for FE-based limit-state functions

% Simulation analysis (MC,IS,DS,SS) and distribution analysis options
analysisopt.num_sim              = 100000;   % Number of samples (MC,IS), number of samples per subset step (SS) or number of directions (DS)
analysisopt.rand_generator       = 1;        % 0: default rand matlab function, 1: Mersenne Twister (to be preferred)

% Simulation analysis (MC, IS) and distribution analysis options
analysisopt.sim_point            = 'dspt';  % 'dspt': design point, 'origin': origin in standard normal space (simulation analysis)
analysisopt.stdv_sim             = 1;        % Standard deviation of sampling distribution in simulation analysis
                                             
% Simulation analysis (MC, IS)
analysisopt.target_cov           = 0.01;   % Target coefficient of variation for failure probability
analysisopt.lowRAM               = 0;        % 1: memory savings allowed, 0: no memory savings allowed

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DATA FIELDS IN 'GFUNDATA' (one structure per gfun)  %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Type of limit-state function evaluator:
% 'basic': the limit-state function is defined by means of an analytical expression or a Matlab m-function,
%          using gfundata(lsf).expression. The function gfun.m calls gfunbasic.m, which evaluates gfundata(lsf).expression.
% 'xxx':   the limit-state function evaluation requires a call to an external code.  The function gfun.m calls gfunxxx.m,
%          which evaluates gfundata(lsf).expression where gext variable is a result of the external code.
gfundata(1).evaluator  = 'basic';
gfundata(1).type       = 'expression';   % Do not change this field!
        
% Expression of the limit-state function:
gfundata(1).expression = 'simple_gfun(Q, C_Q, G, K_E, R, K_R)';

gfundata(1).thetag     =  [];

gfundata(1).thetagname = { };


% Flag for computation of sensitivities w.r.t. thetag parameters of the limit-state function
% 1: all sensitivities assessed, 0: no sensitivities assessment
gfundata(1).flag_sens  = 1;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DATA FIELDS IN 'FEMODEL'  %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

femodel = [];


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DATA FIELDS IN 'RANDOMFIELD'  %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

randomfield = [];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FORM ANALYSIS %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% This function updates probdata and gfundata before any analysis (must be run only once)
[probdata, gfundata, analysisopt] = update_data(1, probdata, analysisopt, gfundata, []);

% This function completely determines and updates parameters, mean and standard deviation associated with the distribution of each random variable
probdata.marg = distribution_parameter(probdata.marg);

if any(any(isnan(probdata.marg)))
    beta = NaN;
    Warning('Fzero did not converge for R_k, thus skipping FORM analysis and returning beta = NaN!')
else
% FORM analysis %
[formresults, ~] = form(1, probdata, analysisopt, gfundata, femodel, randomfield);

beta        = formresults.beta;

% for testing using Pf, WARNING!
% beta        = normcdf(-beta);

switch diagnostic
    case {'y', 'yes', 1}
        disp('Sensitivity factors:')
        alpha       = formresults.alpha;
        disp(alpha)
    case {'n', 'no', 0}
        % do nothing
    otherwise
        warning('The provided diagnostic value is unknown!')
end

end