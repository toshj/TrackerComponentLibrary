classdef GammaD
%Functions to handle the central and noncentral univariate gamma
%distributions.
%Methods implemented for both central and noncentral distributions are:
%PDF, CDF
%Methods only implemented for the central distribution are: mean, var,
%                                                           invCDF, rand
%
%(UNCLASSIFIED) DISTRIBUTION STATEMENT A. Approved for public release.

methods(Static)

function val=mean(k, theta, lambda)
%%MEAN  Obtain the mean of the gamma distribution for given shape and scale
%       parameters.
%
%INPUTS:    k       The shape parameter of the distribution; k>0.
%           theta   The scale parameter of the distribution; theta>0.
%           lambda  The noncentrality parameter of the distribution. If
%                   this parameter is omitted or an empty matrix is passed,
%                   a value of 0, indicating the central gamma
%                   distribution, is used.
%
%OUTPUTS: val  The mean of the gamma distribution.
%
%Currently, the algorithm is only implemented for the case where lambda=0.
%
%October 2013 David F. Crouse, Naval Research Laboratory, Washington D.C.

if(nargin<3||isempty(lambda))
   lambda=0; 
end

if(lambda == 0)
    val=k*theta;
else
    error('This function is not currently supported for noncentral gamma distribution');
end
end

function val=var(k,theta,lambda)
%%VAR   Obtain the variance of the gamma distribution for given shape and
%       scale parameters.
%
%INPUTS:    k       The shape parameter of the distribution; k>0.
%           theta   The scale parameter of the distribution; theta>0..
%           lambda  The noncentrality parameter of the distribution. If
%                   this parameter is omitted or an empty matrix is passed,
%                   a value of 0, indicating the central gamma
%                   distribution, is used.
%
%OUTPUTS: val  The variance of the gamma distribution.
%
%%Currently, the algorithm is only implemented for the case where lambda=0.
%
%October 2013 David F. Crouse, Naval Research Laboratory, Washington D.C.

if(nargin<3||isempty(lambda))
   lambda=0; 
end

if(lambda == 0)
    val=k*theta^2;
else
    error('This function is not currently supported for noncentral gamma distribution');
end
end    
    

function val=PDF(x,k,theta,lambda,errTol,maxIter)
%%PDF      Evaluate the noncentral gamma probability distribution function
%          at a desired point.
%
%INPUTS:    x       The point(s) at which the noncentral gamma PDF 
%                   is to be evaluated. Note that the PDF is only nonzero
%                   for x>=0.
%           k       The shape parameter of the distribution; k>0.
%           theta   The scale parameter of the distribution; theta>0.
%           lambda  The noncentrality parameter of the distribution. If
%                   this parameter is omitted or an empty matrix is passed,
%                   a value of 0, indicating the central gamma
%                   distribution, is used.
%           errTol  Error tolerance for determining convergence of the
%                   algorithm whem lambda~=0. If this parameter is omitted
%                   or an empty matrix is passed, the default of eps(1) is
%                   used.
%           maxIter The maximum number of iterations to allow. This is only
%                   used matters when lambda~=0. If this parameter is
%                   omitted or an empty matrix is passed, then a default
%                   value of 5000 is used.
%
%OUTPUTS:   val The value(s) of the PDF of the noncentral gamma
%               distribution with parameters k, theta, and lambda evaluated
%               at x.
%
%This is an implementation of the distribution computations from [1]. The
%work in [1] concerns algorithms that implement the distribution
%approximations in [2]. This function implements the algorithm for
%computation of the probability distribution function. When lambda is zero,
%the central gamma case, a simple explicit formula is available.
%
%REFERENCES:
%[1] I.R.C. de Oliveria and D.F. Ferreira, "Computing the noncentral gamma
%    distribution, its inverse and the noncentrality parameter," 
%    Computational Statistics, vol. 28, no. 4, pp.1663-1680, 01 Aug 2013.
%[2] L. Kn�sel and B. Bablok, "Computation of the noncentral gamma
%    distribution," SIAM Journal on Scientific Computing, vol. 17, no. 5,
%    pp.1224-1231, Sep. 1996.
%
%December 2014 David A. Karnick, Naval Research Laboratory, Washington D.C.

