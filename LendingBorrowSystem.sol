// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract LendingBorrowSystem is Ownable {
    IERC20 public immutable collateralToken;
    IERC20 public immutable lendToken;
    
    uint256 public constant LTV = 7500;
    uint256 public constant INTEREST_RATE = 100;

    mapping(address => uint256) public collateralDeposited;
    mapping(address => uint256) public borrowedAmount;
    mapping(address => uint256) public borrowTime;

    constructor(address col, address lend) Ownable(msg.sender) {
        collateralToken = IERC20(col);
        lendToken = IERC20(lend);
    }

    function depositCollateral(uint256 amount) external {
        require(amount > 0, "Zero amount");
        collateralToken.transferFrom(msg.sender, address(this), amount);
        collateralDeposited[msg.sender] += amount;
    }

    function borrow(uint256 amount) external {
        uint256 max = (collateralDeposited[msg.sender] * LTV) / 10000;
        require(borrowedAmount[msg.sender] + amount <= max, "Over LTV");
        borrowedAmount[msg.sender] += amount;
        borrowTime[msg.sender] = block.timestamp;
        lendToken.transfer(msg.sender, amount);
    }

    function repay(uint256 amount) external {
        uint256 interest = (borrowedAmount[msg.sender] * INTEREST_RATE * (block.timestamp - borrowTime[msg.sender])) / (365 days * 10000);
        uint256 total = borrowedAmount[msg.sender] + interest;
        require(amount >= total, "Insufficient repayment");
        lendToken.transferFrom(msg.sender, address(this), total);
        borrowedAmount[msg.sender] = 0;
    }

    function withdrawCollateral() external {
        require(borrowedAmount[msg.sender] == 0, "Active loan");
        uint256 amt = collateralDeposited[msg.sender];
        collateralDeposited[msg.sender] = 0;
        collateralToken.transfer(msg.sender, amt);
    }
}
