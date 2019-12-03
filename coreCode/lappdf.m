function y = lappdf(x,u,b)
%LAPPDF Laplace probability density function
%   Y = LAPPDF(X,U,B) returns the Laplace probability density function
%   with mean U and scale parameter B, at the values in X.
%
%   Type: Continuous, unbounded
%   Restrictions:
%     B>0
%
%   The size of Y is the common size of the input arguments. A scalar input
%   functions as a constant matrix of the same size as the other inputs.
%

%   Mike Sheppard
%   Last Modified 24-Jun-2011


if nargin < 3
   error('lappdf:TooFewInputs','Requires three input arguments.');
end

[errorcode, x,u,b] = distchck(3,x,u,b);

if errorcode > 0
    error('lappdf:InputSizeMismatch',...
          'Requires non-scalar arguments to match in size.');
end

% Initialize y to zero.
if isa(x,'single') || isa(u,'single') || isa(b,'single')
   y = zeros(size(x),'single');
else
   y = zeros(size(x));
end

k=(b>0);

if any(k)
    y(k)=(exp(-abs(x(k)-u(k))./b(k)))./(2.*b(k));
end

% Return NaN for out of range parameters.
y(b<=0) = NaN;

%Round-off
y(y<0)=0;


end