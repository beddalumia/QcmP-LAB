function dry_line(EXE,doMPI,Uold,Umin,Ustep,Umax,varargin)
%% Runs a U-line with no other convergence control than building a U_list.txt file

    %   EXE                 : Executable driver
    %   doMPI               : Flag to activate OpenMPI
    %   Uold                : Restart point [Uold<Umin]
    %   Umin,Ustep,Umax     : Input Hubbard interaction [Umin:Ustep:Umax]

    %   varargin            : Set of fixed control parameters ['name',value]

    Ulist = fopen('U_list.txt','a');

    %% Phase-Line: single loop %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    U = Umin; 
    while U <= Umax

        runDMFT.single_point(EXE,doMPI,U,Uold,varargin{:});

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% HERE WE CATCH A FAILED (unconverged) DMFT LOOP
        errorfile = [sprintf('U=%f',U),'/ERROR.README'];
        if ~isfile(errorfile) 
            fprintf(Ulist,'%f\n', U);   % Update U-list (only if converged)
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        Uold = U;
        U = U + Ustep;                  % Hubbard update  

    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    fclose(Ulist);

end




