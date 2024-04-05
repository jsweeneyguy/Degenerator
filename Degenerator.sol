// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Import Ownable contract from OpenZeppelin
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Context.sol";
// Import the FairToken contract
import "./FairERC20.sol";
//Guard against reentrant vunerabilities 
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract Degenerator is ERC20 {
    constructor(address _presaleContract, uint256 _totalSupply) ERC20("$DGEN" , "DEGENERATOR") {
        _mint(_presaleContract, _totalSupply);
    }
}

