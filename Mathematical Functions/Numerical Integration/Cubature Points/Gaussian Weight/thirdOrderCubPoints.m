function [xi, w]=thirdOrderCubPoints(numDim,algorithm,w0)
%THIRDORDERCUBPOINTS Generate third order cubature points for integration
%           involving a multidimensional Gaussian probability density
%           function (PDF).
%
%INPUTS:    numDim  An integer specifying the dimensionality of the points
%                   to be generated. numDim>1.
%         algorithm An optional parameter specifying the algorithm to be
%                   used to generate the points. Possible values are
%                   0 (The default if omitted or an empty matrix is passed)
%                     Use the algorithm of [1] (The "cubature Kalman
%                     filter") set of points.
%                   1 Use the "basic points" for the unscented Kalman
%                     filter given in Section IIIA of [2].
%                   2 Use the "extended symmetric set" from Section IVA of
%                     [2].
%                   3 Formula E_n^{r^2} 3-1 on page 315 of [3],2*numDim
%                     points.
%                   4 Formula E_n^{r^2} 3-2 on page 316 of [3],2^numDim
%                     points.
%               w0 An optional input parameter that is only used in
%                  algorithms 2. This is the value of w(1), the coefficient
%                  associated with a cubature point placed at the origin.
%                  It is required that w(0)>0. Making w0 larger than 1 will
%                  lead to having mostly negative weights. If omitted or an
%                  empty matrix is passed, a default value of 1/3 is used. 
%
%OUTPUTS:   xi      A numDim X numCubaturePoints matrix containing the
%                   cubature points. (Each "point" is a vector)
%           w       A numCubaturePoints X 1 vector of the weights
%                   associated with the cubature points.
%
%Algorithms 1-2 are not normally identified as being "third-order".
%However, due to their symmetry of the points, their odd moments are all
%zero.
%
%For more details on how to use these points, see the comments in the
%function fifthOrderCubPoints.m.
%
%REFERENCES:
%[1] I. Arasaratnam and S. Haykin, "Cubature Kalman filters," IEEE
%    Transactions on Automatic Control, vol. 54, no. 6, pp. 1254-1269, Jun.
%    2009.
%[2] S. J. Julier and J. K. Uhlmann, "Unscented filtering and nonlinear
%    estimation," Proceedings of the IEEE, vol. 92, no. 3, pp. 401-422,
%    Mar. 2004.
%[3] A.H. Stroud, Approximate Calculation of Multiple Integrals. Cliffs,
%    NJ: Prentice-Hall, Inc., 1971.
%
%August 2015 David F. Crouse, Naval Research Laboratory, Washington D.C.
%(UNCLASSIFIED) DISTRIBUTION STATEMENT A. Approved for public release.

    if(nargin<2||isempty(algorithm))
        algorithm=0;
    end

    if(nargin<3||isempty(w0))
       w0=1/3; 
    end

    switch(algorithm)
        case 0%The "cubature Kalman filter" points from [1].
            xi=zeros(numDim,2*numDim);

            curVal=1;
            for curE=1:numDim
                e=zeros(numDim,1);
                e(curE)=sqrt(numDim);

                xi(:,curVal)=e;
                xi(:,curVal+1)=-e;

                curVal=curVal+2;
            end

            w=ones(2*numDim,1)/(2*numDim);
        case 1%The "basic points" for the unscented Kalman filter in
              %Section IIIA of [2].
            numPoints=2*numDim;

            %The weights of integration from Equation 11 in [1]
            w=zeros(numPoints,1);
            w(:)=1/numPoints;
            %The cubature points from Equation 11 in [1], done for unit covariance,
            %zero mean.
            xi=zeros(numDim,numPoints);
            xi(:,1:numDim)=sqrt(numDim)*eye(numDim,numDim);
            xi(:,(numDim+1):numPoints)=-sqrt(numDim)*eye(numDim,numDim);
        case 2%The extended symmetric set from Section IVA of [1]..
            numPoints=2*numDim+1;

            %The weights of integration from Equation 12 in [1]
            w=zeros(numPoints,1);

            w(1)=w0;
            w(2:end)=(1-w(1))/(2*numDim);

            %The cubature points from Equation 12 in [1], done for unit
            %covariance, done for unit covariance, zero mean.
            xi=zeros(numDim,numPoints);
            xi(:,2:(numDim+1))=sqrt(numDim/(1-w0))*eye(numDim,numDim);
            xi(:,(numDim+2):numPoints)=-sqrt(numDim/(1-w0))*eye(numDim,numDim);
        case 3%Formula E_n^{r^2} 3-1 on page 315 of [3],2*numDim points.
            r=sqrt(numDim/2);
            
            %The sqrt(2) makes it for a normal 0-I distribution.
            xi=sqrt(2)*fullSymPerms([r;zeros(numDim-1,1)]);
            w=(1/(2*numDim))*ones(2*numDim,1);
        case 4%Formula E_n^{r^2} 3-2 on page 316 of [3],2^numDim points.
            r=1/sqrt(2);
            
            %The sqrt(2) makes it for a normal 0-I distribution.
            xi=sqrt(2)*PMCombos(r*ones(numDim,1));
            w=2^(-numDim)*ones(2^numDim,1);
        case 5
        otherwise
            error('Unknown algorithm specified')
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
