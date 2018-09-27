function svm_grid
tic;
close all;
clear;
clc; 
format compact;

% CoreNum=48; %���õĴ���������
% if parpool('local')<=0  %֮ǰû�д�
%     parpool('open','local',CoreNum);
% else  %֮ǰ�Ѿ���
%     disp('matlab pool already started');
% end

data=xlsread('F:\98_data_feature.xlsx');
large=96;   %��ǩ��
labels=xlsread('F:\label.xlsx','A1:A96');
temp=[]; 
cg=[]; 
train_98=data(2:large,:);
train_98_labels =labels(2:large); 
test_98 =data(1,:); 
test_98_labels =labels(1); 
%% ѡ��GA��ѵ�SVM����c&g   ��һ��
[bestaac,bestc,bestg] = SVMcgForClass(train_98_labels, train_98,-10,10,-10,10); %���ز���������һ����������
%�������Ѱ�ź���(��������)[bestCVaccuracy,bestc,bestg]=SVMcgForClass(train_label,train,
%cmin,cmax,gmin,gmax,v,cstep,gstep,accstep)������c�ı仯��ΧΪ-10��10
%RBF�˲���g�ı仯��ΧΪ-10��10
% cg(1,1)=bestc; %��õ�cֵ����һ�е�һ��
% cg(1,2)=bestg; %ͬ��
%%%%
%% ������ѵĲ�������SVM����ѵ��  ��һ��
cmd = ['-c ',num2str(bestc),' -g ',num2str(bestg)];
%%%%%
model = svmtrain(train_98_labels, train_98,cmd); %model��ѵ���õ���ģ��
[accuracy] = svmpredict(test_98_labels, test_98, model); 
temp(1)=accuracy(1);  %�ѵ�һ����ȷ�Ⱦ���ֵ��temp
temp_a=(1:large-2);
parfor n=2:(large-1) 
train_98 = [data(1:(n-1),:);data((n+1):large,:)];% 
train_98_labels = [labels(1:(n-1));labels((n+1):large)];%
test_98 =data(n,:); 
test_98_labels =labels(n); 
%% ѡ��GA��ѵ�SVM����c&g  �ڶ���
[bestaac,bestc,bestg] = SVMcgForClass(train_98_labels, train_98,-10,10,-10,10);
% cg(n,1)=bestc; %��õ�Cֵ�����n��1��  n��2��96
% cg(n,2)=bestg;%��õ�gֵ���n��2��  
%%%%
%% ������ѵĲ�������SVM����ѵ��  �ڶ���
cmd = ['-c ',num2str(bestc),' -g ',num2str(bestg)];
%%%%%
model = svmtrain(train_98_labels, train_98,cmd);
[accuracy] = svmpredict(test_98_labels, test_98, model);
% temp_a = [temp_a, accuracy(1)];
temp_a(n-1)=accuracy(1);
end
train_98=data(1:(large-1),:);
train_98_labels =labels(1:(large-1));
test_98 =data(large,:); 
test_98_labels =labels(large);
%% ѡ��GA��ѵ�SVM����c&g   ������
[bestaac,bestc,bestg] = SVMcgForClass(train_98_labels, train_98,-10,10,-10,10);
% cg(large,1)=bestc;  %��c��ֵ��96�е�һ��
% cg(large,2)=bestg; %ͬ��
%%%%
%% ������ѵĲ�������SVM����ѵ��   ������
cmd = ['-c ',num2str(bestc),' -g ',num2str(bestg)];
%%%%%
model = svmtrain(train_98_labels, train_98,cmd);
[accuracy] = svmpredict(test_98_labels, test_98, model);
temp(large)=accuracy(1);  %��accuracy��һ��Ԫ�ظ�ֵ��temp�ĵ�96��Ԫ��
temp(2:large-1)=temp_a;
label = reshape(labels , 1 , large );
result = (temp==label);
wrong_num=large-(length(nonzeros(result)));
real_acc=(length(nonzeros(result)))/large;
fprintf(' _num= %d \n',wrong_num);
fprintf(' real_acc= %f \n',real_acc);
for m=1:large
xlswrite('F:\label.xlsx',temp(m),'sheet1',['B',num2str(m)]); %д������ļ�A�� ���ֱ�Ϊ�ַ��� 
end
wrong=fopen('wrong_mean.txt','a');%'A.txt'Ϊ�ļ�����'a'Ϊ�򿪷�ʽ���ڴ򿪵��ļ�ĩ��������ݣ����ļ��������򴴽���
accr=fopen('acc_mean.txt','a');%'A.txt'Ϊ�ļ�����'a'Ϊ�򿪷�ʽ���ڴ򿪵��ļ�ĩ��������ݣ����ļ��������򴴽���
fprintf(wrong,'%d \r\n',wrong_num);%fpΪ�ļ������ָ��Ҫд�����ݵ��ļ���ע�⣺%d���пո�
fprintf(accr,'%d \r\n',real_acc);%fpΪ�ļ������ָ��Ҫд�����ݵ��ļ���ע�⣺%d���пո�
fclose(wrong);%�ر��ļ���
fclose(accr);%�ر��ļ���
toc;
%disp(cg);
function [bestacc,bestc,bestg] = SVMcgForClass(train_label,train,cmin,cmax,gmin,gmax,v,cstep,gstep,accstep)
%�������Ѱ�ź���
%�Ա����溯�� 
%[bestc,bestg] = SVMcgForClass(train_98_labels, train_98,-10,10,-10,10);
%�������Ѱ�ź���(��������)[bestCVaccuracy,bestc,bestg]=SVMcgForClass(train_label,train,
%cmin,cmax,gmin,gmax,v,cstep,gstep,accstep)������c�ı仯��ΧΪ-10��10
%RBF�˲���g�ı仯��ΧΪ-10��10
%SVMcg cross validation by faruto

