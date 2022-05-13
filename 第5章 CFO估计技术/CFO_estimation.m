clear, clf
CFO = 0.15;                    %Ƶƫ
Nfft=128;                      %FFT�ĵ���
Nbps=2;                        %���ƽ���
M=2^Nbps;  
Es=1; 
A=sqrt(3/2/(M-1)*Es);          %�źŷ���
N=Nfft;
Ng=Nfft/4;                     %ѭ��ǰ׺�򱣻��������
Nofdm=Nfft+Ng;                 %һ��OFDM���ų���
Nsym=3;
h=complex(randn,randn)/sqrt(2);%�ŵ������Ӧ 

%% Transmit signal
x=[];
for m=1:Nsym
   msgint=randi([0,M-1],N);
   if i<=2
       Xp = add_pilot(zeros(1,Nfft),Nfft,4);
       Xf=Xp;   
   else 
      mod_object = modem.qammod('M',M, 'SymbolOrder','gray');
      Xf = A*modulate(mod_object,msgint);
   end                        
   xt = ifft(Xf,Nfft);  
   x_sym = add_CP(xt,Ng);
   x= [x x_sym];
end    
y=x; 
sig_pow= y*y'/length(y); 
SNRdBs= 0:3:30;  
MaxIter = 100;  
for i=1:length(SNRdBs)
   SNRdB = SNRdBs(i);
   MSE_CFO_CP = 0; 
   MSE_CFO_Moose = 0; 
   MSE_CFO_Classen = 0;
   rand('seed',1); 
   randn('seed',1);
   y_CFO= add_CFO(y,CFO,Nfft);
   for iter=1:MaxIter
      y_aw = awgn(y_CFO,SNRdB,'measured'); 
      Est_CFO_CP = CFO_CP(y_aw,Nfft,Ng);
      MSE_CFO_CP = MSE_CFO_CP + (Est_CFO_CP-CFO)^2;
      Est_CFO_Moose = CFO_Moose(y_aw,Nfft);
      MSE_CFO_Moose = MSE_CFO_Moose + (Est_CFO_Moose-CFO)^2;
      Est_CFO_Classen = CFO_Classen(y_aw,Nfft,Ng,Xp); 
      MSE_CFO_Classen = MSE_CFO_Classen + (Est_CFO_Classen-CFO)^2;
   end
   MSE_CP(i)=MSE_CFO_CP/MaxIter; 
   MSE_Moose(i)=MSE_CFO_Moose/MaxIter; 
   MSE_Classen(i)=MSE_CFO_Classen/MaxIter;
end
semilogy(SNRdBs, MSE_CP,'-+')
grid on
hold on
semilogy(SNRdBs, MSE_Moose,'-x')
semilogy(SNRdBs, MSE_Classen,'-*')
xlabel('SNR[dB]'), ylabel('MSE'); 
title('CFO Estimation'); 
legend('CP-based technique','Moose (Preamble-based)','Classen (Pilot-based)');