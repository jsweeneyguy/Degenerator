// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Import Ownable contract from OpenZeppelin
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "./FairLaunchFactory.sol";

//This is only multisig for changes made to the factory 
//Disbursals handled by owner 

contract MultisigWallet is Ownable {

    address[] private execAddresses;
    mapping(address => uint256) private revenueShares;

    uint256 private totalRevenueShares;
    uint256 private numConfirmationsRequired;
    uint256 private currentNumConfirmations; 
    uint256 public currentVoteStartBlock;

    FairLaunchFactoryV1 public fairLaunchFactory;
    address public fairLaunchFactoryAddress;

    struct Transaction {
        address destination;
        uint256 value;
        bool executed;
    }

    event Deposit(address indexed depositor, uint256 amount, uint256 timeStaked);
    event Withdrawn(address indexed staker, uint256 amount);

    constructor(address[] memory _owners, uint256[] memory _startingSplits , uint256 _numConfirmationsRequired, address _factoryAddress) {
        require(_owners.length > 0, "Owners required");
        require(_numConfirmationsRequired > 0 && _numConfirmationsRequired <= _owners.length, "Invalid number of confirmations");
        owners = _owners;
        for (i = 0; i < _owners.length; i++) {
            revenueShares[_owners[i]] = _startingSplits[i];
        }
        numConfirmationsRequired = _numConfirmationsRequired;
        fairLaunchFactory = FairLaunchFactoryV1(_factoryAddress);
    }
    
    function executeDispursal(uint256 _amount) public onlyOwner {
        require( address(this).balance <= _amount);
        //Shares will be represented as a number such that N / 1000 = Rev Split % 
        for (i = 0; i < execAddresses.length; i++) {
            address currentAddress = execAddresses[i];
            uint256 withdrawShare = (_amount * revenueShares[currentAddress]) / 1000;
            currentAddress.transfer(withdrawShare);
            emit Withdrawn(_msgSender(), amount);
        }
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
