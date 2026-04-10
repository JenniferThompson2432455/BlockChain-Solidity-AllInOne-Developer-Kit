// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MultiTokenWallet is Ownable {
    constructor() Ownable(msg.sender) {}

    function transferNative(address payable to, uint256 amount) external onlyOwner {
        require(address(this).balance >= amount, "Insufficient");
        to.transfer(amount);
    }

    function transferERC20(address token, address to, uint256 amount) external onlyOwner {
        IERC20(token).transfer(to, amount);
    }

    function transferERC721(address nft, address to, uint256 id) external onlyOwner {
        IERC721(nft).transferFrom(address(this), to, id);
    }

    function transferERC1155(address token, address to, uint256 id, uint256 amount, bytes calldata data) external onlyOwner {
        IERC1155(token).safeTransferFrom(address(this), to, id, amount, data);
    }

    receive() external payable {}
}
