%======================================================== 
%   Name: usample.m 
%   ���ܣ������� 
%   ���룺����ͼƬ I, ������ϵ��N 
%   ������������ͼƬIdown 
%   author:gengjiwen    date:2015/5/10 
%======================================================== 
function Iup = usample(I,N) 
[row,col] = size(I); 
upcol = col*N; 
upcolnum = upcol - col; 
uprow = row*N; 
uprownum = uprow -row; 

If = fft(fft(I)')';     %fft2�任 
Ifrow = [If(:,1:col/2) zeros(row,upcolnum) If(:,col/2 +1:col)];   %ˮƽ�����м���� 
                                                                                                   %����֮��IfrowΪ row*upcol                                                                
Ifcol = [Ifrow(1:row/2,:);zeros(uprownum,upcol);Ifrow(row/2 +1:row,:)];   %��ֱ������ 
Iup = ifft2(Ifcol); 
end 