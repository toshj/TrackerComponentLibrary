function points=Cart2Sphere(cartPoints,systemType,useHalfRange,zTx,zRx,M)
%%CART2SPHERE Convert Cartesian coordinates to spherical coordinates.
%             An option allows for the angles to be specified from
%             different axes. Optionally, a bistatic range can be used when
%             considering bistatic measurements in a local spherical
%             coordinate system.
%
%INPUTS: cartPoints A matrix of the points in Cartesian coordinates that
%                   are to be transformed into spherical coordinates. Each
%                   columns of cartPoints is of the format [x;y;z].
%        systemType An optional parameter specifying the axes from which
%                   the angles are measured. Possible values are
%                   0 (The default if omitted) Azimuth is measured
%                     counterclockwise from the x-axis in the x-y plane.
%                     Elevation is measured up from the x-y plane (towards
%                     the z-axis). This is consistent with common spherical
%                     coordinate systems for specifying longitude (azimuth)
%                     and geocentric latitude (elevation).
%                   1 Azimuth is measured counterclockwise from the z-axis
%                     in the z-x plane. Elevation is measured up from the
%                     z-x plane (towards the y-axis). This is consistent
%                     with some spherical coordinate systems that use the z
%                     axis as the boresight direction of the radar.
%useHalfRange A boolean value specifying whether the bistatic range
%           value should be divided by two. This normally comes up when
%           operating in monostatic mode (the most common type of spherical
%           coordinate system), so that the range reported is a
%           one-way range. The default if this parameter is not provided is
%           true.
%       zTx The 3XN [x;y;z] location vectors of the transmitters in global
%           Cartesian coordinates. If this parameter is omitted, then the
%           transmitters are assumed to be at the origin. If only a single
%           vector is passed, then the transmitter location is assumed the
%           same for all of the target states being converted. zTx can have
%           more than 3 rows; additional rows are ignored.
%       zRx The 3X1 [x;y;z] location vector of the receiver in Cartesian
%           coordinates.  If this parameter is omitted, then the
%           receivers are assumed to be at the origin. If only a single
%           vector is passed, then the receiver location is assumed the
%           same for all of the target states being converted. zRx can have
%           more than 3 rows; additional rows are ignored.
%        M  A 3X3XN hypermatrix of the rotation matrices to go from the
%           alignment of the global coordinate system to that at the
%           receiver. The z-axis of the local coordinate system of the
%           receiver is the pointing direction of the receiver. If omitted,
%           then it is assumed that the local coordinate system is aligned
%           with the global and M=eye(3) --the identity matrix is used. If
%           only a single 3X3 matrix is passed, then is is assumed to be
%           the same for all of the N conversions.
%
%OUTPUTS:   points  A matrix of the converted points. Each column of the
%                   matrix has the format [r;azimuth;elevation],
%                   with azimuth and elevation given in radians.
%
%The conversion from Cartesian to spherical coordinates is given in Chapter
%14.4.4.2 of [1]. Modifications have been made to deal with local, bistatic
%conversions.
%
%REFERENCES:
%[1] R. L. Duncombe, "Computational techniques," in Explanatory Supplement
%    to the Astronomical Almanac, 3rd ed., S. E. Urban and P. K.
%    Seidelmann, Eds. Mill Valley, CA: University Science Books, 2013,
%
%July 2014 David F. Crouse, Naval Research Laboratory, Washington D.C.
%(UNCLASSIFIED) DISTRIBUTION STATEMENT A. Approved for public release.

if(nargin<2)
    systemType=0;
end

%If a simple, standard spherical coordinate system conversion can be used.
if(nargin<3)
    %Extract the coordinates
    x=cartPoints(1,:);
    y=cartPoints(2,:);
    z=cartPoints(3,:);

    r=sqrt(x.^2+y.^2+z.^2);
    switch(systemType)
        case 0
            azimuth=atan2(y,x);
            elevation=asin(z./r);
        case 1
            azimuth=atan2(x,z);
            elevation=asin(y./r);
        otherwise
            error('Invalid system type specified')
    end
    points=[r;azimuth;elevation];
    return;
end

N=size(cartPoints,2);

%If any type of bistatic range thing is done.
if(nargin<6)
    M=repmat(eye(3),[1,1,N]);
elseif(size(M,3)==1)
    M=repmat(M,[1,1,N]);
end

if(nargin<5)
    zRx=zeros(3,N);
elseif(size(zRx,2)==1)
    zRx=repmat(zRx,[1,N]);
end

if(nargin<4)
    zTx=zeros(3,N);
elseif(size(zTx,2)==1)
    zTx=repmat(zTx,[1,N]);
end

%Allocate space for the return values.
points=zeros(3,N);
for curPoint=1:N
    %The target location in the receiver's coordinate system.
    zCL=M(:,:,curPoint)*(cartPoints(:,curPoint)-zRx(:,curPoint));
    %The transmitter location in the receiver's local coordinate system.
    zTxL=M(:,:,curPoint)*(zTx(:,curPoint)-zRx(:,curPoint));

%Perform the conversion.
    r1=norm(zCL);%Receiver to target.
    r2=norm(zCL-zTxL);%Target to transmitter.
    r=r1+r2;
    
    x=zCL(1);
    y=zCL(2);
    z=zCL(3);
    
    switch(systemType)
        case 0
            azimuth=atan2(y,x);
            elevation=asin(z./r1);
        case 1
            azimuth=atan2(x,z);
            elevation=asin(y./r1);
        otherwise
            error('Invalid system type specified')
    end

    points(:,curPoint)=[r;azimuth;elevation];
end

if(useHalfRange)
    points(1,:)=points(1,:)/2;
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
