gyrocali500 = [ 1712.28081457663;
                1713.6270096463;
                1694.57984994641];
            
            
MagCMatrix = [0   0   1
              -1  0   0
              0  -1   0];
          
AccCMatrix = [      0.23933403823395     1.46867629666629e-003     4.33093040252392e-003
     4.04103062991867e-007       0.238449747339358     4.12450720183918e-003
     1.19164600479841e-006     1.13796862612132e-006       0.242992389982905];
                     
AccMMatrix = [      2064.5
           2065.22463768116
          2094.03181535501];

MagMMatrix =   [ 61.2028060156999;
         -228.808994316973;
         -124.605589956184];


 
%SERIAL PORT
s1 = serial('com10');    % define serial port
s1.BaudRate=115200;               % define baud rate
set(s1, 'terminator', 'LF');    % define the terminator for println
fopen(s1);
%END SERIAL PORT

deg2rad = 0.0174532925;
iteration = 1;
                         
                             
 t0 = clock;

 
% SET PROCESS VAR

% predicted estimate covariance
P = [0, 0, 0, 0, 0, 0, 0;
     0, 0, 0, 0, 0, 0, 0;
     0, 0, 0, 0, 0, 0, 0;
     0, 0, 0, 0, 0, 0, 0;
     0, 0, 0, 0, 0.2, 0, 0; 
     0, 0, 0, 0, 0, 0.2, 0;
     0, 0, 0, 0, 0, 0, 0.2];
 
% Innovation (or residual) covariance

Q = [0.000001, 0, 0, 0, 0, 0, 0;
     0, 0.000001, 0, 0, 0, 0, 0;
     0, 0, 0.000001, 0, 0, 0, 0;
     0, 0, 0, 0.000001, 0, 0, 0;
     0, 0, 0, 0, 0.000001, 0, 0; 
     0, 0, 0, 0, 0, 0.000001, 0;
     0, 0, 0, 0, 0, 0, 0.000001];

Racc = [0.6, 0, 0;
       0, 0.6, 0;
       0, 0, 0.6];
   
% magnetometer covariance matrix
Rmag = [0.3, 0, 0;
       0, 0.3, 0;
       0, 0, 0.3];
   
   
% Quaternion matrix
state = [1 0 0 0 0 0 0]';

 u=udp('127.0.0.1',9091);
 fopen(u);
 
 %generate refererence magnetomer vector
 ae = [    0.0159302245853403
       0.00680186846843273
         0.999849970010501];
 me = [  -0.309834153107078
         0.942336159900768
         0.126512289173404];
 
 sh1 = ae;
 sh2 = cross(ae,me)/norm(cross(ae,me));
 sh3 = cross(sh1, sh2);
 z=[0;0;0];
 while(true)
  
    dT = etime(clock,t0);
    t0 = clock;
   
  w=fscanf(s1, '%d %d %d %d %d %d %d %d %d');              % must define the input % d or %s, etc. 
  
   [c r] = size(w); 
    
   if c ~= 9 
       continue; 
   end
    Acc =  [w(5);
           w(3);
            w(1)];
  
  % Acc = Acc/norm(double(Acc))
    AccCalibrate = (Acc - AccMMatrix);
   %AccCalibrate = AccCMatrix * (Acc - AccMMatrix);
   AccNorm = (AccCalibrate/norm(AccCalibrate))
    
 
   
    
%     acc_x = Acc(1); 
%     acc_y = Acc(2);
%     acc_z = Acc(3);
%     
%     AccNorm = [acc_x;
%                acc_y;
%                acc_z];
    %gyro data - this case is 9.1mV/degree, we are at 3.3V, 1024 steps,
    %each step is 3300/1024 = 3.22265625mV/step -> 0.354138049 degree/step
   
    %correct gyro with reference (need temp correction here), multiply by
    %step to get degrees, and then multiply by rad
    Gyro = ([w(4); w(5); w(6)] - gyrocali500) * 1/(14.375) * deg2rad;
    gyro_x = Gyro(1);
    gyro_y = Gyro(2);
    gyro_z = Gyro(3);
    
  
    %calibrate the magnetomer mesasurement
    Mag = [w(7);
           w(8);
           w(9)];

   
       
    MagCalibrate = MagCMatrix * (Mag - MagMMatrix);
    MagNorm = (MagCalibrate/norm(MagCalibrate));
  
  
    %AccNorm

   
    %z = MagNorm+z;
    %z/iteration
    
    % PREDICTION
    
