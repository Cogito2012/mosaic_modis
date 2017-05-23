%======================================================== 
%   Name: usample.m 
%   功能：升采样 
%   输入：采样图片 I, 升采样系数N 
%   输出：采样后的图片Idown 
%   author:gengjiwen    date:2015/5/10 
%======================================================== 
function Iup = usample(I,N) 
[row,col] = size(I); 
upcol = col*N; 
upcolnum = upcol - col; 
uprow = row*N; 
uprownum = uprow -row; 

If = fft(fft(I)')';     %fft2变换 
Ifrow = [If(:,1:col/2) zeros(row,upcolnum) If(:,col/2 +1:col)];   %水平方向中间插零 
                                                                                                   %补零之后，Ifrow为 row*upcol                                                                
Ifcol = [Ifrow(1:row/2,:);zeros(uprownum,upcol);Ifrow(row/2 +1:row,:)];   %垂直方向补零 
Iup = ifft2(Ifcol); 
end 