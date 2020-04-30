clear all; clc;
load('VictoriaPark2.mat');
load('pose.mat');
% VP data
x0  = [gps(1,1) gps(2,1) 35.5*pi/180]';
pose    = [x0,pose];
for i = 1:length(ut)
    ut(i)   = control_rel(pose(:,i+1), pose(:,i));
end

save VP gps timeGps timeUt timeZt ut zt x0
%% Sequentialize data of motion and measurement
idx_odo     = 1; % idx of last control sequence in original odometry data
Data        = []; % sequence data contents measurements and odometry controls
% Loop over the laser measurement
for i = 2:length(timeZt)
    % if is odometry data: append odometry conmmand
    idx_pre = idx_odo;
    is_moved = false;
    while timeUt(idx_odo) < timeZt(i)
        is_moved = true;
        idx_odo = idx_odo + 1;
    end
    % control from idx_pre to idx_odo
    Data(end+1).odometry   = control_rel(pose(:,idx_pre),pose(:,idx_odo));
    
    % if is sensor data: append measurements
    if is_moved
        Data(end).sensors   = zt(i).sensor;
    else
        Data(end).sensors   = [Data(end).sensors, zt(i).sensor];
    end
end

save VP_SEQ gps Data x0

function u = control_rel(p1,p2)
    dx      = p2(1) - p1(1);
    dy      = p2(2) - p1(2);
    dtheta  = p2(3) - p1(3);
    u.t     = sqrt(dx^2+dy^2);
    u.r1    = atan2(dy,dx) - p1(3);
    u.r2    = dtheta - u.r1;
end