%     q0 = state(1);
%     q1 = state(2);
%     q2 = state(3);
%     q3 = state(4);
%     g4 = state(5);
%     g5 = state(6);
%     g6 = state(7);
%     %Gyro Rotation into quatarion matrix    
%     %state equation
%     q0 = q0 + (-1/2 * gyro_x * q1 - 1/2 * gyro_y * q2 - 1/2 * gyro_z * q3) * dT;
%     q1 = q1 + (1/2 * gyro_x * q0 - 1/2 * gyro_y * q3 + 1/2 * gyro_z * q2) * dT;
%     q2 = q2 + (1/2 * gyro_x * q3 + 1/2 * gyro_y * q0 - 1/2 * gyro_z * q1) * dT;
%     q3 = q3 + (-1/2 * gyro_x * q2 + 1/2 * gyro_y * q1 + 1/2 * gyro_z * q0) * dT;
%     g4 = g4 + 0;
%     g5 = g5 + 0;
%     g6 = g6 + 0;
%     %xk: state quaternion
%     %quaternion = quatnormalize([q0 q1 q2 q3])
%     
%     quaternion = quatnormalize([q0 q1 q2 q3]);
%     
%     state(1:4) = quaternion;
%     state(5:7) = [g4, g5, g6];
%    
%     %assemble jacobian matrix
%     F = [1,         -1/2*gyro_x*dT, -1/2*gyro_y*dT, -1/2*gyro_z*dT,  1/2*q1*dT,  1/2*q2*dT,  1/2*q3*dT;
%          1/2*gyro_x*dT,  1,          1/2*gyro_z*dT, -1/2*gyro_y*dT, -1/2*q0*dT,  1/2*q3*dT, -1/2*q2*dT;
%          1/2*gyro_y*dT, -1/2*gyro_z*dT,  1,          1/2*gyro_x*dT,  1/2*q3*dT, -1/2*q0*dT,  1/2*q1*dT;
%          1/2*gyro_z*dT,  1/2*gyro_y*dT, -1/2*gyro_x*dT,  1,          1/2*q2*dT, -1/2*q1*dT, -1/2*q0*dT;
%          0,          0,          0,          0,          1,          0,          0        ;
%          0,          0,          0,          0,          0,          1,          0        ;
%          0,          0,          0,          0,          0,          0,          1        ];
%      
%      % predict covariance matrix from the last one
%     P = F*P*(F') + Q;
%     
%     
%    %% CORRECTION
%     % normalized accelerometer measurement matrix
%      Zm = [acc_x; 
%            acc_y;
%            acc_z];
% 
%     % predicted z-earth vector - MACRO
%    Ze = [2*(q1*q3 - q0*q2);
%          2*(q2*q3 + q0*q1);
%          1 - 2*(q1*q1 + q2*q2)];
% 
%     % roll-pitch estimation error
%     Epr = Zm - Ze;
%   
%     %roll-pitch observation matrix -MACRO
%     Hpr = [-2*q2,   2*q3,   -2*q0,  2*q1,   0,  0,  0;
%             2*q1,   2*q0,    2*q3,  2*q2,   0,  0,  0;
%             0,      -4*q1,  -4*q2,  0,      0,  0,  0];
%          
%     % roll-pitch estimation error covariance matrix
%     Ppr = Hpr * P * (Hpr') + Racc;
%     
%     % roll-pitch kalman gain
%     Kpr = P * (Hpr') / Ppr;
%     
%     % update system state
%     state = state + Kpr*Epr;
%     
%     % update system state covariance matrix
%     P = P - Kpr * Hpr * P;
%     
%     AccNorm = [2*(q1*q3 - q0*q2);
%          2*(q2*q3 + q0*q1);
%          1 - 2*(q1*q1 + q2*q2)];
    
     r1 = AccNorm;
     r2 = cross(AccNorm,MagNorm)/norm(cross(AccNorm,MagNorm));
     r3 = cross(r1, r2);
    
     mm = [r1,r2,r3];
     mr = [sh1,sh2, sh3];
     ma = (mm*mr');
    
    %% magnetometer updates
    % compute predicted X body over ground in earth xy plane using the
    % already filtered quaternion
%     q0 = state(1);
%     q1 = state(2);
%     q2 = state(3);
%     q3 = state(4);
%     
%     Xog = [1-2*(q2*q2 + q3*q3);
%            2*(q1*q2 - q0*q3);
%            2*(q0*q2 + q1*q3)];
%        
%     %VERmag INTERSTING...
%     Xogmag = [ma(1,1); ma(2,1); ma(3,1)];
%     
%     Ey = Xogmag - Xog;
%     
%     Hy = [    0,     0, -4*q2, -4*q3, 0, 0, 0;
%             -2*q3,    2*q2,    2*q1,   -2*q0, 0, 0, 0;
%           	  2*q2, 2*q3, 2*q0,     2*q1, 0, 0, 0];
%     
%     % yaw estimation error covariance matrix
%     Py = Hy * P * (Hy') + Rmag;
%     
%     % yaw kalman gain
%     Ky = P * (Hy') / Py;
%     
%     % update the system state
%     state = state + Ky * Ey;
%     
%     % update system state covariance matrix
%     P = P - Ky*Hy*P;
    
    %% END MAGNETOMETER
    %end kalman
    
    
    
    % FOR PYTHON PLOTTING
    state(1:4)';
    %dcm = quat2dcm(state(1:4)');
    dcm=ma;
   %[ dcm2quat(ma);state(1:4)']'
  
    %[r1 r2 r3] = (quat2angle(state(1:4)'));
     [r1 r2 r3] = dcm2angle(dcm);
     [r1;r2;r3]*(1/deg2rad)
    
    dcmstr =  [num2str(dcm(1,1), '%10.6f') ' '  num2str(dcm(1,2), '%10.6f') ' '  num2str(dcm(1,3), '%10.6f') ' ' num2str(dcm(2,1), '%10.6f') ' '  num2str(dcm(2,2), '%10.6f') ' '  num2str(dcm(2,3), '%10.6f') ' ' num2str(dcm(3,1), '%10.6f') ' '  num2str(dcm(3,2), '%10.6f') ' ' num2str(dcm(3,3), '%10.6f')];
    
%    dcmstr =  [num2str(state(1), '%10.6f') ' '  num2str(state(2), '%10.6f') ' '  num2str(state(3), '%10.6f') ' ' num2str(state(4), '%10.6f')] 
   
    %state1 = int16(state(1:4) * 10000)
    
   % fwrite(u, state1,'int16');
    
    fwrite(u, dcmstr);
    
    
    %%
    iteration = iteration + 1;
  
end
fclose(u);
