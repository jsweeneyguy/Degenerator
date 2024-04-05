// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Import Ownable contract from OpenZeppelin
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
//ERC20 Interface 
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
//Guard against reentrant vunerabilities 
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./IFairLaunchFactory.sol";

contract DegeneratorStaking is Context, ReentrancyGuard {
    address public multiSigAddress;
    address public tokenAddress;
    uint256 public minimumStakeAmount;
    uint256 public rewardBlackoutPeriod;
    IFairLaunchFactoryV1 public factory;

    uint256 public degeneratorStakingPool;
    uint256 public degeneratorStakers;

    bool public stakingOpen;
    
    modifier onlyStaker() {
        require(addressStake[msg.sender].activeDeposit);
        _;
    }

    modifier launchpadOnly() {
        require(factory.isAddressLaunchpad(msg.sender) == true);
        _; // Continue execution of the function
    }

    modifier multiSigOnly() {
        require(msg.sender == multiSigAddress, "Only multiSig address can call this function");
        _; // Continue execution of the function
    }

    struct Stake {
        uint256 amount;
        uint256 blockStaked;
        bool withdrawn;
        bool activeDeposit;
    }

    struct ERC20Supply {
        uint256 poolSupply;
        uint256 blockSupplied;
        uint256 remainingPoolSupply;
        uint256 degeneratorPoolSizeAtTime; 
        bool registered;
    }

    mapping(address => Stake) private addressStake;
    mapping(address => ERC20Supply) public erc20Supplies;
    mapping(address => mapping(address => bool)) public addressWithdrewERC20Reward;

    event degeneratorStaked(address indexed staker, uint256 amount, uint256 blockStaked);
    event degeneratorWithdrawn(address indexed staker, uint256 amount);

    constructor( address _multiSigAddress , address _tokenAddress, uint256 _minimumStakeAmount, uint256 _rewardBlackoutPeriod) {
        multiSigAddress = _multiSigAddress;
        tokenAddress = _tokenAddress;
        rewardBlackoutPeriod = _rewardBlackoutPeriod;
        minimumStakeAmount = _minimumStakeAmount;
        degeneratorStakingPool = 0;
        degeneratorStakers = 0;
    }

    function stakeDegnerator(uint256 _amount) public nonReentrant {
        IERC20 token = IERC20(tokenAddress);
        require(stakingOpen);
        require(_amount > minimumStakeAmount, "Amount must be greater than zero");
        require(token.transferFrom(_msgSender(), address(this), _amount), "Transfer failed");
        require(!addressStake[_msgSender()].activeDeposit);

        addressStake[_msgSender()].amount += _amount;
        addressStake[_msgSender()].blockStaked = block.number;
        degeneratorStakingPool += _amount;
        degeneratorStakers += 1;

        emit degeneratorStaked(_msgSender(), _amount, block.number);

    }

    function withdrawDegenerator() public nonReentrant {
        require(addressStake[_msgSender()].amount > 0, "No stake found");
        require(!addressStake[_msgSender()].withdrawn, "Stake already withdrawn");
        IERC20 token = IERC20(tokenAddress);
        uint256 amount = addressStake[_msgSender()].amount;
        addressStake[_msgSender()].withdrawn = true;
        addressStake[_msgSender()].activeDeposit = false;

        require(token.transfer(_msgSender(), amount), "Transfer failed");
        degeneratorStakingPool -= amount;
        degeneratorStakers -= 1;
        addressStake[msg.sender].amount = 0;
        addressStake[_msgSender()].blockStaked = 0;
        emit degeneratorWithdrawn(_msgSender(), amount);
    }

    function registerERC20Supply(address _tokenAddress, uint256 _poolSupply) public nonReentrant {
        require(IERC20(_tokenAddress).balanceOf(address(this)) == _poolSupply);
        require(!erc20Supplies[_tokenAddress].registered);
        erc20Supplies[_tokenAddress].blockSupplied = block.number;
        erc20Supplies[_tokenAddress].poolSupply = _poolSupply; 
        erc20Supplies[_tokenAddress].remainingPoolSupply = _poolSupply; 
        erc20Supplies[_tokenAddress].degeneratorPoolSizeAtTime = degeneratorStakingPool;
    }

    
    function withdrawRewards(address[] calldata _tokenAddresses) public onlyStaker nonReentrant {
        for (uint256 i = 0; i < _tokenAddresses.length; i++) {
            require(getTokenEligibility(_tokenAddresses[i], msg.sender));
            require(!addressWithdrewERC20Reward[_tokenAddresses[i]][msg.sender]);
            uint256 tokenReward = getTokenReward(_tokenAddresses[i], msg.sender);
            addressWithdrewERC20Reward[_tokenAddresses[i]][msg.sender] = true;
            IERC20(_tokenAddresses[i]).transfer(msg.sender, tokenReward);
        }
    }

    function getTokenEligibility(address _tokenAddress, address _account) public view returns(bool) {
        require(erc20Supplies[_tokenAddress].registered);
        return (addressStake[_account].blockStaked + rewardBlackoutPeriod) <= erc20Supplies[_tokenAddress].blockSupplied;
    }

    function getTokenReward(address _tokenAddress, address _account) public view returns(uint256) {
        require(getTokenEligibility(_tokenAddress, _account));
        uint256 poolSupply = erc20Supplies[_tokenAddress].poolSupply;
        uint256 poolPortionAtTime = addressStake[_account].amount / erc20Supplies[_tokenAddress].degeneratorPoolSizeAtTime;
        uint256 tokenReward = poolPortionAtTime * poolSupply;
        return tokenReward;
    }

    function setMinimumStakeAmount(uint256 _amount) public multiSigOnly {
        require(_amount > 0); 
        minimumStakeAmount = _amount;
    }

    function setRewardBlackoutPeriod(uint256 _length) public multiSigOnly {
        require(_length > 0); 
        rewardBlackoutPeriod = _length;
    }

}

