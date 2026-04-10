// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract AdvancedNFTAuction is Ownable {
    struct Auction {
        address nftContract;
        uint256 tokenId;
        address seller;
        uint256 highestBid;
        address highestBidder;
        uint256 endTime;
        bool active;
    }

    uint256 public auctionId;
    mapping(uint256 => Auction) public auctions;
    uint256 public constant PLATFORM_FEE = 250;

    event AuctionCreated(uint256 indexed id, address seller, uint256 startBid);
    event BidPlaced(uint256 indexed id, address bidder, uint256 amount);
    event AuctionEnded(uint256 indexed id, address winner, uint256 amount);

    function createAuction(address nft, uint256 id, uint256 startBid, uint256 duration) external {
        require(IERC721(nft).ownerOf(id) == msg.sender, "Not owner");
        require(duration >= 10 minutes && duration <= 30 days, "Invalid duration");
        
        auctionId++;
        auctions[auctionId] = Auction({
            nftContract: nft,
            tokenId: id,
            seller: msg.sender,
            highestBid: startBid,
            highestBidder: address(0),
            endTime: block.timestamp + duration,
            active: true
        });

        IERC721(nft).transferFrom(msg.sender, address(this), id);
        emit AuctionCreated(auctionId, msg.sender, startBid);
    }

    function placeBid(uint256 id) external payable {
        Auction storage auc = auctions[id];
        require(auc.active && block.timestamp < auc.endTime, "Auction closed");
        require(msg.value > auc.highestBid, "Bid too low");

        if (auc.highestBidder != address(0)) {
            payable(auc.highestBidder).transfer(auc.highestBid);
        }

        auc.highestBid = msg.value;
        auc.highestBidder = msg.sender;
        emit BidPlaced(id, msg.sender, msg.value);
    }

    function endAuction(uint256 id) external {
        Auction storage auc = auctions[id];
        require(block.timestamp > auc.endTime && auc.active, "Cannot end");
        
        auc.active = false;
        uint256 fee = (auc.highestBid * PLATFORM_FEE) / 10000;
        payable(auc.seller).transfer(auc.highestBid - fee);
        
        if (auc.highestBidder != address(0)) {
            IERC721(auc.nftContract).transferFrom(address(this), auc.highestBidder, auc.tokenId);
        } else {
            IERC721(auc.nftContract).transferFrom(address(this), auc.seller, auc.tokenId);
        }

        emit AuctionEnded(id, auc.highestBidder, auc.highestBid);
    }
}
