function varargout = cross_stitch(varargin)
% CROSS_STITCH takes in a picture and outputs a color coded matrix
%
% *Usage*
%   B = cross_stitch(A) takes in the matrix (or RGB array) A and outputs a
%   matrix of size <<INSERT IPHONE CASE SIZE HERE>> scaled to the <<DEFAULT
%   COLOR SCHEME>>
%
%   B = cross_stitch(A,SIZE) takes in the matrix (or RGB array) A and
%   outputs a matrix of size SIZE scaled to the <<DEFAULT COLOR SCHEME>>
%
%   B = cross_stitch(A,SIZE,COLORMAP) takes in the matrix (or RGB array) A
%   and outputs a matrix of size SIZE scaled to the colormap COLORMAP
%
%   B = cross_stitch(A,SIZE,COLORMAP,METHOD) takes in the matrix
%   (or RGB array) A and outputs a matrix of size SIZE scaled to the
%   colormap COLORMAP and uses the provided method (shrink or crop)
%
% *Authorship*
%   Created on August 2, 2011 by David Gross
%   Last Modified on August 2, 2011 by David Gross
%
% See Also
%   fssp

%% Check Inputs
if nargin<5, zeroLevel = 0; end
if nargin<4, method = 'crop'; else method = varargin{4}; end
if nargin<3, cMap = [1,.4,.4;.2,.2,.2;0,.5,1]; else cMap = varargin{3}; end
if nargin<2, dims = [69,33]; else dims = varargin{2}; end
if nargin<1, error('cross_stitch:InvalidInputs', ...
        'Must provide an image to process'); else A = varargin{1}; end
%% Size the Image
B = zeros(dims);
switch method
    case 'crop'
        isSmallerOrEqual = size(A) <= dims;
        if isSmallerOrEqual(1) && isSmallerOrEqual(2)
            B((1:size(A,1))-round(size(A,1)/2)+round(size(B,1)/2), ...
                (1:size(A,2))-round(size(A,2)/2)+round(size(B,2)/2)) = A;
        elseif isSmallerOrEqual(1) && ~isSmallerOrEqual(2)
            B((1:size(A,1))-round(size(A,1)/2)+round(size(B,1)/2),:) = ...
                A(:,(1:size(B,2))-round(size(B,2)/2)+round(size(A,2)/2));
        elseif ~isSmallerOrEqual(1) && isSmallerOrEqual(2)
            B(:,(1:size(A,2))-round(size(A,2)/2)+round(size(B,2)/2),:) = ...
                A((1:size(B,1))-round(size(B,1)/2)+round(size(A,1)/2),:);
        elseif ~isSmallerOrEqual(1) && ~isSmallerOrEqual(2)
            B = A((1:size(B,1))-round(size(B,1)/2)+round(size(A,1)/2), ...
                (1:size(B,2))-round(size(B,2)/2)+round(size(A,2)/2));
        end
    otherwise
        error('cross_stitch:InvalidInputs', ...
            'Method must be "crop".');
end
%% Color the image
% B = B - min(B(:));
% B = B./max(B(:)) + zeroLevel;
% for i = 1:numel(B)
%    B(i) = floor(B(i)*(size(cMap,1)-1));
% end

%% mask
B(1,1) = zeroLevel; B(1,2) = zeroLevel; B(2,1) = zeroLevel;
B(1,end) = zeroLevel; B(1,end-1) = zeroLevel; B(2,end) = zeroLevel;
B(end,end) = zeroLevel; B(end,end-1) = zeroLevel; B(end-1,end) = zeroLevel;
B(end-7:end,1:12) = zeroLevel;

%% Deal with outputs
if nargout < 1
    imagesc(flipud(B)); grid on; grid minor
    set(gca,'xtick',0:5:33);
    set(gca,'yticklabel',flipud(get(gca,'yticklabel')));
    colormap(cMap); 
    axis equal tight; 
end
if nargout == 1, varargout{1} = B; end
