// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";

contract OnChainLottery is Ownable {
    uint256 public ticketPrice = 0.01 ether;
    uint256 public maxTickets = 1000;
    address[] public participants;
    address public winner;
    bool public lotteryEnded;

    event TicketPurchased(address indexed buyer, uint256 amount);
    event WinnerSelected(address indexed winner, uint256 prize);

    constructor() Ownable(msg.sender) {}

    function buyTickets(uint256 amount) external payable {
        require(!lotteryEnded, "Lottery ended");
        require(amount > 0 && participants.length + amount <= maxTickets, "Invalid amount");
        require(msg.value == ticketPrice * amount, "Wrong payment");

        for (uint256 i = 0; i < amount; i++) {
            participants.push(msg.sender);
        }
        emit TicketPurchased(msg.sender, amount);
    }

    function drawWinner() external onlyOwner {
        require(!lotteryEnded && participants.length > 0, "Cannot draw");
        uint256 randomIndex = uint256(keccak256(abi.encodePacked(block.timestamp, block.prevrandao, participants.length))) % participants.length;
        winner = participants[randomIndex];
        lotteryEnded = true;
        payable(winner).transfer(address(this).balance * 95 / 100);
        emit WinnerSelected(winner, address(this).balance * 95 / 100);
    }

    function resetLottery() external onlyOwner {
        delete participants;
        winner = address(0);
        lotteryEnded = false;
    }

    function getParticipantCount() external view returns (uint256) {
        return participants.length;
    }
}
