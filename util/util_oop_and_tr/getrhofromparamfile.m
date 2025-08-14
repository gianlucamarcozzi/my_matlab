function Sys = getrhofromparamfile(Sys, mode)
    arguments
        Sys
        mode = "statistical"
    end

    % pciss must be between 0 (0 perc CISS) and 1 (100 perc CISS)
    Sys.rho = zeros(4, 4);
    if ~isfield(Sys, 'initState') && ~isfield(Sys, 'pciss')
        warning("The initial density matrix is set to 'singlet' " + ...
            "since no initState nor pciss was declared in the parameters.")
        pciss = 0;
    elseif isfield(Sys, 'initState') && isfield(Sys, 'pciss')
        warning("Both initState and pciss are declared in the " + ...
            "parameters. initState is used to construct rho. pciss " + ...
            "is ingored.")
    end
    if isfield(Sys, 'initState')  % initState used for rho
        initState = lower(Sys.initState);
        if strcmp(initState, 'singlet')
            pciss = 0;
        elseif strcmp(initState, 'ud')
            pciss = pi/2;
        elseif strcmp(initState, 'du')
            pciss = -pi/2;
        else
            error("initState not implemented.")
        end
    elseif ~isfield(Sys, 'initState') && isfield(Sys, 'pciss')
        % only pciss is present
        pciss = Sys.pciss;
    end

    if strcmpi(mode, "superposition")
        % Density matrix of the superposition state
        % Transform pciss from percentage to chi angle
        chi = acos(1 - pciss)
        stateVec = [0, ...
                    cos(chi/2) + sin(chi/2), ...
                    -cos(chi/2) + sin(chi/2), ...
                    0]/sqrt(2);
        Sys.rho = stateVec'*stateVec;
    elseif strcmpi(mode, "statistical")
        % Sum of the density matrices
        rhoS = zeros(4, 4);
        rhoS(2, 2) = 1;
        rhoS(2, 3) = -1;
        rhoS(3, 2) = -1;
        rhoS(3, 3) = 1;
        rhoS = 1/2*rhoS;
        rhoT0 = abs(rhoS);
        % pciss = 0 must give rhoS
        % pciss = 1 must give 1/2(rhoud + rhodu) = 1/2(rhoS + rhoT0)
        Sys.rho = (1 - pciss/2)*rhoS + (pciss/2)*rhoT0;
    else
        fprintf("mode should be 'superposition' or 'statistical'")
        return
    end

end

