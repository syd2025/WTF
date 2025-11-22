// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.5.0
pragma solidity ^0.8.24;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {ERC721URIStorage} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract MyToken is ERC721URIStorage, Ownable {
    constructor() ERC721("MyToken", "MTK") Ownable(msg.sender){}
    
    uint256 public tokenId; 
    string constant TOKEN_URI = "https://ipfs.io/ipfs/QmYuKY45Aq87LeL1R5dhb1hqHLp6ZFbJaCP8jxqKM1MX6y/babe_ruth_1.json";

    function safeMint(address to) public{
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, TOKEN_URI);
        tokenId++;
    }

}
