pragma solidity ^0.4.21;

contract GCDLCMCache {


    mapping (bytes32 => uint256) public cache;
    enum CacheType { GCD, LCM }


    function gcd(uint256[] input) 
        public 
        returns (uint256 result)
    {
        bytes32 key = keccak256(CacheType.GCD, input);
        result = cache[key];
        
        if (result == 0) {
            result = _gcd(input);
            cache[key] = result;
        }
        
    }

    function gcd(uint256 a, uint256 b) 
        public 
        returns (uint256 result)
    {
        bytes32 key = keccak256(CacheType.GCD, a, b);
        result = cache[key];
        
        if (result == 0) {
            result = _gcd(a, b);
            cache[key] = result;
        }
        
    }

    function lcm(uint256[] input) 
        public 
        returns (uint256 result)
    {
        bytes32 key = keccak256(CacheType.LCM, input);
        result = cache[key];
        
        if (result == 0) {
            result = _lcm(input);
            cache[key] = result;
        }
    }


    function _gcd(uint256 a, uint256 b) 
        internal 
        returns (uint256)
    {
        uint256 _a = a;
        uint256 _b = b;
        uint256 temp;
        while (_b > 0) {
            temp = _b;
            _b = _a % _b; // % is remainder
            _a = temp;
        }
        return _a;
    }

    function _lcm(uint256 a, uint256 b) 
        internal 
        returns (uint256)
    {
        return a * (b / gcd(a, b));
    }

    function _gcd(uint256[] input) 
        internal 
        returns (uint256)
    {
        uint256 result = input[0];
        uint256 len = input.length;
        for (uint256 i = 1; i < len; i++) {
            result = gcd(result, input[i]);
        }
        return result;
    }

    function _lcm(uint256[] input) 
        internal 
        returns (uint256)
    {
        uint256 result = input[0];
        uint256 len = input.length;
        for (uint256 i = 1; i < len; i++) {
            result = _lcm(result, input[i]);
        }
        return result;
    }

}