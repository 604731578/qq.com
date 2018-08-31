function [V, S] = potential(V, S, robocar_V, robocar_S, LRS_angle, LRS_distance)

% LRS_angle [deg]
LRS_ANGLE = LRS_angle + 90;
% LRS_distance [mm]
LRS_DISTANCE = LRS_distance;
% LRS_length
LRS_LENGTH = 341;


persistent FileName;
if isempty(FileName)
    FileName = strcat(datestr(now, 'yyyymmddHHMM'), '.csv');
    
    fileID = fopen(FileName, 'w');
    fprintf(fileID, ', , , , LRS_ANGLE [deg], ');
    fclose(fileID);
    
    dlmwrite(FileName, transpose(LRS_ANGLE), '-append');
    
    fileID = fopen(FileName, 'a');
    fprintf(fileID, 'time, V [mm / s], S [deg], robocar_V [mm / s], robocar_S [deg], LRS_DISTANCE [mm]\n');
    fclose(fileID);
end

fileID = fopen(FileName, 'a');
fprintf(fileID, datestr(now, 'HH:MM:SS.FFF'));
fprintf(fileID, ', %f, %f, %f, %f, ', V, S, robocar_V, robocar_S);
fclose(fileID);

dlmwrite(FileName, transpose(LRS_DISTANCE), '-append');


% 仮想障害物
% [deg]
VIRTUAL_ANGLE = transpose(360 / 512 * 299 : 360 / 512 : 330);
% [mm] ---------------------------------------------------- 要調整
VIRTUAL_DISTANCE = ones(171, 1) * 800;
%
VIRTUAL_LENGTH = 171;

% 姿勢角  π / 2 {rad]
th = 1.570796326794897;
% ホイールベース [mm]
L = 256;
% 車速 [mm / s]
u1 = 200;
% λ [s] ---------------------------------------------------- 要調整
ramda = 0.28;

% ポテンシャル 力の次元で足し算
% 力のx成分
f_x = 0;
% 力のy成分
f_y = 0;
for n = 1 : LRS_LENGTH
    % 大きさ 1 / r ^ 2 なる力のx成分
    f_x = f_x + cosd(LRS_ANGLE(n, 1)) / LRS_DISTANCE(n, 1) ^ 2;
    % 大きさ 1 / r ^ 2 なる力のy成分
    f_y = f_y + sind(LRS_ANGLE(n, 1)) / LRS_DISTANCE(n, 1) ^ 2;
end
% 仮想障害物
for n = 1 : VIRTUAL_LENGTH
    % 1 / r ^ 2 なる力のx成分
    f_x = f_x +cosd(VIRTUAL_ANGLE(n, 1)) / VIRTUAL_DISTANCE(n, 1) ^ 2;
    % 1 / r ^ 2 なる力のy成分
    f_y = f_y + sind(VIRTUAL_ANGLE(n, 1)) / VIRTUAL_DISTANCE(n, 1) ^ 2;
end

% 目標姿勢角 力の向き　-π <= th_r <= π
th_r = atan2(f_y , f_x);
% 0 <= th_r < 2π
if  f_y < 0
    th_r = th_r + 2 * pi;
end

% 操舵角
u2 = atand(L * ramda / u1 * (th_r - th));
% 飽和処理
if u2 > 30
    u2 = 30;
end
if u2 < -30
    u2 = -30;
end

% 操舵角 軸の反転 [deg]
S = -u2;
% 車速 [mm / s]
V = u1;
