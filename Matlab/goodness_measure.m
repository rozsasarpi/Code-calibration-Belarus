% Calculates various goodness measures for calibrated partial factors
%
% Model and Results are required as inputs although only these are used:
% - beta_target
% - objective_function
% - beta
% - weights
%
% Filtered & selected Results is expected
%
%

function goodness_measure(Model, Results)

% objective function value at minimum
O           = Results.obj_fun_val;

w           = Model.w(:);
w           = w/sum(w);
beta        = Results.beta(:);

% beta_med    = weighted_median(beta,w);
beta_mean   = sum(beta.*w);
% median absolute deviation
% weighted mad should be implemented in Matlab, for inspiration see matrixStats R package
beta_std    = sqrt(var(beta, w));

beta_minmax = [min(beta), max(beta)];

%--------------------------------------------------------------------------
% Print measures
disp(['O =      ', num2str(O)])
% disp(['median = ', num2str(beta_med)])
disp(['weighted_mean = ', num2str(beta_mean)])
% disp(['mad =    ', num2str(beta_mad)])
disp(['weighted_std = ', num2str(beta_std)])
disp(['minmax = ', num2str(beta_minmax)])

end

