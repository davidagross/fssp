function B = cross_stitch(A,dims,cMap,method,zeroLevel)
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
%   colormap COLORMAP and uses the provided method (crop)
%
%   B = cross_stitch(A,SIZE,COLORMAP,METHOD,ZEROLEVEL) takes in the matrix
%   (or RGB array) A and outputs a matrix of size SIZE scaled to the
%   colormap COLORMAP and uses the provided method (crop) and setting the
%   zero-level for masking effects.
%
% *Authorship*
%   Created on August 2, 2011 by David Gross
%   Last Modified on December 31, 2012 by David Gross
%
% See Also
%   fssp

%% Check Inputs
if ~exist('method','var') || isempty(method)
    method = 'crop';
end
if ~exist('cMap','var') || isempty(cMap)
    cMap = [1,.4,.4;.2,.2,.2;0,.5,1];
end
if ~exist('dims','var') || isempty(dims)
    dims = [69,33];
end
if nargin<1
    error('cross_stitch:InvalidInputs', ...
        'Must provide an image to process');
end
%% Size the Image
A = flipud(A);
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
totalColors = unique(B);
diffs = diff(linspace(min(totalColors),max(totalColors),size(cMap,1)));
cMap = [1 1 1 ; cMap];
if ~exist('zeroLevel','var') || isempty(zeroLevel)
    zeroLevel = min(totalColors)-diffs(1);
end

%% mask
B(1,1) = zeroLevel; B(1,2) = zeroLevel; B(2,1) = zeroLevel;
B(1,end) = zeroLevel; B(1,end-1) = zeroLevel; B(2,end) = zeroLevel;
B(end,end) = zeroLevel; B(end,end-1) = zeroLevel; B(end-1,end) = zeroLevel;
B(end-7:end,1:12) = zeroLevel;

%% plotting
colormap(cMap);
imagesc(flipud(B),[zeroLevel+1,max(totalColors)+1]);
grid on; grid minor;
axis equal tight;
ax1 = gca;
set(ax1,'xtick',0:5:dims(2),'ytick',0:5:dims(1));
set(ax1,'yticklabel',fliplr(0:5:dims(1)+5));
ax2 = axes(rmfield(get(ax1), { ...
    'BeingDeleted','CurrentPoint','TightInset', ...
    'Title','Type','XLabel','YLabel','ZLabel', ...
    'Children'}));
set(ax2,'XAxisLocation','top',...
    'YAxisLocation','right',...
    'Color','none');
axes(ax1)
