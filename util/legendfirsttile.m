function lgd = legendfirsttile(tL, varargin)
% ADD DOCUMENTATION

ax = nexttile(1);
if nargin > 3
    ME = MException('legentFirstTile: too many imput arguments');
    throw(ME);
elseif nargin == 3
    displayNames = varargin{1};
    h = varargin{2};
    lgd = legend(ax, h, displayNames);
elseif nargin == 2
    displayNames = varargin{1};
    lgd = legend(ax, displayNames);
else
    lgd = legend(ax);
end

gridSize = tL.GridSize;
if gridSize(1) ~= 1 || gridSize(2) ~= 1
    lgd.ItemTokenSize = [10 10 10];
end
% lgd.Location = 'NorthEast';
% lgd.NumColumns = 2;

end

