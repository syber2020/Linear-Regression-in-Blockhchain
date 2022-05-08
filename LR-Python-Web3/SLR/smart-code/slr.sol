pragma solidity 0.7.0;

contract srl{
    int xmean; int ymean; int xvar; int yvar; int covar;


    int B0; int B1; int pred;
    function get_mean(int[] memory x, int[] memory y) public {
        int sum1=0; int sum2=0;
        for(uint i =0;i<x.length; i++){
            sum1 = sum1+ x[i];
            sum2 = sum2+ y[i];
        }
        xmean =sum1/int(x.length);
        ymean = sum2/int(y.length);
    }
    function get_variance (int[] memory x, int[] memory y) public{
        int sum1; int sum2;
        for (uint i=0;i<x.length; i++){
            sum1 = sum1+(x[i]-xmean)**2;
            sum2 = sum2+(y[i]-ymean)**2;
        }
        xvar = sum1;
        yvar = sum2;
    }
    function get_covariance(int[] memory x, int[] memory y) public{
        int sum;
        for (uint i =0; i<x.length; i++){
            sum = sum + (x[i]-xmean) * (y[i]-ymean);
        }
        covar = sum;
    }

    function get_coefficient(int[] memory x, int[] memory y) public{
        B1 = covar / xvar;
        B0 = ymean - B1*xmean;
    }

    function get_predict(int x) public{
        pred = B0 + B1 * x;
    }
    function set_mean() public returns(int,int){ return (xmean,ymean); }
    function set_variance() public returns(int,int){ return (xvar,yvar);}
    function set_covariance() public returns(int){ return covar;}
    function set_coefficient() public returns(int, int ){ return (B0, B1);}
    function set_predict() public returns(int){ return pred;}
}