if(nargin<4||isempty(lambda))
   lambda=0; 
end

%Clip negative values to zero to ensure convergence.
x(x<0)=0;

if(lambda == 0) % Central gamma case
    val=x.^(k-1).*exp(-x/theta)/(theta^k*gamma(k));
else
    if(nargin<6||isempty(maxIter))
        maxIter = 5000;
    end
    
    if(nargin<5||isempty(errTol))
        errTol = eps(1);
    end
    
    x = x/theta;
    m = ceil(lambda);
    a = k+m;
    gx = x.^a.*exp(-x)./gamma(a+1)/theta; % Calculate i=m term
    gxp = gx*a./x;
    gxp(x==0) = 0;
    gxr = gxp;
    pp = exp(-lambda)*lambda.^(m)./gamma(m+1); % i=m Poisson weight
    pr = pp;
    remain = 1-pp;
    ii = 1;
    g = pp*gxp;

    while(1)
        gxp = gxp.*x./(a+ii-1); % calculate progressive iteration
        pp = pp*lambda/(m+ii);
        g = g + pp*gxp;
        err = g*remain;
        remain = remain - pp;
        if(ii > m)
            if(max(err)<errTol || ii>maxIter)
                break
            end
        else
            gxr = gxr.*(a-ii)./x; % calculate regressive iteration
            pr = pr*(m-ii+1)/lambda;
            g = g+ pr*gxr;
            remain = remain - pr;
            if(remain<errTol || ii>maxIter)
                break
            end
        end
        ii = ii+1;
    end
    val = g; % convergence achieved
end
end

function prob=CDF(x,k,theta,lambda,errTol,maxIter)
%%CDF      Evaluate the cumulative distribution function of the
%          noncentral gamma distribution at desired points.
%
%INPUTS:       x   The point(s) at which the noncentral gamma CDF is 
%                  to be evaluated. Note that x>=0.
%              k   The shape parameter of the distribution; k>0.
%            theta The scale parameter of the distribution; theta>0.
%           lambda  The noncentrality parameter of the distribution. If
%                   this parameter is omitted or an empty matrix is passed,
%                   a value of 0, indicating the central gamma
%                   distribution, is used.
%           errTol  Error tolerance for determining convergence of the
%                   algorithm whem lambda~=0. If this parameter is omitted
%                   or an empty matrix is passed, the default of eps(1) is
%                   used.
%           maxIter The maximum number of iterations to allow. This is only
%                   used matters when lambda~=0. If this parameter is
%                   omitted or an empty matrix is passed, then a default
%                   value of 5000 is used.
%
%OUTPUTS:   prob The value(s) of the CDF of the noncentral gamma
%                distribution with parameters k and theta evaluated
%                at x.
%
%This is an implementation of the distribution computations from [1]. The
%work in [1] concerns algorithms that implement the distribution
%approximations in [2]. This function implements the algorithm for
%computation of the cumulative distribution function. When lambda is zero,
%the central gamma case, a simple explicit formula is available.
%
%REFERENCES:
%[1] I.R.C. de Oliveria and D.F. Ferreira, "Computing the noncentral gamma
%    distribution, its inverse and the noncentrality parameter," 
%    Computational Statistics, vol. 28, no. 4, pp.1663-1680, 01 Aug 2013.
%[2] L. Kn�sel and B. Bablok, "Computation of the noncentral gamma
%    distribution," SIAM Journal on Scientific Computing, vol. 17, no. 5,
%    pp.1224-1231, Sep. 1996.
%
%December 2014 David A. Karnick, Naval Research Laboratory, Washington D.C.

if(nargin<4||isempty(lambda))
   lambda=0; 
end

%Clip negative values to zero to ensure convergence.
x(x<0)=0;

if(lambda == 0)% Central gamma case
    prob=gammainc(x/theta,k);
