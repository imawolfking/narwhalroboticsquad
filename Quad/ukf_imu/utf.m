function [y,Y,P,Y1]=utf(f,gyro,dT,X,Wm,Wc,n,R)
%Unscented Transformation custom for the IMU
%Input:
%        f: nonlinear map
%        gyro: gyroscope inputs for the current measurement
%        dT: time
%        X: sigma points
%       Wm: weights for mean
%       Wc: weights for covraiance
%        n: numer of outputs of f
%        R: additive covariance
%Output:
%        y: transformed mean
%        Y: transformed smapling points
%        P: transformed covariance
%       Y1: transformed deviations

L=size(X,2);
y=zeros(n,1);
Y=zeros(n,L);
for k=1:L                   
    Y(:,k)=f(X(:,k), gyro, dT);       
    y=y+Wm(k)*Y(:,k);       
end
Y1=Y-y(:,ones(1,L));
P=Y1*diag(Wc)*Y1'+R;          
