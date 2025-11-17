// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

contract PrivatePassword{
    address private owner;
    string private password;

    modifier onlyOwner(){
        require(msg.sender == owner);
        _;
    }

    constructor(){
        owner = msg.sender;
    }

    function setPassword(string memory newPassword) external onlyOwner{
        password = newPassword;
    }

    function getPassword() external onlyOwner view returns(string memory){
        return password;
    }
}