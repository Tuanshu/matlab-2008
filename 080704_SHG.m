         clear all;
		 %倍頻程式
   w=0;
         
%===========調變參數===============
          QPM_wavelength=1.550;   
          Scanning_range=0.1;     %以QPM_wavelength為中心
          Scanning_pitch=0.01;     %全部的單位都是micron (in spectral domain)
          Ratio=1;
%=================================

%===========平常不動的參數=========
            q_p=1000000;                %將每個QPM pitch分成這麼多個pitch (spitially) (QPM pitch/q_p=dz)
            random_pitch=1;        %單位dz, 最好設為q_p/2 (coherent length)的因數, 不然會遇到換poling方向時一個pitch被切斷的情況(物理圖像不對)
            number_of_period=1;      %週期數量, 此數值乘上QPM週期(這是算出來的)即sevice長度
%====================================


%===========預先宣告陣列長度==========
Z01(1:(Scanning_range/Scanning_pitch))=0;
W3(1:(Scanning_range/Scanning_pitch))=0;
Z03(1:(Scanning_range/Scanning_pitch))=0;
area(1:(Scanning_range/Scanning_pitch))=0;
delta_k_SHG(1:q_p)=0;
position(1:q_p)=0;
M_SHG(1:q_p)=0;
power_run_A(1:q_p)=0;
power_run_B(1:q_p)=0;
SHG_power(1:(Scanning_range/Scanning_pitch))=0;
SHG_wavelength_t(1:(Scanning_range/Scanning_pitch))=0;
%==================================== 
         


		 W01=0.065;            %輸入晶體前光束光腰半徑(mm)
		 fL=50;                %透鏡焦距(mm)
		 n=1;                   %真空中折射率
		 C=3E8;                 %光速(m/s)
		 pi=3.1415926;          %圓周率
		 d=0.6E-6;              %單位周期位移量(m)

		 sus=8.854E-12;         %真空中介電常數(F/m)
		 perm=pi*4E-7;          %真空中導磁係數(H/m)
         
         t=25;                  %溫度
	     
		%    fe=(t-24.5)*(t+570.82);                     %Sellimeier equation 參數 for LN
	    %    c1=5.35583;                                
		%    c2=0.100473;
		%    c3=0.20692;
		%    c4=100;
		%    c5=11.34927;
		%    c6=-1.5334e-2;
		%    d1=4.629e-7;
		%    d2=3.826e-8;
		%    d3=-8.9e-9;
		%    d4=2.657e-5	;	 
%=============================以下是LT的
	        A=4.514261                      ;           
		    B=0.011901;
		    C=0.110744;
            D=-0.02323;
            E=0.076144;
            F=0.195596;
            bT=(1.82194*1E-8)*(t+273.15)^2;
            cT=(1.5662*1E-8)*(t+273.15)^2	 ;
            
            
                        
            			np_gpr=(A+(B+bT)/(lamp_gpr^2-(C+cT)^2)+E/(lamp_gpr^2-F^2)+D*lamp_gpr^2)^0.5 ;
		    nc_gpr=(A+(B+bT)/(lamc_gpr^2-(C+cT)^2)+E/(lamc_gpr^2-F^2)+D*lamc_gpr^2)^0.5 ;
           			gpr_1=(nc_gpr/lamc_gpr-np_gpr/lamp_gpr-np_gpr/lamp_gpr)^(-1) ;     
        
			
	      %power_p=q*10
	   	  power_p=0.05;                      %入射光功率(W)


		  %do r=27,30,1
          %write(*,*),r


		  %vi=0.1
          %do rv_round=1,14,1

	      %call random_seed()
		  %do rv=1,301,1
		  %call random_number(r1)
		  %r1_array(rv)=1-vi+2*vi*r1
		  %end do




          %=======================================!
		  %     迴圈1 (最外圈) ==> 跑波長變化
		  %=======================================! 

