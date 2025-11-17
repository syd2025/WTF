// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

contract Overflow {
    uint8 public count = 255;

    function increment() public {
        unchecked {
            count += 1;
        }
    }

    function incrementAlt() public view returns(uint8 result){
        assembly {
            result := add(sload(count.slot),1)
        }
    }
}

contract Underflow {
    uint8 public count = 0;

    function decrement() public {
        unchecked{
            count -= 1;
        }
    }

    function decrementAlt() public view returns(uint8 result){
        assembly {
            result := sub(sload(count.slot), 1)
        }
    }
}