% ------------------------------------
% ��ͼ��ӳ���� [0, 255] ���
% 2015/07/01
%
% Input    img_16bit  --> 16λԭͼ��
%          l_val      --> ӳ����ֵ
%          r_val      --> ӳ����ֵ
% 
% Output   img_8bit   --> ���8λ�����ͼ��
% ------------------------------------

function [img_8bit] = img_map(img_16bit, l_val, r_val)

    [xlen, ylen, c] = size(img_16bit);
    img_8bit = zeros(xlen, ylen);
    
    img_8bit = (img_16bit - l_val).*(255/(r_val-l_val));
    img_8bit = uint8(round(img_8bit));
    
end