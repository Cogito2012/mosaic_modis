% ------------------------------------
% 计算直方图左右裁剪的灰度值
% 2015/07/01
%
% Input    histcount --> 直方图
%          tt        --> 图像像素个数
%          per       --> 左右裁剪的百分比
% 
% Output   l_val     --> 左值
%          r_val     --> 右值
% ------------------------------------

function [l_val, r_val] = cal_lr_val(histcount, tt, per)
    per_tt = tt*per;  % 按百分比裁剪的像素个数 

    % 计算左值
    tmp = 0;
    for i = 1:length(histcount)
        tmp = tmp + histcount(i);
        if tmp >= per_tt
            l_val = i;
            break;
        end
    end
    % 计算右值
    tmp = 0;
    for i = 1:length(histcount)
        tmp = tmp + histcount(length(histcount)-i+1);
        if tmp >= per_tt
            r_val = length(histcount)-i+1;
            break;
        end
    end

end