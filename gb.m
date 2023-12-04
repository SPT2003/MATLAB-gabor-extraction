function gbfilter=gb(imsize, lamda, theta, sigma)

phase = 0;                              % phase (0 -> 1)
trim = 0;                               % trim off gaussian values smaller than this

X = 1:imsize;                           % X is a vector from 1 to imageSize
X0 = (X / imsize) - 0.5;                 % rescale X -> -.5 to .5

sin_wav = sin(X0 * 2*pi);                  % convert to radians and do sine

f = imsize/lamda;                    % compute frequency from wavelength
Xf = X0 * f * 2*pi;                  % convert X to radians: 0 -> ( 2*pi * frequency)
sin_wav = sin(Xf) ;                        % make new sinewave
phaseRad = (phase * 2* pi);             % convert to radians: 0 -> 2*pi
sin_wav = sin( Xf + phaseRad) ;            % make phase-shifted sinewave

[Xm Ym] = meshgrid(X0, X0);             % 2-Dimension matrices

Xf = Xm * f * 2*pi;
grating = sin( Xf + phaseRad);          % make 2D sinewave

%%
thetaRad = 2*pi*(theta/360);        % convert theta (orientation) to radians
Xt = Xm * cos(thetaRad);                % compute proportion of Xm for given orientation
Yt = Ym * sin(thetaRad);                % compute proportion of Ym for given orientation
XYt =  Xt + Yt ;                      % sum X and Y components
XYf = 2*pi*XYt*f;                % convert to radians and scale by frequency
grating = sin(XYf+phaseRad);         % make 2D sinewave

s = sigma / imsize;                     % gaussian width as fraction of imageSize
Xg = exp( -( ( (X0.^2) ) ./ (2* s^2) ));% formula for 1D gaussian
Xg = normpdf(X0, 0, (20/imsize)); Xg = Xg/max(Xg);  % alternative using normalized probability function (stats toolbox)

gauss = exp( -(((Xm.^2)+(Ym.^2)) ./ (2* s^2)) );    % formula for 2D gaussian

gauss(gauss < trim) = 0;                 % trim around edges (for 8-bit colour displays)
gbfilter = grating .* gauss;                % use .* dot-product

% figure
% hold on
% title([num2str(theta),' degree'])
% imagesc( gbfilter, [-1 1] );                % display
% axis([0 imsize 0 imsize])
% axis square
% axis off
% colormap('gray')
end