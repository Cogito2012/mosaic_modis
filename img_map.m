% ------------------------------------
% 将图像映射至 [0, 255] 区间
% 2015/07/01
%
% Input    img_16bit  --> 16位原图像
%          l_val      --> 映射左值
%          r_val      --> 映射右值
% 
% Output   img_8bit   --> 输出8位拉伸后图像
% ------------------------------------

function [img_8bit] = img_map(img_16bit, l_val, r_val)

    [xlen, ylen, c] = size(img_16bit);
    img_8bit = zeros(xlen, ylen);
    % 按照左右值映射
    img_8bit = (img_16bit - l_val).*(255/(r_val-l_val));
    img_8bit = uint8(round(img_8bit));
    
end