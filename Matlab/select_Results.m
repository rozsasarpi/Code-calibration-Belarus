% Postprocess Results: select a particular solution, filter unrealistic results
%
% select gamma (pf_idx_th partial factor!) closest to pf!
%
% Results = SELECT_RESULTS(Model, Results, pf_idx, pf)
%

function [Results, PF] = select_Results(Model, Results, pf_idx, pf)

if nargin < 4
   pf = 1.5; 
end

% Get one specific element from multiple solutions
if ~isfield(Results,'manymins')
    warning('No multiple solutions are available in Results structure!')
else
    manymins    = Results.manymins;
    n_pf        = length(Results.partial_f);
    n_solu      = length(manymins);

    PF          = reshape(cell2mat({manymins.X}),n_pf, n_solu).';
    
    PF
    %...............................................
    % SELECT A PARTICULAR SOLUTION
    %...............................................
    
    % select gamma closest to pf!
    [~, solu_idx] = min(sum(bsxfun(@minus, PF(:,pf_idx), pf).^2,2));

    partial_f   = Results.manymins(solu_idx).X
    Results     = calibrate(Model, partial_f);    
end

end