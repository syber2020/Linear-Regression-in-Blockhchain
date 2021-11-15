pragma solidity 0.7.0;

interface lcminterface{
    function lcm(uint256[] memory input)  external returns (uint256);
    function gcd(uint256[] memory input) external returns (uint256 );
}

contract main{
    address private constant lcm_address = 0x5FD6eB55D12E759a21C09eF703fe0CBa1DC9d88D;
    
    function lcm(uint256[] memory input) external returns(int256){
        uint a;
        a = lcminterface(lcm_address).lcm(input);
        return int(a);
        
    }
}