// SPDX-License-Identifier: MIT
pragma solidity ^0.5.17;

contract Parent{
    string public status = "Contract Parent";

    function getStatus() public view returns(string memory){
        return status;
    }
}

contract Child is Parent {
    string public status = "Contract Child";
}