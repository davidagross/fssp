function A = mandelbroidery()
% MANDELBROIDERY - Mandelbrot Embroidery Pattern
%
%USAGE
%   A = mandelbroidery() will create a matrix of color intensities based on
%   rates of divergence from the edge of the mandelbrot set
%
%REFERENCES
%   [1] http://blogs.mathworks.com/loren/ ...
%       2011/07/18/a-mandelbrot-set-on-the-gpu/
%   [2] http://www.mathworks.com/moler/exm/chapters/mandelbrot.pdf
%
%AUTHORSHIP
%   Created by David A. Gross on 19 Feb 2013 at 8:43 AM
%
% See Also
%   iphone5_cross_stich

% configure sizing
c0 = .14 + .93*1i;
% c0 = .105 + .93*1i;
depth = 1000;
% xlim = [-.5, .5] * .09;
% xlim = [-.5, .5] * .006;
xlim = [-.5, .5] * .1;
ylim = 2.2*xlim;
grid = [35,77];
x = linspace( xlim(1), xlim(2), grid(1) );
y = linspace( ylim(1), ylim(2), grid(2) );

% make grid
[xGrid,yGrid] = meshgrid( x - real(c0), y - imag(c0));
c = xGrid + 1i * yGrid;
count = zeros(size(c));

% calculate
z = c;
for k = 0:depth
   
    z = z.*z + c;
    inside = abs(z) < 2;
    count = count + inside;
    
end
A = log( count+1 );

end