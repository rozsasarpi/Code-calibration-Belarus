close all
clc
n_solu = length(Results.manymins);
n_rc = ceil(sqrt(n_solu));

% TO CHECK IF THE CURVES DIFFERS FOR DIFFERENT PARTIAL FACTORS BUT SAME OBJECTIVE FUNCTION VALUE!
for ii = 1:n_solu
    partial_f = Results.manymins(ii).X;
    Results_ = calibrate(Model, partial_f);
    Results_
    plot_reli_vs_loadratio(Model, Results_)
end