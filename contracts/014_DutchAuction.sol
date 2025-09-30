// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";

interface IERC721 {
    function transferFrom(address _from, address _to, uint _nftId) external ;
}

contract DutchAuction {
    // NFT 相关信息
    IERC721 public immutable nft;
    uint public immutable nftId;

    // 持续时间
    uint private constant DURATION = 7 days;   
    // 售卖者
    address public immutable seller;
    // 起始价格
    uint public immutable startingPrice;
    // 起始时间
    uint public immutable startAt;
    // 过期时间
    uint public immutable expiredAt;
    // 步长
    uint public immutable discountRate;


    constructor(
        uint _startPrice,
        uint _discountRate,
        address _nft,
        uint _nftId
    )  {
        seller = payable(msg.sender);
        startingPrice = _startPrice;
        discountRate = _discountRate;
        startAt = block.timestamp;
        expiredAt = startAt + DURATION;

        require(startingPrice >= discountRate * DURATION, "start price < discount");

        nft = IERC721(_nft);
        nftId = _nftId;
    }

    function buy() external payable {
        require(block.timestamp <= expiredAt, "Auction expired!");

        uint price = getPrice();

        require(msg.value >= price, "ETH < price");
        nft.transferFrom(seller, msg.sender, nftId);
        uint refund = msg.value - price;
        if (refund > 0){
            payable(msg.sender).transfer(refund);
        }
    }

    function getPrice() public view returns(uint){
        uint timeElapsed = block.timestamp - startAt;
        uint discount = timeElapsed * discountRate;
        uint price = startingPrice - discount;
        return price;
    }
}
