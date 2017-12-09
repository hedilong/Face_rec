clear  
clc  
img=imread('100_A.jpg');%读取图片 
GrayPic = rgb2gray(img);
[h w]=size(GrayPic);
Mrad_1 = 120 + (240-1)*rand();
Mrad_2 = 0.1 + 1*rand();
Mrad_3 = 0.5 + 1*rand();
wave=[Mrad_3,Mrad_1]; %[幅度，周期]
% newh=h+2*wave(1);
% neww=w+2*wave(1);
newh=h;
neww=w;
rot=0;
for i=1:1
    imgn=zeros(newh,neww);  
    imgn = uint8(imgn);
    rot=rot+Mrad_2;
    for y=1:newh
        for x=1:neww

            yy=round((y-wave(1))-(wave(1)*cos(2*pi/wave(2)*x+rot)));    %依然是逆变换
            xx=round((x-wave(1))-(wave(1)*cos(2*pi/wave(2)*y+rot)));

           if yy>=1 && yy<=h && xx>=1 && xx<=w
                imgn(y,x)=img(yy,xx);
           end

        end
    end

    figure(1);
    imshow(imgn);
    imwrite(imgn,strcat('Pic','.bmp'));
%  imgn(:,:,2)=imgn;       %生成gif图片
%  imgn(:,:,3)=imgn(:,:,1);
%  [I,map]=rgb2ind(mat2gray(imgn),256);  
% imwrite(I,map,'re.gif','Loopcount',inf,'DelayTime',1.5);
% rt=mat2gray(imgn);
% figure(3);
% subplot(1,1,1),imshow(rt),title('PSFPic');
% imwrite(I,map,strcat('PSFPic','.bmp'));

end