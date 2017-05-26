% ------------------------------------
% ����ֱ��ͼ���Ҳü��ĻҶ�ֵ
% 2015/07/01
%
% Input    histcount --> ֱ��ͼ
%          tt        --> ͼ�����ظ���
%          per       --> ���Ҳü��İٷֱ�
% 
% Output   l_val     --> ��ֵ
%          r_val     --> ��ֵ
% ------------------------------------

function [l_val, r_val] = cal_lr_val(histcount, tt, per)
    per_tt = tt*per;  % ���ٷֱȲü������ظ��� 

    % ������ֵ
    tmp = 0;
    for i = 1:length(histcount)
        tmp = tmp + histcount(i);
        if tmp >= per_tt
            l_val = i;
            break;
        end
    end
    % ������ֵ
    tmp = 0;
    for i = 1:length(histcount)
        tmp = tmp + histcount(length(histcount)-i+1);
        if tmp >= per_tt
            r_val = length(histcount)-i+1;
            break;
        end
    end

end