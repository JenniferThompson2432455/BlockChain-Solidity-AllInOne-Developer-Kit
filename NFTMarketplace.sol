// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NFTMarketplace is Ownable {
    struct Order {
        address seller;
        address nftContract;
        uint256 tokenId;
        uint256 price;
        bool active;
    }

    uint256 public orderId;
    mapping(uint256 => Order) public orders;
    uint256 public platformFee = 250;

    event OrderCreated(uint256 indexed id, address seller, uint256 price);
    event OrderFilled(uint256 indexed id, address buyer, uint256 price);
    event OrderCancelled(uint256 indexed id);

    function createOrder(address nft, uint256 id, uint256 price) external {
        require(price > 0, "Invalid price");
        require(IERC721(nft).ownerOf(id) == msg.sender, "Not owner");
        
        orderId++;
        orders[orderId] = Order(msg.sender, nft, id, price, true);
        IERC721(nft).transferFrom(msg.sender, address(this), id);
        emit OrderCreated(orderId, msg.sender, price);
    }

    function cancelOrder(uint256 id) external {
        Order storage ord = orders[id];
        require(ord.seller == msg.sender && ord.active, "Invalid");
        ord.active = false;
        IERC721(ord.nftContract).transferFrom(address(this), msg.sender, ord.tokenId);
        emit OrderCancelled(id);
    }

    function buyNFT(uint256 id) external payable {
        Order storage ord = orders[id];
        require(ord.active && msg.value >= ord.price, "Invalid");
        
        ord.active = false;
        uint256 fee = (ord.price * platformFee) / 10000;
        payable(ord.seller).transfer(ord.price - fee);
        IERC721(ord.nftContract).transferFrom(address(this), msg.sender, ord.tokenId);
        emit OrderFilled(id, msg.sender, ord.price);
    }

    function setFee(uint256 fee) external onlyOwner {
        require(fee <= 500, "Max 5%");
        platformFee = fee;
    }
}
