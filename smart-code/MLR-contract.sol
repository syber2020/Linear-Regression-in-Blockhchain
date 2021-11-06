// SPDX-License-Identifier: MIT
pragma solidity 0.7.0;
pragma experimental ABIEncoderV2;
contract regression{
   int lcm ; int sub_num; int sub_den;int[] z_num; int[] z_den;int[] yh_num; int[] yh_den;
   int[] yh_sub_num; int[] yh_sub_den; int[] del_w_num; int[] del_w_den; int del_b_num; int del_b_den;
   int[] _wnum; int[] _wden;
   
    function get_lcm(int x, int y) public returns(int){
        int greater;  
        if(x>y){ greater =x;}
        else{ greater =y;}
        while(true){
            if(x==0){ lcm = y; break;}
            else if (y==0){lcm =x; break;}
            else if(greater%x==0 && greater%y==0) { lcm = greater; break;}
            greater +=1;
        }
        return greater;
    }
    
    function get_subtraction(int a, int b, int c, int d) public returns(int,int){
        sub_den = get_lcm(b,d);
        if(b==0){sub_num = c ; sub_den = d;}
        else if (d==0){sub_num= a ; sub_den = b;}
        else {sub_num = ((sub_den/b)*a) - ((sub_den/d)*c); }
        return (sub_num,sub_den);
    }
    
    function get_gcd(int a, int b) public returns(int) {
        if (a==0) return b;
        if (b==0) return a;
        if (a==b) return a;
        if (a>b) return get_gcd(a-b,b);
        return get_gcd(a,b-a);
    }
    function get_add_array(int[] memory anum, int[] memory aden ) public returns(int,int){
      int _lcm=1; int _sum=0; int gcd=0;
      for (uint i=0;i<aden.length;i++){
          gcd = get_gcd(_lcm,aden[i]);
          _lcm = (_lcm*aden[i])/gcd;
      }
      for (uint i=0;i<anum.length;i++){
          _sum=_sum+ anum[i]*_lcm/aden[i];
          
      }
      return (_sum,_lcm);
    }
    function get_addition(int a, int b, int c, int d) public returns(int,int){
        int num; int den; 
        den = get_lcm(b,d);
        if (b==0){num = c ; den = d;}
        else if (d==0){num= a ; den = b;}
        else    { num = ((den/b)*a) + ((den/d)*c);}
        return (num,den);
    }
    
    function get_multiply(int[] memory a_num, int[] memory a_den,int[] memory b_num,int[] memory b_den) public returns(int,int) {
         int num; int den;
        for( uint i=0; i<a_num.length; i++){
            int x = a_num[i]*b_num[i];
            int y = a_den[i]*b_den[i];
         
            z_num.push(x); z_den.push(y);   
        }
        (num,den) = get_add_array(z_num,z_den);
        return (num,den);
    }
  
//for y_hat function use a pre-prcessor function in python to get rows of x_train separately instead of getting 2d array as it may throw error
// the below function must be caleld for n rows in x_train dataset
    function get_y_hat(int[] memory wnum, int[] memory wden, int[] memory x_num, int[] memory x_den, int[] memory b)  public {
        int temp_n; int temp_d;
        (temp_n,temp_d) = get_multiply(x_num,x_den,wnum,wden);
        (temp_n,temp_d) = get_addition(temp_n,temp_d,b[0],b[1]);
        yh_num.push(temp_n); yh_den.push(temp_d);
        //may need to sjorten the results of yh_num and yh_den in python
    }
    
    function get_mse(int[] memory yhnum, int[] memory yhden, int[] memory ynum, int[] memory yden) public returns (int,int) {
        int num =0; int den =0;int num1;int den1;
        for(uint i =0;i<yhnum.length;i++){
            (num1,den1) = get_subtraction(ynum[i],yden[i],yhnum[i],yhden[i]);
            num1 = num1*num1;
            den1 = den1*den1;
            (num,den) = get_addition(num,den,num1,den1);
        }
        return (num,den);
    }
    
    function get_y_hat_subtraction(int[] memory yhnum,int[] memory yhden,int[] memory ynum,int[] memory yden) public returns(int[] memory, int[] memory){
          for (uint i =0; i<yhnum.length;i++){
              (yh_sub_num[i],yh_sub_den[i]) = get_subtraction(yhnum[i],yhden[i],ynum[i],yden[i]);
          }
          return (yh_sub_num,yh_sub_den);
    }
    
    // for following function we need transpose matrix of x_train and take the input one by one into it
    function get_delta_w(int[] memory yh_sub_n, int[] memory yh_sub_d, int[] memory xnum,int[] memory xden ) public  {
          int x; int y;
          (x,y) = get_multiply(xnum,xden,yh_sub_n,yh_sub_d);
          del_w_num.push(x);
          del_w_den.push(y);
    }
    
    function get_delta_b() public {
        int num; int den;
        (num,den) = get_add_array(yh_sub_num,yh_sub_den);
        del_b_num = num*2;
        del_b_den = den * int(yh_sub_num.length);
        
    }
    
    function get_new_parameters(int lr_num, int lr_den) public  {
        for (uint i=0;i<del_w_num.length; i++){
            del_w_num[i] = del_w_num[i]*lr_num;
            del_w_den[i] = del_w_num[i]*lr_den;
        }
        
        for (uint i=0;i<del_w_num.length;i++){
            (_wnum[i], _wden[i]) = get_subtraction(_wnum[i],_wden[i],del_w_num[i],del_w_den[i]);
        }
    }
    
    
    // function set_lcm() public view returns(int) { return lcm;}
    
    // function set_subtraction() public view returns(int,int){return (sub_num, sub_den);}
    
    // // function set_add_array() public returns(int,int){ return  }
    
    // function set_addition() public returns(int){}
    
    // function set_multiply() public returns(int){}
    
    // function set_y_hat() public returns(int, int){}
    
    // function set_mse() public  returns(int){}
    
    // function set_y_hat_subtraction() public returns(int) {}
    
    // function set_delta_w() public returns(int) {}
    
    // function set_delta_b() public returns(int) {}
    
    // function set_set_new_parameters() public returns(int) {}
    
}