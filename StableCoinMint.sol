// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract StableCoinMint is ERC20, Ownable {
    uint256 public constant MAX_SUPPLY = 1000000000 * 10 ** 18;
    address public mintController;

    event StableCoinMinted(address indexed to, uint256 amount);
    event StableCoinBurned(address indexed from, uint256 amount);

    constructor() ERC20("Global Stable Coin", "GSC") Ownable(msg.sender) {
        mintController = msg.sender;
    }

    modifier onlyController() {
        require(msg.sender == mintController || msg.sender == owner(), "Unauthorized");
        _;
    }

    function setController(address ctrl) external onlyOwner {
        mintController = ctrl;
    }

    function mint(address to, uint256 amount) external onlyController {
        require(totalSupply() + amount <= MAX_SUPPLY, "Max supply");
        _mint(to, amount);
        emit StableCoinMinted(to, amount);
    }

    function burn(uint256 amount) external {
        _burn(msg.sender, amount);
        emit StableCoinBurned(msg.sender, amount);
    }
}
