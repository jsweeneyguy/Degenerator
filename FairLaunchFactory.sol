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
    uint256 public factoryBaseFee;
    address public stakingContract;
    address public multiSigAddress;
    address public factoryToken;
    uint256 public launchpadsGenerated;
    bool public factoryOpen = false;

    mapping(address => bool) public isFactoryToken;
    mapping(address => uint256) public stakingContractFactoryTokenAllocations;
    mapping(address => bool) public addressIsLaunchpad;

    event LaunchPadGenerated(address indexed LaunchpaddAddress, uint256 indexed launchpadNumber, uint256 hardcap, uint256 softcap, address founderAddres);
    event multiSigEthWithdrawal(address withdrawSender, uint256 withdrawalAmount);
    event multiSigTokenWithdrawal(address indexed tokenAddress, uint256 withdrawalAmount);
    event FactoryTokenRegistered(address indexed tokenAddress);
    event FactoryFeeSet(uint256 newFee);
    event FactoryBaseFeeSet(uint256 newBaseFee);
    event StakingContractSet(address indexed newStakingContract);
    event FactoryClosed(bool factoryOpen);

    modifier multiSigOnly() {
        require(msg.sender == multiSigAddress, "Only multiSig address can call this function");
        _; // Continue execution of the function
    }

    modifier launchpadOnly() {
        require(addressIsLaunchpad[msg.sender] == true);
        _; // Continue execution of the function
    }

    constructor(
        uint256 _factoryFee,
        uint256 _factoryBaseFee, 
        address _stakingContract,
        address _factoryToken,
        address _multiSigAddress
    ) Ownable(msg.sender) {
        factoryFee = _factoryFee;
        factoryBaseFee = _factoryBaseFee;
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
        uint256 _founderSupplyAllocation
    ) public payable nonReentrant {
        require(factoryOpen);
        require(msg.value == factoryBaseFee);
        uint256 presaleMaxThreshold = (_totalSupply *50)/1000;
        uint256 presaleMinThreshold = (_totalSupply *50)/1000000;
        uint256 maxFounderAllocation = (_totalSupply *25)/1000;
        require( _presaleMaxContribution <= presaleMaxThreshold , "Max presale contribution above accepted %5 limit");
        require(_presaleMinContribution <= presaleMinThreshold , "Max presale contribution below accepted %.005 limit");
        require(_founderSupplyAllocation <= maxFounderAllocation , "Founder supply allocation above accepted 2.5% limit");
        require(_presaleLengthBlocks < 6969696969696969); //Figure out exact block conversions for base and other L2s 
        require(_presaleHardcap < 69696969696969); //Fill correct val
        require(_presaleSoftcap < 69696969696969);
        FairTokenLaunchpad launchpad = new FairTokenLaunchpad(
            _name, 
            _symbol, 
            _totalSupply,
             _presaleLaunchpad, 
             _presaleHardcap,
             _presaleSoftcap,
             _presaleLengthBlocks,
             _presaleMaxContribution,
             _presaleMinContribution,
             _founderSupplyAllocation
             );
        launchpad.transferOwnership(msg.sender);
        addressIsLaunchpad[address(launchpad)] = true;
        launchpadsGenerated += 1;
        emit LaunchPadGenerated( address(launchpad), launchpadsGenerated, _presaleHardcap, _presaleSoftcap, msg.sender);
    }

    function withdrawETHToMultiSig() multiSigOnly public {
        require(msg.sender == owner());
        uint256 ethBal = address(this).balance;
        payable(multiSigAddress).transfer(ethBal);
        emit multiSigEthWithdrawal( msg.sender , ethBal );

        //Adjust to use multisig function to emit events for tax tracking 
    }

    function withdrawTokensToMultiSig(address[] calldata _tokenAddresses) multiSigOnly public {
        require(msg.sender == owner());
        for (uint256 i = 0; i < _tokenAddresses.length ; i++) {
            IERC20 tokenInterface = IERC20(_tokenAddresses[i]);
            uint256 tokenBal = tokenInterface.balanceOf(address(this));
            tokenInterface.transfer(multiSigAddress , tokenBal);
            emit multiSigTokenWithdrawal( _tokenAddresses[i] , tokenBal );
        }    
    }


    function registerFactoryToken(address _address, uint256 _stakingContractAllocation) public launchpadOnly {
        isFactoryToken[_address] = true;
        stakingContractFactoryTokenAllocations[_address] = _stakingContractAllocation;
        emit FactoryTokenRegistered(_address);
    }

    function setFactoryFee(uint256 _newFee) public multiSigOnly {
        factoryFee = _newFee;
        emit FactoryFeeSet(_newFee);
    }

    function setFactoryBaseFee(uint256 _newFee) public multiSigOnly {
        factoryBaseFee = _newFee;
        emit FactoryBaseFeeSet(_newFee);
    }

    function setStakingContract(address _newStakingContract) public multiSigOnly {
        stakingContract = _newStakingContract;
        emit StakingContractSet(_newStakingContract);
    }

    function closeFactory(bool _factoryOpen) public multiSigOnly {
        factoryOpen = _factoryOpen;
        emit FactoryClosed(_factoryOpen);
    }

    function isAddressLaunchpad(address _address) public view returns(bool) {
        return addressIsLaunchpad[_address];
    }

    function isAddressFactoryToken(address _address) public view returns(bool) {
        return isFactoryToken[_address];
    }

    function getTokenStakingContractAllocation(address _address) public view returns (uint256) {
        require(isFactoryToken[_address]);
        return stakingContractFactoryTokenAllocations[_address];
    }
}



