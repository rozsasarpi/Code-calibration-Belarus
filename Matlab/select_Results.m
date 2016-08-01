% Postprocess Results: select a particular solution, filter unrealistic results
%
% if solu_idx == 1 select gamma_S (first partial factor!) closest to 1.5!

function Results = select_Results(Model, Results, solu_idx)

% Get one specific element from multiple solutions
if ~isfield(Results,'manymins')
    warning('No multiple solutions are available in Results structure!')
else
    manymins    = Results.manymins;
    n_pf        = length(Results.partial_f);
    n_solu      = length(manymins);

    PF          = reshape(cell2mat({manymins.X}),n_pf, n_solu).';
    
    %...............................................
    % SELECT A PARTICULAR SOLUTION
    %...............................................
    
    % select gamma_Q closest to 1.5!
    if solu_idx == 0 
        [~, solu_idx] = min((PF(:,1)-1.5).^2);
    end
    partial_f   = Results.manymins(solu_idx).X
    Results     = calibrate(Model, partial_f);    
end

end