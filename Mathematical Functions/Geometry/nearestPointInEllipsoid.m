function [zp,exitFlag]=nearestPointInEllipsoid(z,A,p,gammaVal,varargin)
%%NEARESTPOINTONELLIPSOID Given an ellipsoid such that a point zp on the
%        surface of the ellipsoid satisfies the equation
%        (z-zp)'*A*(z-zp)=gammaVal find the point on or inside the
%        ellipsoid that is closest to another point p.
%
%INPUTS: z  The numDimX1 center of the ellipsoid.
%        A  A numDimXnumDim symmetric, positive definite matrix that
%           specifies the size and shape of the ellipse or ellipsoid, where
%           a point zp is on the ellipse/ellipsoid if
%           (zp-z)'*A*(zp-z)=gammaVal.
%        p  A numDimX1 point.
%  gammaVal The threshold for declaring a point to be in the ellipsoid. If
%           this parameter is omitted or an empty matrix is passed, the
%           default value of 1 is used.
% varargin Any parameters that one might wish to pass to the fzero
%          function. These are generally comma-separated things, such as
%          'TolX',1e-12. 
%
%OUTPUTS: zp The numDimX1 point on the ellipse that is closest to p. If the
%            quadratic programming algorithm fails, then an empty matrix is
%            returned.
%  exitFlag The exit flag from the fzero function, if used. Otherwise, this
%           is 0.
%
%If we say that B=A/gammaVal, then points on the surface of the ellipsoid
%satisfy the equation
%(zp-z)'*B*(zp-z)<=1
%We want to minimize the squared distance
%s^2=(zp-p)'*(zp-p)
%Subject to the point being on the ellipsoid. Let L be the lower-triangular
%Cholesky decomposition of B and say that
%y=L'*(zp-z)
%which is equivalent to
%zp=z+inv(L)'*y
%Then the constraint for a point being on the ellipsoid is  y'*y<=1 and,
%after dropping constant terms, the squared distance that we want to
%minimize becomes
%(inv(L)'*y+z-p)'*(inv(L)'*y+z-p)
%Thus, the problem is a quadratic programming problem with a quadratic
%constraint (that y is unit magnitude). The problem can be solved using the
%constrainedLSSpher function.
%
%EXAMPLE 1:
%This is a 2D example that can be easily plotted. The point is outside the
%ellipse.
% A=[0.1,0;
%    0,10];
% z=[0;10];
% p=[6;10];
% M=[0.413074198133900,  0.910697373904216;
%    -0.910697373904216,   0.413074198133900];%A rotation matrix
% A=M*A*M';
% [zp,exitCode]=nearestPointInEllipsoid(z,A,p);
% figure(1)
% clf
% hold on
% axis([-6,6,-6+10,6+10])
% axis square
% drawEllipse(z,A,1,'g','linewidth',2)
% plot([p(1),zp(1)],[p(2),zp(2)],'--c')
% scatter(p(1),p(2),'ok','linewidth',2)
% scatter(zp(1),zp(2),'xr','linewidth',2)
%
%EXAMPLE 2:
%This is another 2D example. In this instance, the point is inside the
%ellipse, so the point itself is the closest point on or in the ellipse.
% A=[1,0;
%    0,5];
% z=[0;10];
% p=[0.5;10];
% [zp,exitCode]=nearestPointInEllipsoid(z,A,p);
% figure(1)
% clf
% hold on
% axis([-6,6,-6+10,6+10])
% axis square
% drawEllipse(z,A,1,'g','linewidth',2)
% plot([p(1),zp(1)],[p(2),zp(2)],'--c')
% scatter(p(1),p(2),'ok','linewidth',2)
% scatter(zp(1),zp(2),'xr','linewidth',2)
%
%May 2016 David F. Crouse, Naval Research Laboratory, Washington D.C.
%(UNCLASSIFIED) DISTRIBUTION STATEMENT A. Approved for public release.

if(nargin<4||isempty(gammaVal))
   gammaVal=1; 
end

B=A/gammaVal;
L=chol(B,'lower');

A=inv(L)';
b=p-z;

[y,~,exitFlag]=constrainedLSSpher(A,b,1,varargin{:});

if(~isempty(y))
    zp=z+A*y;
else
    zp=[];
end

end

%LICENSE:
%
%The source code is in the public domain and not licensed or under
%copyright. The information and software may be used freely by the public.
%As required by 17 U.S.C. 403, third parties producing copyrighted works
%consisting predominantly of the material produced by U.S. government
%agencies must provide notice with such work(s) identifying the U.S.
%Government material incorporated and stating that such material is not
%subject to copyright protection.
%
%Derived works shall not identify themselves in a manner that implies an
%endorsement by or an affiliation with the Naval Research Laboratory.
%
%RECIPIENT BEARS ALL RISK RELATING TO QUALITY AND PERFORMANCE OF THE
%SOFTWARE AND ANY RELATED MATERIALS, AND AGREES TO INDEMNIFY THE NAVAL
%RESEARCH LABORATORY FOR ALL THIRD-PARTY CLAIMS RESULTING FROM THE ACTIONS
%OF RECIPIENT IN THE USE OF THE SOFTWARE.