for j=1:(Scanning_range/Scanning_pitch)                                 
        %write(*,*),j

            lam_p=QPM_wavelength-0.5*Scanning_range+Scanning_pitch*j;   %基頻光波長(um) 是j的函數
		    
		    lam_c=lam_p/2;             %倍頻光波長(um)
		
            
			%write(1,*) lam_p*1E3
		
			 
			fre_p=2*pi*C/lam_p*1E6;   %基頻光頻率(Hz)
		    
		    fre_c=2*pi*C/lam_c*1E6;   %倍頻光頻率(Hz)

		%	np=(c1+d1*fe+(c2+d2*fe)/(lam_p^2-(c3+d3*fe)^2)+(c4+d4*fe)/(lam_p^2-(c5)^2)+c6*lam_p^2)^0.5;  %基頻光折射率 FOR LN
  		    
		%    nc=(c1+d1*fe+(c2+d2*fe)/(lam_c^2-(c3+d3*fe)^2)+(c4+d4*fe)/(lam_c^2-(c5)^2)+c6*lam_c^2)^0.5;  %倍頻光折射率 FOR LN

            np=(A+(B+bT)/(lam_p^2-(C+cT)^2)+E/(lam_p^2-F^2)+D*lam_p^2)^0.5 ;
		    nc=(A+(B+bT)/(lam_c^2-(C+cT)^2)+E/(lam_c^2-F^2)+D*lam_c^2)^0.5 ;
        
		    %write(*,*) np
			%write(*,*) nc

			Z01(j)=pi*(W01)^2*n/(lam_p*1E-3);
		
		    W3(j)=(fL/Z01(j))/((1+(fL/Z01(j))^2)^0.5)*W01; %入射晶體後光腰半徑

		    Z03(j)=pi*(W3(j))^2*n/(lam_p*1E-3);             %rayleigh range

			area(j)=pi*(W3(j)*1E-3)^2;                       %光點面積
		 
          A(1)=((2*power_p*(perm/sus)^(0.5))/(area(j)*fre_p))^(0.5);     %基頻光電場初始值
		  B(1)=0;                                                        %倍頻光電場初始值
		  
          %下面的是designed pitch, 所以和j無關
		   %lamp_gpr=1.550                  %計算起始週期長度對應之基頻光波長
		    lamp_gpr=QPM_wavelength;
		
            lamc_gpr=lamp_gpr/2;              %計算起始週期長度對應之倍頻光波長
		    
			
			%write(*,*) lamc_gpr
		%	np_gpr=(c1+d1*fe+(c2+d2*fe)/(lamp_gpr^2-(c3+d3*fe)^2)+(c4+d4*fe)/(lamp_gpr^2-(c5)^2)+c6*lamp_gpr^2)^0.5;  %計算起始週期長度對應之基頻光折射率	FOR LN	    
		%    nc_gpr=(c1+d1*fe+(c2+d2*fe)/(lamc_gpr^2-(c3+d3*fe)^2)+(c4+d4*fe)/(lamc_gpr^2-(c5)^2)+c6*lamc_gpr^2)^0.5;  %計算起始週期長度對應之倍頻光折射率
		                        
            np_gpr=(A+(B+bT)/(lamp_gpr^2-(C+cT)^2)+E/(lamp_gpr^2-F^2)+D*lamp_gpr^2)^0.5 ;
		    nc_gpr=(A+(B+bT)/(lamc_gpr^2-(C+cT)^2)+E/(lamc_gpr^2-F^2)+D*lamc_gpr^2)^0.5 ;
           	gpr_1=(nc_gpr/lamc_gpr-np_gpr/lamp_gpr-np_gpr/lamp_gpr)^(-1) ;   	
        
        
		    %write(*,*) np_gpr,nc_gpr,nu_gpr
			
		%	gpr_1=(nc_gpr/lamc_gpr-np_gpr/lamp_gpr-np_gpr/lamp_gpr)^(-1);	%一階倍頻對應之QPM週期(um) LN
			
            
		    dz=gpr_1/q_p*1E-6;              %計算晶體長度之間距(m)        
			%dz=(gpr_2+d*s+r*h)/600*1E-6 	%計算晶體長度之間距(m)		
                                        



		    %do d_change=1,10000,1
			%deff_1=0.0001*(d_change)*1.939E-22 
