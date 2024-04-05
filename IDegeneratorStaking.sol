// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IFairLaunchFactory.sol";

interface IDegeneratorStaking {
    function factoryAddress() external view returns (address);
    function multiSigAddress() external view returns (address);
    function tokenAddress() external view returns (address);
    function minimumStakeAmount() external view returns (uint256);
    function rewardBlackoutPeriod() external view returns (uint256);
    function factory() external view returns (IFairLaunchFactoryV1);
    function degeneratorStakingPool() external view returns (uint256);
    function degeneratorStakers() external view returns (uint256);

    function stakeDegnerator(uint256 _amount) external;
    function withdrawDegenerator() external;
    function registerERC20Supply(address _tokenAddress, uint256 _poolSupply) external;
    function withdrawRewards(address[] calldata _tokenAddresses) external;
    function getTokenEligibility(address _tokenAddress, address _account) external view returns(bool);
    function getTokenReward(address _tokenAddress, address _account) external view returns(uint256);

    event degeneratorStaked(address indexed staker, uint256 amount, uint256 blockStaked);
    event degeneratorWithdrawn(address indexed staker, uint256 amount);
}