else
    if(nargin<6||isempty(maxIter))
        maxIter = 5000;
    end
    
    if(nargin<5||isempty(errTol))
        errTol = eps(1);
    end
    
    x = x/theta;
    m = ceil(lambda);
    a = k+m;
    gammap = gammainc(x,a);
    gammar = gammap;
    gxr = x.^a.*exp(-x)./gamma(a+1)/theta; % Calculate i=m term
    gxp = gxr*a./x;
    gxp(x==0) = 0;
    pp = exp(-lambda)*lambda.^(m)./gamma(m+1); %i=m Poisson weight
    pr = pp;
    remain = 1-pp;
    ii = 1;
    cdf = pp*gammap;

    while(1)
        gxp = gxp.*x./(a+ii-1); %Calculate progressive iteration
        gammap = gammap-gxp;
        pp = pp*lambda/(m+ii);
        cdf = cdf + pp*gammap;
        err = remain*gammap;
        remain = remain - pp;
        if(ii > m)
            if max(err)<errTol || ii>maxIter
                break
            end
        else
            gxr = gxr.*(a-ii)./x; %Calculate regressive iteration
            gammar = gammar + gxr;
            pr = pr*(m-ii+1)/lambda;
            cdf = cdf + pr*gammar;
            remain = remain - pr;
            if remain<errTol || ii>maxIter
                break
            end
        end
        ii = ii+1;
    end
    prob = cdf; %Convergence achieved
end
end

function val=invCDF(prob,k,theta,lambda)
%%INVCDF      Evaluate the inverse of the cumulative distribution
%             function of the gamma distribution.
%
%INPUTS:       prob The probability or probabilities (0<=prob<=1) at which the 
%                   argument of the CDF is desired.
%              k    The shape parameter of the distribution; k>0.
%             theta The scale parameter of the distribution; theta>0.
%           lambda  The noncentrality parameter of the distribution. If
%                   this parameter is omitted or an empty matrix is passed,
%                   a value of 0, indicating the central gamma
%                   distribution, is used.
%
%OUTPUTS:   val  The argument(s) of the CDF that would give the probability
%                or probabilities in prob.
%
%The CDF of the gamma distribution can be expressed in terms of the
%incomplete gamma function as described in [1]. The inverse incomplete
%gamma function is built into Matlab without the use of any toolboxes and
%thus is called here.
%
%Currently, no implementation for the case of a nonzero noncentrality
%parameter is provided.
%
%REFERENCES:
%[1] Weisstein, Eric W. "Gamma Distribution." From MathWorld--A Wolfram Web
%    Resource. http://mathworld.wolfram.com/GammaDistribution.html
%
%September 2013 David F. Crouse, Naval Research Laboratory, Washington D.C.

if(nargin<4||isempty(lambda))
   lambda=0; 
end

if(lambda == 0)
    val=theta*gammaincinv(prob,k);
else
    error('This function is not currently supported for noncentral gamma distribution');
end
end

function vals=rand(N,k,theta,lambda)
%%RAND       Generate gamma distributed random variables with the given
%            parameters.
%
%INPUTS:    N      If N is a scalar, then rand returns an NXN matrix
%                  of random variables. If N=[M,N1] is a two-element row 
%                  vector, then rand returns an MXN1 matrix of random
%                  variables.
%           k      The shape parameter of the distribution; k>0.
%           theta  The scale parameter of the distribution; theta>0.
%          lambda  The noncentrality parameter of the distribution. If
%                   this parameter is omitted or an empty matrix is passed,
%                   a value of 0, indicating the central gamma
%                   distribution, is used.
%
%OUTPUTS:   vals   A matrix whose dimensions are determined by N of the
%                  generated gamma random variables.
%
%This is an implementation of the inverse transform algorithm of Chapter
%5.1 of [1].
%
%Currently, no implementation for the case of a nonzero noncentrality
%parameter is provided.
%
%REFERENCES:
%[1] S. H. Ross, Simulation, Ed. 4, Amsterdam: Elsevier, 2006.
%
%September 2013 David F. Crouse, Naval Research Laboratory, Washington D.C.

if(nargin<4||isempty(lambda))
    lambda=0;
end

if(lambda == 0)
    if(isscalar(N))
        dims=[N, N];
    else
        dims=N;
    end
    
    U=rand(dims);
    
    vals=GammaD.invCDF(U,k,theta);
else
    error('This function is not currently supported for noncentral gamma distribution');
end
end
    
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
