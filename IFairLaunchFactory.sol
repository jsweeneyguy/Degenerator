// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
interface IFairLaunchFactoryV1 {
    function factoryFee() external view returns (uint256);
    function factoryBaseFee() external view returns (uint256);
    function stakingContract() external view returns (address);
    function multiSigAddress() external view returns (address);
    function factoryToken() external view returns (address);
    function launchpadsGenerated() external view returns (uint256);
    function factoryOpen() external view returns (bool);
    function isFactoryToken(address _address) external view returns (bool);
    function stakingContractFactoryTokenAllocations(address _address) external view returns (uint256);
    function addressIsLaunchpad(address _address) external view returns (bool);

    event LaunchPadGenerated(address indexed LaunchpaddAddress, uint256 indexed launchpadNumber, uint256 hardcap, uint256 softcap, address founderAddres);
    event multiSigWithdrawal(address withdrawSender, uint256 withdrawalAmount);
    event FactoryTokenRegistered(address indexed tokenAddress);
    event FactoryFeeSet(uint256 newFee);
    event FactoryBaseFeeSet(uint256 newBaseFee);
    event StakingContractSet(address indexed newStakingContract);
    event FactoryClosed(bool factoryOpen);

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
    ) external payable;

    function withdrawToMultiSig() external;

    function registerFactoryToken(address _address, uint256 _stakingContractAllocation) external;

    function setFactoryFee(uint256 _newFee) external;

    function setFactoryBaseFee(uint256 _newFee) external;

    function setStakingContract(address _newStakingContract) external;

    function closeFactory(bool _factoryOpen) external;

    function isAddressLaunchpad(address _address) external view returns(bool);

    function isAddressFactoryToken(address _address) external view returns(bool);

    function getTokenStakingContractAllocation(address _address) external view returns (uint256);
}