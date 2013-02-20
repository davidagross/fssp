function B = iphone5_cross_stitch(A)
% IPHONE5_CROSS_STITCH takes in a picture and outputs a cropped on
%
%USAGE
%   B = cross_stitch(A)
%
%AUTHORSHIP
%   Created by David A. Gross on 19 Feb 2013 at 6:30 PM
%
% See Also
%   fssp, mandelbroidery

% configure colors
cMapFun = @autumn;
flipFirst = true;
numColors = 6;

% transfer (this isn't fancy because we aren't resizing)
if ~isequal(size(A),[77,35])
    error('This isn''t an iPhone 5 case design');
end
B = A;
dims = size(B);

% masking
for r = 1:3
    B = rot90(B);
    B(1,1) = nan; B(1,2) = nan;
    B(2,1) = nan; 
end
B = rot90(B);

B(1,1:13) = nan;
B(2,1:15) = nan;
B(3,1:15) = nan;
B(4,1:16) = nan;
B(5,1:16) = nan;
B(6,1:16) = nan;
B(7,1:16) = nan;
B(8,2:16) = nan;
B(9,2:15) = nan;
B(10,3:15) = nan;
B(11,4:13) = nan;

% plotting
if flipFirst
    cMap = [flipud( cMapFun(numColors) ); cMapFun(numColors); 0 0 0];
else
    cMap = [cMapFun(numColors); flipud( cMapFun(numColors) ); 0 0 0];
end
imagescwithnan( B , cMap , [1 1 1] ); shading flat;
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

end

% modified from http://stackoverflow.com/questions/8481324/contrasting-color-for-nans-in-imagesc
function h = imagescwithnan(a,cm,nanclr)
% IMAGESC with NaNs assigning a specific color to NaNs

%# find minimum and maximum
amin=min(a(:));
amax=max(a(:));
%# size of colormap
n = size(cm,1);
%# color step
dmap=(amax-amin)/n;

%# standard imagesc
him = imagesc(a);
%# add nan color to colormap
colormap([nanclr; cm]);
%# changing color limits
caxis([amin-dmap amax]);
%# place a colorbar
% hcb = colorbar;
%# change Y limit for colorbar to avoid showing NaN color
% ylim(hcb,[amin amax])

if nargout > 0
    h = him;
end

end
