tic
clear  
clc  
% figure(1);
% subplot(1,1,1),imshow(GrayPic),title('gray');
trainfile='train.txt';
valfile='val.txt';
fp_t = fopen(trainfile,'wt');
fp_v = fopen(valfile,'wt');
name_train = 999;                    %用作训练样本的图片数+1，剩余的作为验证样本
Nm_all = 1499                        %总图片数+1
Nm_out = floor((Nm_all+1)/4);           %生成1/4的数目后打印提示
Nm_con = Nm_out;
for class = 0:5
    if class == 0
       im = imread('2_A.jpg');        %读取图片  
    elseif  class == 1
       im = imread('5_A.jpg');        %读取图片      
    elseif  class == 2
       im = imread('10_A.jpg');        %读取图片 
    elseif  class == 3
       im = imread('50_A.jpg');        %读取图片      
    elseif  class == 4
       im = imread('100_A.jpg');        %读取图片 
     elseif  class == 5
       im = imread('10_B.jpg');        %读取图片      
%      elseif  class == 6
%        im = imread('50_A.jpg');        %读取图片 
%      elseif  class == 7
%        im = imread('50_B.jpg');        %读取图片      
%     elseif  class == 8
%        im = imread('100_A.jpg');        %读取图片 
%      elseif  class == 9
%        im = imread('100_B.jpg');        %读取图片      
    end  
    
GrayPic = rgb2gray(im);              %转换为单通道的灰度图像
    
for name = 0:Nm_all                     %总共生成的图片
% matgraypic = mat2gray(im);
% MidGrayPic = uint8(matgraypic);
% [h w]=size(MidGrayPic);
% MidGrayPic2 = zeros(rows , cols);%用得到的参数创建一个全零的矩阵，这个矩阵用来存储用下面的方法产生的灰度图像    
% MidGrayPic2 = uint8(MidGrayPic2);%将创建的全零矩阵转化为uint8格式，因为用上面的语句创建之后图像是double型的  
%%%%%%%%%%%%%%%%%%%%%%%%随机参数生成%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Mtheta_1 = 100 + (240-1)*rand();     %随机高斯运动模糊角度
Mgas = 0.001 + 0.01*rand();          %随机高斯噪声
Msigma = 0.1 + 0.8*rand();           %随机高斯滤波参数
Mth_1 = 0.25 + 0.35*rand();            %随机改变灰度区间
Mth_2 = 0.65 + 0.35*rand();

% Mtheta_1 = 100;
% Mgas = 0.001;
% Msigma = 0.1;
% Mth_1 = 0.2;
% Mth_2 = 0.6;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

MsizePic = imresize(GrayPic,[256,256]);            %尺寸缩放
% figure(5);
% subplot(1,1,1),imshow(MsizePic),title('MsizePic');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Madjust=imadjust(MsizePic,[Mth_1 Mth_2],[0.1 1]);   %随机改变灰度

GasPic= imnoise(Madjust,'gaussian',0,Mgas);         %添加高斯噪声
% figure(2);
% subplot(1,1,1),imshow(GasPic),title('gas');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
PSF = fspecial('motion',2,Mtheta_1);     %高斯运动模糊 H = FSPECIAL('motion',LEN,THETA)  LEN移动像素个数，THETA角度
PSF_Pic = imfilter(GasPic,PSF,'conv','circular');
% figure(3);
% subplot(1,1,1),imshow(PSF_Pic),title('PSFPic');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
gausFilter = fspecial('gaussian',[5 5],Msigma); %高斯平滑窗口
MrePic= imfilter(PSF_Pic,gausFilter,'replicate');
% figure(4);
% subplot(1,1,1),imshow(MrePic),title('PSFPic');

%%%%%%%%%%%%%%%%%%%%%以下进行图像扭曲%%%%%%%%%%%%%%%%%%%%%%%
rot=0;
[h w]=size(MrePic);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%3个随机参数
Mrad_1 = 120 + (240-1)*rand();
Mrad_2 = 0.1 + 1*rand();
Mrad_3 = 1 + 1*rand();
wave=[Mrad_3,Mrad_1]; %[幅度，周期]

imgn = zeros(h,w);  
imgn = uint8(imgn);
rot=rot+Mrad_2;
for y=1:h
    for x=1:w

        yy=round((y-wave(1))-(wave(1)*sin(2*pi/wave(2)*x+rot)));    %依然是逆变换
        xx=round((x-wave(1))-(wave(1)*cos(2*pi/wave(2)*y+rot)));

       if yy>=1 && yy<=h && xx>=1 && xx<=w
            imgn(y,x)=MrePic(yy,xx);
       end

    end
end

% figure(6);
% imshow(imgn);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%生成图片和标签%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%训练样本%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if name <= name_train
        Mpath = sprintf(strcat('./train/%d'),class);
        if ~exist(Mpath) 
            mkdir(Mpath)         % 若不存在，在当前目录中产生一个子目录
        end 

        imgname = sprintf(strcat('train/%d/%d','.jpg'),class,name);
        imwrite(imgn,imgname);

        fprintf(fp_t,'%d/%d.jpg',class,name);
        fprintf(fp_t,' %d\n',class);
    else
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%测试样本%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        name_val = name - name_train;
        Mpath = sprintf(strcat('./val/%d'),class);
        if ~exist(Mpath) 
            mkdir(Mpath)         % 若不存在，在当前目录中产生一个子目录
        end 

        imgname = sprintf(strcat('val/%d/%d','.jpg'),class,name_val);
        imwrite(imgn,imgname);

        fprintf(fp_v,'%d/%d.jpg',class,name_val);
        fprintf(fp_v,' %d\n',class);        
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%打印提示%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if (name+1) == (Nm_out)
    toc   
    fprintf('已经生成%d张图片,约占总数的%f\n',(name+1),Nm_out/(Nm_all+1));
    Nm_out = Nm_out + Nm_con;
    end
    
end
    Nm_out = Nm_con;
    fprintf('第%d个类完成\n',class);
end
fclose(fp_t);
fclose(fp_v);
fclose all;
fprintf('所有类完成！！！！\n');
toc

