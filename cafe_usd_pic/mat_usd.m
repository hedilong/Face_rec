tic
clear  
clc  
% figure(1);
% subplot(1,1,1),imshow(GrayPic),title('gray');
trainfile='train.txt';
valfile='val.txt';
fp_t = fopen(trainfile,'wt');
fp_v = fopen(valfile,'wt');
name_train = 999;                    %����ѵ��������ͼƬ��+1��ʣ�����Ϊ��֤����
Nm_all = 1499                        %��ͼƬ��+1
Nm_out = floor((Nm_all+1)/4);           %����1/4����Ŀ���ӡ��ʾ
Nm_con = Nm_out;
for class = 0:5
    if class == 0
       im = imread('2_A.jpg');        %��ȡͼƬ  
    elseif  class == 1
       im = imread('5_A.jpg');        %��ȡͼƬ      
    elseif  class == 2
       im = imread('10_A.jpg');        %��ȡͼƬ 
    elseif  class == 3
       im = imread('50_A.jpg');        %��ȡͼƬ      
    elseif  class == 4
       im = imread('100_A.jpg');        %��ȡͼƬ 
     elseif  class == 5
       im = imread('10_B.jpg');        %��ȡͼƬ      
%      elseif  class == 6
%        im = imread('50_A.jpg');        %��ȡͼƬ 
%      elseif  class == 7
%        im = imread('50_B.jpg');        %��ȡͼƬ      
%     elseif  class == 8
%        im = imread('100_A.jpg');        %��ȡͼƬ 
%      elseif  class == 9
%        im = imread('100_B.jpg');        %��ȡͼƬ      
    end  
    
GrayPic = rgb2gray(im);              %ת��Ϊ��ͨ���ĻҶ�ͼ��
    
for name = 0:Nm_all                     %�ܹ����ɵ�ͼƬ
% matgraypic = mat2gray(im);
% MidGrayPic = uint8(matgraypic);
% [h w]=size(MidGrayPic);
% MidGrayPic2 = zeros(rows , cols);%�õõ��Ĳ�������һ��ȫ��ľ���������������洢������ķ��������ĻҶ�ͼ��    
% MidGrayPic2 = uint8(MidGrayPic2);%��������ȫ�����ת��Ϊuint8��ʽ����Ϊ���������䴴��֮��ͼ����double�͵�  
%%%%%%%%%%%%%%%%%%%%%%%%�����������%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Mtheta_1 = 100 + (240-1)*rand();     %�����˹�˶�ģ���Ƕ�
Mgas = 0.001 + 0.01*rand();          %�����˹����
Msigma = 0.1 + 0.8*rand();           %�����˹�˲�����
Mth_1 = 0.25 + 0.35*rand();            %����ı�Ҷ�����
Mth_2 = 0.65 + 0.35*rand();

% Mtheta_1 = 100;
% Mgas = 0.001;
% Msigma = 0.1;
% Mth_1 = 0.2;
% Mth_2 = 0.6;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

MsizePic = imresize(GrayPic,[256,256]);            %�ߴ�����
% figure(5);
% subplot(1,1,1),imshow(MsizePic),title('MsizePic');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Madjust=imadjust(MsizePic,[Mth_1 Mth_2],[0.1 1]);   %����ı�Ҷ�

GasPic= imnoise(Madjust,'gaussian',0,Mgas);         %��Ӹ�˹����
% figure(2);
% subplot(1,1,1),imshow(GasPic),title('gas');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
PSF = fspecial('motion',2,Mtheta_1);     %��˹�˶�ģ�� H = FSPECIAL('motion',LEN,THETA)  LEN�ƶ����ظ�����THETA�Ƕ�
PSF_Pic = imfilter(GasPic,PSF,'conv','circular');
% figure(3);
% subplot(1,1,1),imshow(PSF_Pic),title('PSFPic');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
gausFilter = fspecial('gaussian',[5 5],Msigma); %��˹ƽ������
MrePic= imfilter(PSF_Pic,gausFilter,'replicate');
% figure(4);
% subplot(1,1,1),imshow(MrePic),title('PSFPic');

%%%%%%%%%%%%%%%%%%%%%���½���ͼ��Ť��%%%%%%%%%%%%%%%%%%%%%%%
rot=0;
[h w]=size(MrePic);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%3���������
Mrad_1 = 120 + (240-1)*rand();
Mrad_2 = 0.1 + 1*rand();
Mrad_3 = 1 + 1*rand();
wave=[Mrad_3,Mrad_1]; %[���ȣ�����]

imgn = zeros(h,w);  
imgn = uint8(imgn);
rot=rot+Mrad_2;
for y=1:h
    for x=1:w

        yy=round((y-wave(1))-(wave(1)*sin(2*pi/wave(2)*x+rot)));    %��Ȼ����任
        xx=round((x-wave(1))-(wave(1)*cos(2*pi/wave(2)*y+rot)));

       if yy>=1 && yy<=h && xx>=1 && xx<=w
            imgn(y,x)=MrePic(yy,xx);
       end

    end
end

% figure(6);
% imshow(imgn);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%����ͼƬ�ͱ�ǩ%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%ѵ������%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if name <= name_train
        Mpath = sprintf(strcat('./train/%d'),class);
        if ~exist(Mpath) 
            mkdir(Mpath)         % �������ڣ��ڵ�ǰĿ¼�в���һ����Ŀ¼
        end 

        imgname = sprintf(strcat('train/%d/%d','.jpg'),class,name);
        imwrite(imgn,imgname);

        fprintf(fp_t,'%d/%d.jpg',class,name);
        fprintf(fp_t,' %d\n',class);
    else
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%��������%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        name_val = name - name_train;
        Mpath = sprintf(strcat('./val/%d'),class);
        if ~exist(Mpath) 
            mkdir(Mpath)         % �������ڣ��ڵ�ǰĿ¼�в���һ����Ŀ¼
        end 

        imgname = sprintf(strcat('val/%d/%d','.jpg'),class,name_val);
        imwrite(imgn,imgname);

        fprintf(fp_v,'%d/%d.jpg',class,name_val);
        fprintf(fp_v,' %d\n',class);        
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%��ӡ��ʾ%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if (name+1) == (Nm_out)
    toc   
    fprintf('�Ѿ�����%d��ͼƬ,Լռ������%f\n',(name+1),Nm_out/(Nm_all+1));
    Nm_out = Nm_out + Nm_con;
    end
    
end
    Nm_out = Nm_con;
    fprintf('��%d�������\n',class);
end
fclose(fp_t);
fclose(fp_v);
fclose all;
fprintf('��������ɣ�������\n');
toc