%		    d_BPM=3.04612E-22;                                                          %不知道這是啥單位 to check FOR LN
            
            d_BPM=sus*8.5E-12;              %    8.5E-12 m/V, 參考Hao 071220           
            deff_1_p=2/pi*d_BPM;                                                         %非線性係數(AS/V^2) =d_BPM*2/(pi)
            deff_1_n=-deff_1_p;
            %write(*,*) 2*((perm/sus)**1.5)*((c/lam_p*1E6)**2)*(d_BPM**2)*(0.0032**2)/(np**3)*power_p/(area(j))*100
             %==============================================


		  %================================================================!
		  %     迴圈2 (第2圈) ==> 給定週期長度與個數
		  %                       
		  %================================================================! 

        for h=1:number_of_period  %週期的數量
		  
		  %===========================================================================!
		  %     迴圈3 (第3圈) ==> 基頻的消耗與倍頻光的產生                     
		  %===========================================================================! 
		
    for q=1:q_p                        %q為position之index   600為一週期
             
            
		
                if q<=q_p/2              %週期反轉,duty cycle=50%       這邊可以稍微寫的精簡一點, 但這樣比較清楚
                    if (mod(q-1,random_pitch)==0)       
                        if rand<Ratio
                            deff_1=deff_1_p;
                        else
                            deff_1=deff_1_n;
                        end
                    end
                else
                    if mod(q-1,random_pitch)==0
                        if rand<Ratio
                            deff_1=deff_1_n;
                        else
                            deff_1=deff_1_p;
                        end
                    end                             %沒做check時什麼都不做, 也就是不換
                end
 
                
			%write(*,*) i,deff_1
		   
			%write(*,*)np,nc

            sus_p=sus*np^2;                  %基頻光之介電係數
		   
		    sus_c=sus*nc^2;                  %倍頻光之介電係數
            
			%write(*,*)  sus_p,sus_c

            lo_p=0;                           %基頻光傳輸損耗 
           
            lo_c=0;                           %倍頻光傳輸損耗 
         

			abs_p=lo_p*(perm/sus_p)^(0.5);   %基頻光吸收係數
            
            abs_c=lo_c*(perm/sus_c)^(0.5);   %倍頻光吸收係數
            
			%write(*,*) abs_p,abs_c
	
            delta_k_SHG(q)=2*pi*(nc/(lam_c*1E-6)-np/(lam_p*1E-6)-np/(lam_p*1E-6));   %倍頻相位不匹配程度
			
			%delta_k_1=0                                                    
			%write(*,*) delta_k_1

			position(q+1)=position(q)+dz;                   %光束傳遞位置
           
		    M_SHG(q)=i*delta_k_SHG(q)*position(q);
           

			k_1=deff_1*((perm/sus)*fre_p*fre_p*fre_c/(np*np*nc))^(0.5);                %倍頻非線性耦合係數
           
           A(q+1)=A(q)+dz*(-0.5*abs_p*A(q)-0.5*i*k_1*B(q)*conj(A(q))*exp(-M_SHG(q)));  %計算基頻光之消耗
		   B(q+1)=B(q)+dz*(-0.5*abs_c*B(q)-0.5*i*k_1*A(q)^2*exp(M_SHG(q)));            %計算倍頻光之產生
          
		   power_run_A(q)=(0.5*(sus/perm)^(0.5))*fre_p*((abs(A(q)))^2)*area(j);     %經過一段長度所剩下的基頻光功率(W) 學長的程式有乘2, 被我拿掉了
           power_run_B(q)=(0.5*(sus/perm)^(0.5))*fre_c*((abs(B(q)))^2)*area(j);       %經過一段長度所產生的倍頻光功率(W)
                      
        
          % total_A((h-1)*q_p+(q+1))=power_run_A(q);
          % total_B((h-1)*q_p+(q+1))=power_run_B(q);
	
           
		 
    end                                %迴圈3結束 q
           
		   position(1)=position(q_p+1);           %接續晶體長度
		   A(1)=A(q_p+1);                         %基頻光接續傳遞
           B(1)=B(q_p+1);                         %倍頻光接續傳遞
	                                
           
        end                               %迴圈2結束 h

  

		 SHG_power(j)=power_run_B(q_p)';                % (W)
		  position(1)=0;                        %改變波長前須將晶體位置歸零           
         
         
         %write(6,*),real(power_run_A(600))+real(power_run_B(600))
          %write(*,*) real(power_run_B(600))
          %write(*,*) real(power_run_B(600))
	 	 
          %if( real(power_run_B(600)) > 120.098 ) then
     	  %write(*,*) "found"
	      %write(3,*) deff_1
	      %end if

	     %end do
		  
end                                    %迴圈1結束 j

for t=1:(Scanning_range/Scanning_pitch)                                 %生成畫圖用的wavelength scale (micron)
    SHG_wavelength_t(t)=QPM_wavelength-0.5*Scanning_range+Scanning_pitch*t;
end
SHG_wavelength=SHG_wavelength_t';
 plot(SHG_wavelength,SHG_power);
	%plot(power_run_B);		  
			  
			
