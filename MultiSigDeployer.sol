// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Import Ownable contract from OpenZeppelin
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "./FairLaunchFactory.sol";
import "./DegeneratorStaking.sol";
import "./FairERC20.sol";



//This is only multisig for changes made to the factory 
//Disbursals handled by owner 

contract MultisigWallet is Ownable {

    address[] private execAddresses;
    mapping(address => uint256) private revenueShares;

    uint256 private totalRevenueShares;
    uint256 private numConfirmationsRequired;
    uint256 private currentNumConfirmations; 
    uint256 public currentVoteStartBlock;

    uint256 public votedFactoryFee;
    address public stakingContractAddress;
    address public tokenContract; 

    FairLaunchFactoryV1 public fairLaunchFactory;
    DegeneratorStaking public stakingContract;
    address public fairLaunchFactoryAddress;

    uint256 public launchTime; 

    FairERC20 public degenerator;
    address public degeneratorAddress;


    struct Transaction {
        address destination;
        uint256 value;
        bool executed;
    }

    event Deposit(address indexed depositor, uint256 amount, uint256 timeStaked);
    event Withdrawal(address indexed staker, uint256 amount);

    constructor(address[] memory _owners, uint256[] memory _startingSplits , uint256 _numConfirmationsRequired, uint256 _launchTime) Ownable(msg.sender) {
        require(_owners.length > 0, "Owners required");
        require(_numConfirmationsRequired > 0 && _numConfirmationsRequired <= _owners.length, "Invalid number of confirmations");
        execAddresses = _owners;
        for (uint256 i = 0; i < _owners.length; i++) {
            revenueShares[_owners[i]] = _startingSplits[i];
        }
        numConfirmationsRequired = _numConfirmationsRequired;
        launchTime = _launchTime;
    }
    
    function executeDispursal(uint256 _amount) public payable onlyOwner {
        require( address(this).balance <= _amount);
        //Shares will be represented as a number such that N / 1000 = Rev Split % 
        for (uint256 i = 0; i < execAddresses.length; i++) {
            address currentAddress = execAddresses[i];
            uint256 withdrawShare = (_amount * revenueShares[currentAddress]) / 1000;
            payable(currentAddress).transfer(withdrawShare);
            emit Withdrawal(_msgSender(), _amount);
        }
    }

    function launchDegeneratorFactory(uint256 _factoryFee ,uint256 _factoryBaseFee, address _stakingContract, address _degeneratorToken) public onlyOwner {
        require(stakingContractAddress != address(0) && tokenContract != address(0) && block.timestamp > launchTime );
        fairLaunchFactory = new FairLaunchFactoryV1(_factoryFee, _factoryBaseFee, _stakingContract, _degeneratorToken, address(this));
        fairLaunchFactoryAddress = address(fairLaunchFactory);
    }

    function launchStakingContract(uint256 _minimumStakeAmount, uint256 _rewardBlackoutPeriod) public onlyOwner {
        require(degeneratorAddress != address(0) && block.timestamp > launchTime);
        stakingContract = new DegeneratorStaking(msg.sender , tokenContract,_minimumStakeAmount,_rewardBlackoutPeriod);
    }

    function setDegeneratorAddress( address _address ) public onlyOwner {
        tokenContract = _address;
    }

    //Proposed voting mechanisms: factory Fee change, factory staking contract change, staking contract pausing, staking contract factory change 
    //For a proposed vote:
    //reset current confirmations 
    //hold value 
    //function to close vote 
    //function to execute after successful vote 
    //Owner of multisig wallet has veto power, if they have not confirmed then vote fails 

    receive() external payable { 
        emit Deposit(msg.sender, msg.value, block.number);
     }

}
