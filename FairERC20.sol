// SPDX-License-Identifier: MIT

pragma solidity ^0.8.25;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract FairERC20 is ERC20 {
    constructor(uint256 _totalSupply, string memory name, string memory symbol ) ERC20(name, symbol) {
        _mint(msg.sender, _totalSupply * 10**decimals());
    }
}