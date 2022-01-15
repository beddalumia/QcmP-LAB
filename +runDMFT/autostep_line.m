function autostep_line(EXE,doMPI,Uold,Umin,Umax,varargin)
%% Runs a U-line with feedback-controlled steps: 
%  if dmft does not converge the point is discarded and the Ustep is reduced.

    %   EXE                 : Executable driver
    %   doMPI               : Flag to activate OpenMPI
    %   Uold                : Restart point [Uold<Umin]
    %   Umin,Umax           : Input Hubbard interaction [Umin<U<Umax]

    %   varargin            : Set of fixed control parameters ['name',value]

    Ulist = fopen('U_list.txt','a');

    %% Phase-Line: single loop %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    Ustep = [.5,.25,.1,.05,.01];       % Let's keep them hard-coded...
    NUstep = length(Ustep);

    nonconvFLG = false;                % Convergence-fail *flag*
    nonconvCNT = 0;                    % Convergence-fail *counter*
    nonconvMAX = NUstep-1;             % Maximum #{times} we accept DMFT to fail

    U = Umin; 
    while U <= Umax

        runDMFT.single_point(EXE,doMPI,U,Uold,varargin{:});

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% HERE WE CATCH A FAILED (unconverged) DMFT LOOP
        errorfile = [sprintf('U=%f',U),'/ERROR.README'];
        if isfile(errorfile) 
            nonconvFLG = true;
            nonconvCNT = nonconvCNT + 1;
            movefile(errorfile,sprintf('ERROR_U=%f',U));
        else
            fprintf(Ulist,'%f\n', U);	            % Write on U-log
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        if nonconvCNT > nonconvMAX
            error('Not converged: phase-span stops now!');         
        end 

        if nonconvFLG == true
            U = Uold; 			        % if nonconverged we don't want to update 
            nonconvFLG = false;	        % > but we want to reset the flag(!)
        else
            Uold = U; 			        % else we update Uold and proceed to...         
        end

        U = U + Ustep(notConvCount+1);  % ...Hubbard update  

    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    fclose(Ulist);

end




