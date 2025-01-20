% --- Function Summary --- %
% Call function when plotting background to be black
% Must also call 'colordef black' then change back for normal plots

function plt(x, y, figObj, plot_type, varargin)

if ~isempty(varargin)
    linestyle = varargin{1};
else
    linestyle = '-'; 
end

switch lower(plot_type)

    case 'log'
        semilogx(x, y, linestyle, 'LineWidth',1.5)
        grid minor; 

    case 'plt'
        plot(x, y, linestyle, 'LineWidth',1.5);
        grid minor; 

    otherwise
        error("invalid plot type")


end
%---
figAx = figObj.get.CurrentAxes;
figAx.Title.FontSize = 20; 
gca; grid minor; axis tight; 
%figAx.
%---
set(groot, 'defaultAxesTickLabelInterpreter','tex'); 
set(groot, 'defaultLegendInterpreter','tex');

whitebg('black'); 
set(figObj, 'InvertHardCopy', 'off'); 
set(figObj,'Color',[0 0 0]); 
set(groot,'defaultAxesFontName','Georgia')
set(groot,'defaultAxesFontSize',16)
end

