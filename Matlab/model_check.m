% Some basic check of Model
%
%SYNOPSYS
% Model = MODEL_CHECK(Model)
%

function Model = model_check(Model)

%==========================================================================
% INITIALIZATION
%==========================================================================
gamma_Q_type    = Model.gamma_Q_type;
gamma_Q_diff    = Model.gamma_Q_diff;


lead_action_idx = Model.lead_action_idx;

limit_state_idx = Model.limit_state_idx;

limit_state_label = Model.limit_state_label;



%==========================================================================
% CHECK
%==========================================================================

if length(Model.limit_state_label) < length(limit_state_idx)
    error('Number of limit state labels should be equal or greater than than the number of limit states!')
end

gamma_R_label = {};
for ii = 1:length(limit_state_label)
    gamma_R_label   = {gamma_R_label{:}, ['gamma_{R,',limit_state_label{ii},'}']};
end
gamma_R_label   = gamma_R_label(limit_state_idx);

if strncmpi(gamma_Q_type,'l',1) && strncmpi(gamma_Q_diff,'y',1)
    error('Linear gamma_Q cannot be applied if different gamma_Q is selected for each variable actions!')
end



% different partial factor for each leading actions?
switch lower(gamma_Q_diff)
    case {'y', 'yes'}
        gamma_Q_label   = {'gamma_S', 'gamma_I', 'gamma_W'};
        gamma_Q_label   = gamma_Q_label(lead_action_idx);
        n_gamma_Q       = length(lead_action_idx);
    case {'n', 'no'}
        gamma_Q_label   = {'gamma_Q'};
        n_gamma_Q       = 1;
    otherwise
        error(['diff_gamma_Q should be ''yes'' or ''no'', and not: ', gamma_Q_diff])
end



switch lower(gamma_Q_type)
    case {'constant'}
        % do nothing
    case {'linear'}
        gamma_Q_label = {'gamma_{Qa}', 'gamma_{Qb}'};
    otherwise
        error(['Unknown partial factor type: ', gamma_Q_type])
end

gamma_label         = {gamma_Q_label{:}, 'gamma_G', gamma_R_label{:}};

%==========================================================================
% GATHER OUTPUT
%==========================================================================
Model.gamma_label   = gamma_label;
Model.n_gamma_Q     = n_gamma_Q;

end