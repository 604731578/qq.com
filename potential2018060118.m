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


% ���z��Q��
% [deg]
VIRTUAL_ANGLE = transpose(360 / 512 * 299 : 360 / 512 : 330);
% [mm] ---------------------------------------------------- �v����
VIRTUAL_DISTANCE = ones(171, 1) * 800;
%
VIRTUAL_LENGTH = 171;

% �p���p  �� / 2 {rad]
th = 1.570796326794897;
% �z�C�[���x�[�X [mm]
L = 256;
% �ԑ� [mm / s]
u1 = 200;
% �� [s] ---------------------------------------------------- �v����
ramda = 0.28;

% �|�e���V���� �͂̎����ő����Z
% �͂�x����
f_x = 0;
% �͂�y����
f_y = 0;
for n = 1 : LRS_LENGTH
    % �傫�� 1 / r ^ 2 �Ȃ�͂�x����
    f_x = f_x + cosd(LRS_ANGLE(n, 1)) / LRS_DISTANCE(n, 1) ^ 2;
    % �傫�� 1 / r ^ 2 �Ȃ�͂�y����
    f_y = f_y + sind(LRS_ANGLE(n, 1)) / LRS_DISTANCE(n, 1) ^ 2;
end
% ���z��Q��
for n = 1 : VIRTUAL_LENGTH
    % 1 / r ^ 2 �Ȃ�͂�x����
    f_x = f_x +cosd(VIRTUAL_ANGLE(n, 1)) / VIRTUAL_DISTANCE(n, 1) ^ 2;
    % 1 / r ^ 2 �Ȃ�͂�y����
    f_y = f_y + sind(VIRTUAL_ANGLE(n, 1)) / VIRTUAL_DISTANCE(n, 1) ^ 2;
end

% �ڕW�p���p �͂̌����@-�� <= th_r <= ��
th_r = atan2(f_y , f_x);
% 0 <= th_r < 2��
if  f_y < 0
    th_r = th_r + 2 * pi;
end

% ���Ǌp
u2 = atand(L * ramda / u1 * (th_r - th));
% �O�a����
if u2 > 30
    u2 = 30;
end
if u2 < -30
    u2 = -30;
end

% ���Ǌp ���̔��] [deg]
S = -u2;
% �ԑ� [mm / s]
V = u1;