%
% by faruto
%Email:patrick.lee@foxmail.com QQ:516667408 http://blog.sina.com.cn/faruto BNU
%last modified 2010.01.17
%Super Moderator @ www.ilovematlab.cn

% ��ת����ע����
% faruto and liyang , LIBSVM-farutoUltimateVersion 
% a toolbox with implements for support vector machines based on libsvm, 2009. 
% Software available at http://www.ilovematlab.cn
% 
% Chih-Chung Chang and Chih-Jen Lin, LIBSVM : a library for
% support vector machines, 2001. Software available at
% http://www.csie.ntu.edu.tw/~cjlin/libsvm

% about the parameters of SVMcg 
if nargin < 10
    accstep = 4.5;
end
if nargin < 8
    cstep = 0.8;
    gstep = 0.8;
end
if nargin < 7
    v = 5;
end
if nargin < 5
    gmax = 8;
    gmin = -8;
end
if nargin < 3
    cmax = 8;
    cmin = -8;
end
% X:c Y:g cg:CVaccuracy
[X,Y] = meshgrid(cmin:cstep:cmax,gmin:gstep:gmax);
[m,n] = size(X);
cg = zeros(m,n);

eps = 10^(-4);

% record acc with different c & g,and find the bestacc with the smallest c
bestc = 1;
bestg = 0.1;
bestacc = 0;
basenum = 2;
for i = 1:m
    for j = 1:n
        cmd = ['-v ',num2str(v),' -c ',num2str( basenum^X(i,j) ),' -g ',num2str( basenum^Y(i,j) )];
        cg(i,j) = svmtrain(train_label, train, cmd);
        
        if cg(i,j) <= 55
            continue;
        end
        
        if cg(i,j) > bestacc
            bestacc = cg(i,j);
            bestc = basenum^X(i,j);
            bestg = basenum^Y(i,j);
        end        
        
        if abs( cg(i,j)-bestacc )<=eps && bestc > basenum^X(i,j) 
            bestacc = cg(i,j);
            bestc = basenum^X(i,j);
            bestg = basenum^Y(i,j);
        end        
        
    end
end
