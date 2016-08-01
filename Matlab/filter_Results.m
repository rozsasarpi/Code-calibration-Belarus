% Postprocess Results: filter unrealistic results
%

function Results = filter_Results(Results)


% Get one specific element from multiple solutions
if ~isfield(Results,'manymins')
    warning('No multiple solutions are available in Results structure!')
else
    manymins    = Results.manymins;

    O_val       = cell2mat({manymins.Fval}).';
    
    %...............................................
    % FILTER SUSPICIOS SOLUTIONS
    %...............................................
    mO_val      = mode(O_val);
    idx         = abs(O_val - mO_val) > mO_val;
    
    if any(idx)    
        warning([num2str(sum(idx)), ' of ',num2str(length(idx)),' available solutions are filterd with suspicion of ill-convergence!'])
    end
    
    Results.manymins = Results.manymins(~idx);   
end

end