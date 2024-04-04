// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Import Ownable contract from OpenZeppelin
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
//ERC20 Interface 
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
//Guard against reentrant vunerabilities 
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";


contract DegeneratorStaking is Context, ReentrancyGuard {
    address public factoryAddress;
    address public multiSigAddress;
    address public tokenAddress;
    uint256 public minimumStakeAmount;

    struct Stake {
        uint256 amount;
        uint256 timeStaked;
        bool withdrawn;
        bool activeDeposit;
    }

    struct ERC20Supply {
        uint256 supply;
        uint256 timeSupplied;
    }

    modifier multiSigOnly() {
        require(msg.sender == multiSigAddress, "Only multiSig address can call this function");
        _; // Continue execution of the function
    }

    mapping(address => Stake) private addressStake;
    mapping(address => ERC20Supply) public erc20Supplies;
    mapping(address => mapping(address => bool)) public addressWithdrewERC20Reward;

    uint256 public rewardBlackoutPeriod;

    event Staked(address indexed staker, uint256 amount, uint256 timeStaked);
    event Withdrawn(address indexed staker, uint256 amount);

    constructor(address _factoryAddress, address _multiSigAddress , address _tokenAddress, uint256 _minimumStakeAmount, uint256 _rewardBlackoutPeriod) {
        factoryAddress = _factoryAddress;
        multiSigAddress = _multiSigAddress;
        tokenAddress = _tokenAddress;
        rewardBlackoutPeriod = _rewardBlackoutPeriod;
        minimumStakeAmount = _minimumStakeAmount;
    }

    function stakeDegnerator(uint256 _amount) public nonReentrant {
        IERC20 token = IERC20(tokenAddress);
        require(_amount > minimumStakeAmount, "Amount must be greater than zero");
        require(token.transferFrom(_msgSender(), address(this), _amount), "Transfer failed");
        require(!addressStake[_msgSender()].activeDeposit);

        addressStake[_msgSender()].amount += _amount;
        addressStake[_msgSender()].timeStaked = block.timestamp;

        emit Staked(_msgSender(), _amount, block.timestamp);

    }

    function withdrawDegenerator() public nonReentrant {
        require(addressStake[_msgSender()].amount > 0, "No stake found");
        require(!addressStake[_msgSender()].withdrawn, "Stake already withdrawn");
        IERC20 token = IERC20(tokenAddress);
        uint256 amount = addressStake[_msgSender()].amount;
        addressStake[_msgSender()].withdrawn = true;
        addressStake[_msgSender()].activeDeposit = false;

        require(token.transfer(_msgSender(), amount), "Transfer failed");
        emit Withdrawn(_msgSender(), amount);
    }

    /*
    function withdrawRewards() {

    }
    */


}

