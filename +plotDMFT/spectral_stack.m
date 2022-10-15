function spectral_stack(filename,dx,dy,cmap_name,ulist,varargin)
%% SPECTRAL_STACK: Builds a classic stacked plot for the requested spectral
%                  tensors, reading along a computed U-driven line
%
%   >> plotDMFT.spectral_stack(filename,dx,dy,cmap_name,ulist,varargin)
%
%  filename : filename of the complex spectral function to be plotted
%  dx       : horizontal step for stacking, in units of U, for proper scaling
%  dy       : vertical step for stacking, in units of U, for proper scaling
%  cmap_name: name of the desired colormap as a string (optional, see colorlab)
%  ulist    : an array of values for Hubbard interaction U (could be empty!)
%  varargin : additional options to be passed to plotter
%
% See also get_palette palette paletteshow
%  ------------------------------------------------------------------------
    if ~exist('ulist','var') || isempty(ulist)
        [ulist, ~] = postDMFT.get_list('U'); 
    else
        ulist = sort(ulist);
    end
    if ~exist('cmap_name','var') || isempty(cmap_name)
        cmap_name = 'berlin';
    end

    Nu = length(ulist);

    fprintf('Start stacking spectra...\n\n');

    plotDMFT.import_colorlab();
    colorlist = get_palette(cmap_name,Nu);

    for iU = 1:Nu

        % Check for <U=%f> directory
        U = ulist(iU);
        UDIR = sprintf('U=%f',U);
        if ~isfolder(UDIR)
            errstr = 'U_list appears to be inconsistent: ';
            errstr = [errstr,UDIR];
            errstr = [errstr,' folder has not been found.'];
            error(errstr);
        end

        % Enter directory
        cd(UDIR); 

        % Pick and plot the requested filename
        f = plotDMFT.spectral_load(filename);

        % Plot f(x+dx)+dy curves
        plot(f.zeta+U*dx,f.imag+U*dy,'Color',colorlist(iU,:),varargin{:});
        % We could directly use waterfall(), but it requires Z to be a
        % meshgrid or something (a matrix) and the plotting to be done
        % outside of the loop: it would be also faster... and the plot
        % actually flexible regarding the 'viewpoint'. >>>> TODO? <<<<

        % Hold the figure handle
        hold on
        
        % Adjust title to highlight U value
        title(UDIR);

        % Exit directory
        cd('..');

    end
    
    fprintf('...DONE.\n\n');

end 
     