pragma solidity ^0.8.0;

library Strings {
    function toString(address x) internal pure returns (string memory) {
        bytes32 value = bytes32(uint256(uint160(x)));
        bytes memory alphabet = "0123456789abcdef";

        bytes memory str = new bytes(42);
        str[0] = "0";
        str[1] = "x";

        for (uint i = 0; i < 20; i++) {
            str[2+i*2] = alphabet[uint(uint8(value[i+12]))];
          str[3+i*2] = alphabet[uint(uint8(value[i+12])+uint8(1))];
        }
        return string(str);
    }
}