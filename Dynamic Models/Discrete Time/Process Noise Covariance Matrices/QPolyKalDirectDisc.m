function Q=QPolyKalDirectDisc(T,x,order,sigmaV2)
%%QPOLYKALDIRECTDISC  Get the process noise covariance matrix for a direct
%           discrete linear dynamic model of the given polynomial
%           order (number of derivatives of position included) and number
%           of dimensions (generally 3 for 3D motion). order=1 means
%           the discrete white noise acceleration model (DWNA). order=2
%           means the discrete white noise jerk model, etc. The state is
%           ordered in terms of position, velocity, acceleration, etc.
%           Unlike the discretized continuous-time model in the function
%           QPolyKal, the direct-discrete implementation produces a
%           singular matrix and inconsistencies arise when predicting over
%           a time period of 2*T versus sequentially predicting over two
%           time perods of length T. In this function, the process noise is
%           modeled as being one moment higher than the highest order of
%           the state. This is contrasted with the function
%           QPolyKalDirectAlt where the process noise is at the highest
%           order of the state.
%
%INPUTS: T      The time-duration of the propagation interval.
%        x      The (numDim*(order+1))X1 target state. This is just used to
%               extract numDim and for functions that expect the first two
%               parameters of a process noise  covariance matrix function
%               to be T and x.
%        order  The order >=0 of the filter. If order=1, then it is 
%               constant velocity, 2 means constant acceleration, 3 means
%               constant jerk, etc.
%      sigmaV2  The variance driving the process noise. This has units of
%               distance^2/time^(2*(order+1)). sqrt(sigmaV2)*T is
%               proportional to the maximum change in the highest-order
%               moment of the system. If a scalar is passed, it is assumed
%               to be the same for all dimensions. Otherwise, a numDimX1 or
%               1XnumDim vector should be passed specifying the value for
%               each dimension.
%
%OUTPUTS: Q     The process noise covariance matrix under the direct
%               discrete linear dynamic model of the given order with
%               motion in numDim dimensions where the state is stacked
%               [position;velocity;acceleration;etc] where the number of
%               derivatives of position depends on the order given. Order=0
%               means just position.
%
%Chapters 1.5.5 and 1.5.6 of [1] presents the discrete white noise
%acceleration and jerk models, for orders one and two. The logic behind the
%order 1 model, which extends to any order, is explained in Chapter 6.3.2
%of [2]. The generalization has the matrix for 1D motion being sigmaV2*G*G'
%where the ith element in the column vector G is T^(order-i+2)/(order-i+2)!
%where i counts from 1 to order+1.
%
%Note that order=2 produces the discrete white noise jerk model, not the
%discrete Wiener process acceleration model.
%
%This process noise matrix is most commonly used with the FPolyKal state
%transition matrix.
%
%REFERENCES:
%[1] Y. Bar-Shalom, P. K. Willett, and X. Tian, Tracking and Data Fusion.
%    Storrs, CT: YBS Publishing, 2011.
%[2] Y. Bar-Shalom, X. R. Li, and T. Kirubarajan, Estimation with
%    Applications to Tracking and Navigation. New York: John Wiley and
%    Sons, Inc, 2001.
%
%April 2014 David F. Crouse, Naval Research Laboratory, Washington D.C.
%(UNCLASSIFIED) DISTRIBUTION STATEMENT A. Approved for public release.

xDim=size(x,1);
numDim=xDim/(order+1);

if(isscalar(sigmaV2))
    sigmaV2=ones(numDim,1)*sigmaV2;
end

numEl=order+1;
i=(1:numEl)';
G=T.^(order-i+2)./factorial(order-i+2);
%These are the elements of all of the 1D submatrices, except they have to
%be multiplied by the appropriate sigmaV.
QBase=G*G';

%Now, the elements just get spread across identity matrices (scaled by
%sigmaV2) that are numDim dimensional to form a process noise covariance
%matrix of the desired dimensionality. This is done using a Kronecker
%product.
Q=kron(QBase,diag(sigmaV2));

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
