// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Import Ownable contract from OpenZeppelin
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Context.sol";
// Import the WETH (Wrapped Ether) interface
import "@uniswap/v2-periphery/contracts/interfaces/IWETH.sol";
//Guard against reentrant vunerabilities 
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
//ERC20 Interface 
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
//FairLaunchpad Contract 
import "./FairTokenLaunchpad.sol";

contract FairLaunchFactoryV1 is Ownable, ReentrancyGuard {
    uint256 public factoryFee;
    address public stakingContract;
    address public multiSigAddress;
    address public factoryToken;
    uint256 public launchpadsGenerated;
    bool public factoryOpen = false;

    mapping(address => bool) public addressIsLaunchpad;

    event LaunchPadGenerated(address indexed LaunchpaddAddress, uint256 indexed launchpadNumber, uint256 hardcap, uint256 softcap, address founderAddres);
    event multiSigWithdrawl(address withdrawSender, uint256 withdrawalAmount);

    modifier multiSigOnly() {
        require(msg.sender == multiSigAddress, "Only multiSig address can call this function");
        _; // Continue execution of the function
    }


    constructor(
        uint256 _factoryFee,
        address _stakingContract,
        address _factoryToken,
        address _multiSigAddress
    ) {
        factoryFee = _factoryFee;
        stakingContract = _stakingContract;
        factoryToken = _factoryToken;
        multiSigAddress = _multiSigAddress;
    }

    function createFairLaunchpad( 
        string memory _name,
        string memory _symbol,
        uint256 _totalSupply,
        bool _presaleLaunchpad, 
        uint256 _presaleHardcap,
        uint256 _presaleSoftcap,
        uint256 _presaleLengthBlocks,
        uint256 _presaleMaxContribution,
        uint256 _presaleMinContribution,
        uint256 _founderSupplyAllocation,
        uint256 _founderPresaleAllocation,
        uint256 _founderPoolAllocation,
        uint256 _founderStakingPoolAllocation,
        uint256 _poolLaunchDelayBlocks
    ) public payable nonReentrant {
        require(factoryOpen);
        require(msg.value == factoryFee);
        uint256 presaleMaxThreshold = (_totalSupply *50)/1000;
        uint256 presaleMinThreshold = (_totalSupply *50)/1000000;
        uint256 maxFounderAllocation = (_totalSupply *25)/1000;
        require( _presaleMaxContribution <= presaleMaxThreshold , "Max presale contribution above accepted %5 limit");
        require(_presaleMinContribution <= presaleMinThreshold , "Max presale contribution below accepted %.005 limit");
        require(_founderSupplyAllocation <= maxFounderAllocation , "Founder supply allocation above accepted 2.5% limit");
        require(_founderPresaleAllocation <= maxFounderAllocation);
        require(_founderPoolAllocation <= maxFounderAllocation);
        require(_founderStakingPoolAllocation <= maxFounderAllocation);
        require(_founderSupplyAllocation+_founderPresaleAllocation+_founderPoolAllocation+_founderStakingPoolAllocation <= 2*maxFounderAllocation);
        require(_poolLaunchDelayBlocks < 6969696969696969); //Figure out exact block conversions for base and other L2s 
        require(_presaleLengthBlocks < 6969696969696969); //Figure out exact block conversions for base and other L2s 
        require(_presaleHardcap < 69696969696969); //Fill correct val
        require(_presaleSoftcap < 69696969696969);
        FairTokenLaunchpad launchpad = new FairTokenLaunchpad(
            _name, 
            _symbol, 
            _totalSupply,
             _presaleLaunchpad, 
             _presaleHardcap,
             _presaleLengthBlocks,
             _presaleMaxContribution,
             _presaleMinContribution,
             _founderSupplyAllocation,
             _founderPresaleAllocation,
             _founderPoolAllocation,
             _founderStakingPoolAllocation,
             _poolLaunchDelayBlocks
             );
        addressIsLaunchpad[address(launchpad)] = true;
        launchpadsGenerated += 1;
        emit LaunchPadGenerated( address(launchpad), launchpadsGenerated, _presaleHardcap, _presaleSoftcap, _founderAddress);
    }

    function withdrawToMultiSig() onlyOwner public {
        require(msg.sender == owner());
        uint256 ethBal = address(this).balance;
        multiSigAddress.transfer(ethBal);
        emit MultiSigWithdrawal( msg.sender , ethBal );

        //Adjust to use multisig function to emit events for tax tracking 
    }

    function isAddressLaunchpad(address _address) public view returns(bool) {
        return addressIsLaunchpad[_address];
    }

    function setFactoryFee(uint256 _newFee) public multiSigOnly {
        factoryFee = _newFee;
    }

    function setStakingContract(uint256 _newStakingContract) public multiSigOnly {
        stakingContract = _newStakingContract;
    }

    function openFactory() public multiSigOnly {
        factoryOpen = true;
    }
}