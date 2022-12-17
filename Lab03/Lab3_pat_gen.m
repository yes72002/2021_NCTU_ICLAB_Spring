%##########################################################################
%   (C) Copyright Yuan-Jin Li yes72002@gmail.com
%   2021 ICLAB Spring Course
%   Lab03   : Sudoku(SD) 
%   Author  : Yuan-Jin Li 
%   Date    : 2021.03.19
%##########################################################################
clear
close all
clc



original = randi([1 9],9,9);
original_position = [(1:9); (10:18); (19:27); (28:36); (37:45); (46:54); (55:63); (64:72); (73:81)]';
verilog_position = [(1:9); (10:18); (19:27); (28:36); (37:45); (46:54); (55:63); (64:72); (73:81)] - 1;
sub = [0 3 6 27 30 33 54 57 60]';
verilog_position_sub = [sub sub+1 sub+2 sub+9 sub+10 sub+11 sub+18 sub+19 sub+20 ];
blank = randperm(81); % no repeat
blank_15 = blank(1:15);
nine = zeros(1,15) + 9;
blank_row = floor(blank_15./nine);
blank_col = blank_15 - 9*blank_row;
input =  original;
for i=1:15
    input(blank_15(i)) = 0;
end
Address_input = ' C:\Users\Jim\OneDrive - nctu.edu.tw\NCTU\Course\Master2-2-Integrated Circuit Design Laboratory\Lab03\xxxiclab041xxx.txt';
% Address_input = 'C:\Users\henry\OneDrive - nctu.edu.tw\NCTU\Course\Master2-2-Integrated Circuit Design Laboratory\Lab03\xxxiclab041xxx.txt';
txt_in = fopen(Address_input, 'w');

c = 1;%生成数独数量
fprintf(txt_in, '%d\r\n', c + 1);
fprintf(txt_in, '\r\n');

% fprintf(txt_in, '%d %d %d %d %d %d %d %d %d \r\n', input(1:9:73));
for i=1:9
    fprintf(txt_in, '%d %d %d %d %d %d %d %d %d\r\n', input(i:9:72+i));
end
fprintf(txt_in, '\r\n');
fprintf(txt_in, '1 10\r\n');
fprintf(txt_in, '\r\n');

% https://blog.csdn.net/qq_44624573/article/details/106698461
num = zeros(1,c);%生成一个数独的的循环次数
shudu = zeros(9,9,c);
for k = 1:c    
    num(1,k) = 0;       
    while(sum(sum(shudu(:,:,k)))~=405)                
        A = zeros(9,9);       
        a = (1:9);       
        b = randperm(9);        
        A(1,:) = b;        
        for i = 2:9            
            for j = 1:9                
                x = A(i,:);               
                y = A(:,j);                
                if 0<j && j<4                    
                   z = A(:,1:3);                
                else if 3<j && j<7                        
                        z = A(:,4:6);                    
                     else                         
                        z = A(:,7:9);                    
                     end               
                end                
                if 0<i && i<4                    
                   z = z(1:3,:);                
                else if 3<i && i<7                        
                        z = z(4:6,:);                    
                     else                         
                        z = z(7:9,:);                    
                     end               
                end               
                X = x(x~=0);                
                Y = y(y~=0);                
                Z = z(z~=0);                
                t = union(X,Y);                
                t = union(t,Z);                
                n = setxor(t,a);                
                L = length(n);                
                r = rand(1);                
                h = ceil(r*L);                
                if h == 0                    
                   num(1,k) = num(1,k)+1;                    
                   break               
                end               
                A(i,j) = n(h);            
             end           
             if A(i,j) == 0                
                break            
             end       
          end        
          shudu(:,:,k) = A;    
       end   
       shudu(:,:,k); % display
       blank = randperm(81); % no repeat
        blank_15 = blank(1:15);
        blank_s15 = sort(blank_15);
        for j = 1:15
            AA(j) =  A(blank_s15(j));
            A(blank_s15(j)) = 0;
        end
        B = A';
        for i=1:9
            fprintf(txt_in, '%d %d %d %d %d %d %d %d %d\r\n', B(i:9:72+i));
        end
        fprintf(txt_in, '\r\n');
        fprintf(txt_in, '15 %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d\r\n',AA);
        fprintf(txt_in, '\r\n');
end
b = 3;%设置难度，一行中随机挖掉几个数
A;%完整的数独九宫格
% A'
% blank_s15 = sort(blank_15);
% for j = 1:15
%     AA(j) =  A(blank_s15(j));
%     A(blank_s15(j)) = 0;
% end
% B = A';
% for i=1:9
%     fprintf(txt_in, '%d %d %d %d %d %d %d %d %d\r\n', B(i:9:72+i));
% end
% fprintf(txt_in, '\r\n');
% fprintf(txt_in, '15 %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d\r\n',AA);
% fprintf(txt_in, '\r\n');
% B
fclose(txt_in);





