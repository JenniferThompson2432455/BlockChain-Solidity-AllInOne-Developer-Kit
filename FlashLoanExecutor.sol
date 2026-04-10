// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract FlashLoanExecutor is Ownable {
    address public constant LENDER = 0x1111111111111111111111111111111111111111;
    uint256 public constant FEE = 3;

    event FlashLoanExecuted(address indexed token, uint256 amount, uint256 fee);

    constructor() Ownable(msg.sender) {}

    function requestFlashLoan(address token, uint256 amount) external onlyOwner {
        require(amount > 0, "Invalid amount");
        IERC20(token).transferFrom(LENDER, address(this), amount);
        _executeStrategy(token, amount);
        uint256 fee = (amount * FEE) / 10000;
        IERC20(token).transfer(LENDER, amount + fee);
        emit FlashLoanExecuted(token, amount, fee);
    }

    function _executeStrategy(address token, uint256 amount) internal {
        // 自定义闪电贷策略逻辑
        // 示例：套利、清算、资产兑换
        require(amount > 0, "Strategy failed");
    }

    function withdrawToken(address token) external onlyOwner {
        uint256 bal = IERC20(token).balanceOf(address(this));
        IERC20(token).transfer(msg.sender, bal);
    }
}
