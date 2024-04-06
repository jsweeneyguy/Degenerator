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
    uint256[] private revenueShares;
    mapping(address => bool) private isExec;

    FairLaunchFactoryV1 public fairLaunchFactory;
    DegeneratorStaking public stakingContract;
    address public fairLaunchFactoryAddress;

    uint256 public launchTime; 

    IERC20 public degenerator;

    mapping(bytes4 => VoteData) private factoryConfigurationVotes;

    modifier onlyExec() {
        require(isExec[msg.sender]);
        _;
    }


    struct VoteData {
        mapping(address => bool) hasVoted;
        mapping(uint256 => uint256) votes;
    }


    struct Transaction {
        address destination;
        uint256 value;
        bool executed;
    }

    event Deposit(address indexed depositor, uint256 amount, uint256 timeStaked);

    constructor(address[] memory _owners, uint256[] memory _startingSplits , uint256 _launchTime) Ownable(msg.sender) {
        require(_owners.length > 0, "Owners required");
        execAddresses = _owners;
        revenueShares = _startingSplits;
        launchTime = _launchTime;
    }
    
    function executeDispursal(uint256 _amount) public payable onlyOwner {
        require( address(this).balance <= _amount);
        //Shares will be represented as a number such that N / 1000 = Rev Split % 
        for (uint256 i = 0; i < execAddresses.length; i++) {
            address currentAddress = execAddresses[i];
            uint256 withdrawShare = (_amount * revenueShares[i]) / 1000;
            payable(currentAddress).transfer(withdrawShare);
        }
    }

    function launchDegeneratorFactory(uint256 _factoryFee ,uint256 _factoryBaseFee, address _stakingContract, address _degeneratorToken) public onlyOwner {
        require(address(stakingContract) != address(0) && address(degenerator) != address(0) && block.timestamp > launchTime );
        fairLaunchFactory = new FairLaunchFactoryV1(_factoryFee, _factoryBaseFee, _stakingContract, _degeneratorToken, address(this));
        fairLaunchFactoryAddress = address(fairLaunchFactory);
    }

    function launchStakingContract(uint256 _minimumStakeAmount, uint256 _rewardBlackoutPeriod) public onlyOwner {
        require(address(degenerator) != address(0) && block.number > launchTime);
        stakingContract = new DegeneratorStaking(msg.sender , address(degenerator),_minimumStakeAmount,_rewardBlackoutPeriod);
    }

    function setDegeneratorAddress( address _address ) public onlyOwner {
        degenerator = IERC20(_address);
    }

    function setMinimumStakeAmount(uint256 _amount) public onlyOwner {
        require(isApproved(getMinStakeSignature(), _amount));
        stakingContract.setMinimumStakeAmount(_amount);
    }

    function setRewardBlackoutPeriod(uint256 _length) public onlyOwner {
        require(isApproved(getBlackoutSignature(), _length));
        stakingContract.setRewardBlackoutPeriod(_length);
    }

    function setFactoryBaseFee(uint256 _amount) public onlyOwner {
        fairLaunchFactory.setFactoryBaseFee(_amount);
    }

    function setFactoryFee(uint256 _amount) public onlyOwner {
        fairLaunchFactory.setFactoryFee(_amount);
    }    

    function closeFactory(bool _closed) public onlyOwner {
        fairLaunchFactory.closeFactory(_closed);
    }

    function withdrawETHfromFactory() public onlyOwner {
        require(address(fairLaunchFactory).balance > 0);
        fairLaunchFactory.withdrawETHToMultiSig();
    }

    function withdrawTokensFromFactory(address[] calldata _tokenAddresses) public onlyOwner {
        fairLaunchFactory.withdrawTokensToMultiSig(_tokenAddresses);
    }

    function isApproved(bytes4 _function, uint256 _value) public view returns (bool) {
        VoteData storage voteData = factoryConfigurationVotes[_function];
        return (voteData.votes[_value] * 3 > execAddresses.length * 2);
    }

    function vote(bytes4 _function, uint256 _value) public onlyExec {
        VoteData storage voteData = factoryConfigurationVotes[_function];
        require(!voteData.hasVoted[msg.sender], "Already voted");
        voteData.votes[_value]++;
        voteData.hasVoted[msg.sender] = true;
    }

    function getMinStakeSignature() public pure returns (bytes4) {
        // Example function signature: setMinimumStakeAmount(uint256)
        return this.setMinimumStakeAmount.selector;
    }

    function getBlackoutSignature() public pure returns (bytes4) {
        // Example function signature: setMinimumStakeAmount(uint256)
        return this.setRewardBlackoutPeriod.selector;
    }

    function getBaseFeeSignature() public pure returns (bytes4) {
        // Example function signature: setMinimumStakeAmount(uint256)
        return this.setFactoryBaseFee.selector;
    }

    function getFeeSignature() public pure returns (bytes4) {
        return this.setFactoryFee.selector;
    }

    receive() external payable { 
        emit Deposit(msg.sender, msg.value, block.number);
     }

}
