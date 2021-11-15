// SPDX-License-Identifier: MIT
pragma solidity 0.7.0;
pragma experimental ABIEncoderV2;
contract regression{
   int lcm ; int sub_num; int sub_den;int[] z_num; int[] z_den;int[] yh_num; int[] yh_den;
   int[] yh_sub_num; int[] yh_sub_den; int[] del_w_num; int[] del_w_den; int del_b_num; int del_b_den;
   int[] _wnum; int[] _wden; int _b_num; int _b_den; int lr_num; int lr_den;int mse_num; int mse_den;
   
   //define a constructor to deploy the contract with initial bias and weights 
   constructor(int[] memory wnum, int[] memory wden, int bnum, int bden, int lrn, int lrd){
       _wnum = wnum;
       _wden = wden;
       _b_num =bnum;
       _b_den = bden;
       lr_num = lrn;
       lr_den = lrd;
       
   } 
   
   //internal function for least common multiple
    function get_lcm(int x, int y) internal returns(int){
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
    //internal function to compute subtraction between fractions
    function get_subtraction(int a, int b, int c, int d) internal returns(int,int){
        sub_den = get_lcm(b,d);
        if(b==0){sub_num = c ; sub_den = d;}
        else if (d==0){sub_num= a ; sub_den = b;}
        else {sub_num = ((sub_den/b)*a) - ((sub_den/d)*c); }
        return (sub_num,sub_den);
    }
    //internal function to get greatest common divisor 
    function get_gcd(int a, int b) internal returns(int) {
        if (a==0) return b;
        if (b==0) return a;
        if (a==b) return a;
        if (a>b) return get_gcd(a-b,b);
        return get_gcd(a,b-a);
    }
    
    //internal function to add elements of an array in fractions
    function get_add_array(int[] memory anum, int[] memory aden ) internal returns(int,int){
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
    
    //internal functino to compute adition of two fraction numbers
    function get_addition(int a, int b, int c, int d) internal returns(int,int){
        int num; int den; 
        den = get_lcm(b,d);
        if (b==0){num = c ; den = d;}
        else if (d==0){num= a ; den = b;}
        else    { num = ((den/b)*a) + ((den/d)*c);}
        return (num,den);
    }
    
    //internal function to multiply two arrays of functions and get the additoon of numbers usied in yhat = wx+b
    function get_multiply(int[] memory a_num, int[] memory a_den,int[] memory b_num,int[] memory b_den) internal returns(int,int) {
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
//need to rest yh_num and yh_den every time as new values come it
    function get_y_hat( int[] memory x_num, int[] memory x_den)  public {
        int temp_n; int temp_d;
        (temp_n,temp_d) = get_multiply(x_num,x_den,_wnum,_wden);
        (temp_n,temp_d) = get_addition(temp_n,temp_d,_b_num,_b_den);
        yh_num.push(temp_n); yh_den.push(temp_d);
        //may need to shorten the results of yh_num and yh_den in python
    }
    //External function to get mean swiare error
    function get_mse(int[] memory yhnum, int[] memory yhden, int[] memory ynum, int[] memory yden) public returns (int,int) {
        mse_num =0; mse_den =0; int num1;int den1;
        for(uint i =0;i<yhnum.length;i++){
            (num1,den1) = get_subtraction(ynum[i],yden[i],yhnum[i],yhden[i]);
            num1 = num1*num1;
            den1 = den1*den1;
            if (i==0){ mse_num = num1; mse_den = den1;}
            else{(mse_num,mse_den) = get_addition(mse_num,mse_den,num1,den1);}
        }
    }
    //external function to get yhat subtraction from y values of training
    //pushing yh_sub_num, we need to reset it
    function get_y_hat_subtraction(int[] memory ynum,int[] memory yden) public returns(int[] memory, int[] memory){
          int x = 0; int y = 0;
          for (uint i =0; i<yh_num.length;i++){
              (x,y) = get_subtraction(yh_num[i],yh_den[i],ynum[i],yden[i]);
              yh_sub_num.push(x); yh_sub_den.push(y);
          }
        //   return (yh_sub_num,yh_sub_den);
    }
    
    // for following function we need transpose matrix of x_train and take the input one by one into it
    // external function to get delta w values 
    // need tor reset delta_w as it is pushing elements
    function get_delta_w(int[] memory xnum,int[] memory xden ) public  {
          int x; int y;
          (x,y) = get_multiply(xnum,xden,yh_sub_num,yh_sub_den);
          x = x*2;
          int n = int(yh_sub_num.length);
          y = y*n;
          del_w_num.push(x);
          del_w_den.push(y);
    }
    //external function to get delta b values
    //need to reset delta_b as it is pushing elements
    function get_delta_b() public {
        int num; int den;
        (num,den) = get_add_array(yh_sub_num,yh_sub_den);
        del_b_num = num*2;
        del_b_den = den * int(yh_sub_num.length);
        
    }
    
    //external function to get new parameters
    function get_new_parameters() public  {
        int btemp_num; int btemp_den;
        for (uint i=0;i<del_w_num.length; i++){
            del_w_num[i] = del_w_num[i]*lr_num;
            del_w_den[i] = del_w_num[i]*lr_den;
        }
        btemp_num = lr_num * del_b_num;
        btemp_den = lr_den * del_b_den;
        
        for (uint i=0;i<del_w_num.length;i++){
            (_wnum[i], _wden[i]) = get_subtraction(_wnum[i],_wden[i],del_w_num[i],del_w_den[i]);
        }
        
        (_b_num,_b_den) = get_subtraction(_b_num,_b_den,btemp_num,btemp_den);
    }
    
    
    function set_y_hat() public view returns(int[] memory, int[] memory){
        return(yh_num,yh_den);
    }
    
    function set_mse() public  view returns(int,int){
        return (mse_num,mse_den);
    }
    
    function set_y_hat_subtraction() public view returns(int[] memory, int[] memory) {
        return (yh_sub_num, yh_sub_den);
    }
    
    function set_delta_w() public view returns(int[] memory, int[] memory) {
        return (del_w_num, del_w_den);
    }
    
    function set_delta_b() public view returns(int,int) {
        return (del_b_num, del_b_den);
    }
    // function set_set_new_parameters() public returns(int) {}
    function set_weights() public view returns(int[] memory, int[] memory){
        return (_wnum,_wden);
    }
    function set_bias() public view returns(int, int){
        return (_b_num, _b_den);
    }
}

// [1,1,1,1,1,1,1,1,1,1],[1,1,1,1,1,1,1,1,1,1],1,1,1,100

