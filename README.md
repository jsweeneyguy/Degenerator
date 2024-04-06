# README

### DegeneratorDeployer Overview

The `DegeneratorDeployer` contract is a multisignature wallet with additional functionalities for managing a fair launch factory and a staking contract. This contract allows for executing transactions only when approved by a specified number of signatories.

## Contract Structure

The contract is structured as follows:

- **MultisigWallet**: The main contract implementing multisignature functionalities and additional methods for managing a fair launch factory and a staking contract.
- **Ownable**: An imported contract from OpenZeppelin for managing ownership.
- **FairLaunchFactory.sol**: A contract managing fair launch factory operations.
- **DegeneratorStaking.sol**: A contract managing staking functionalities.
- **FairERC20.sol**: A contract for a fair ERC20 token implementation.

## Key Features

1. **Multisignature Functionality**: The contract allows multiple signatories to collectively approve and execute transactions.

2. **Factory and Staking Management**: Functions are provided for launching the fair launch factory and staking contract, setting configurations, and withdrawing funds.

3. **Voting Mechanism**: A voting mechanism is implemented to approve configuration changes for the factory and staking contract. Each signatory has one vote, and a configuration change requires approval from at least 2/3rds of the signatories.

## Usage

1. **Deploying the Contract**: Deploy the `MultisigWallet` contract with an initial list of signatories and revenue splits.

2. **Launching Factory and Staking Contracts**: Use the `launchDegeneratorFactory` and `launchStakingContract` functions to initialize the fair launch factory and staking contract.

3. **Configuring Factory and Staking Parameters**: Use the provided functions to set minimum stake amount, reward blackout period, factory base fee, and factory fee.

4. **Executing Transactions**: Execute transactions such as withdrawing ETH or tokens from the fair launch factory using the `executeDispursal` function.

5. **Voting on Configuration Changes**: Use the `vote` function to approve configuration changes for the factory and staking contract.

## Security Considerations

- Ensure that the list of signatories and revenue splits are carefully chosen to prevent unauthorized transactions.
- Verify configuration changes thoroughly before voting to avoid unintended consequences.
- Implement proper access controls to restrict sensitive functions to authorized users only.


### FairLaunchFactoryV1 Overview

The `FairLaunchFactoryV1` contract facilitates the creation of fair launchpads for new tokens. It allows users to generate launchpads with customizable parameters such as presale hardcap, softcap, duration, and more.

## Contract Structure

The contract is structured as follows:

- **FairLaunchFactoryV1**: The main contract for managing fair launchpad creation and configuration.
- **Ownable**: An imported contract from OpenZeppelin for managing ownership.
- **ReentrancyGuard**: A contract from OpenZeppelin for guarding against reentrancy vulnerabilities.
- **IERC20**: An ERC20 token interface.
- **FairTokenLaunchpad.sol**: A contract representing a fair launchpad for a new token.

## Key Features

1. **Fair Launchpad Creation**: Users can create fair launchpads for new tokens using the `createFairLaunchpad` function, specifying various parameters.
2. **Factory Configuration**: The factory fee, base fee, staking contract, and token allocations can be configured using specific functions.
3. **Multisig Functionality**: Certain critical functions such as withdrawing ETH and tokens are restricted to the multisig address for enhanced security.

## Usage

1. **Deploying the Contract**: Deploy the `FairLaunchFactoryV1` contract with initial parameters such as factory fee, base fee, staking contract address, and multisig address.
2. **Creating Fair Launchpads**: Use the `createFairLaunchpad` function to generate fair launchpads for new tokens with customizable parameters.
3. **Configuring Factory**: Adjust the factory fee, base fee, staking contract address, and other parameters using the respective functions.
4. **Managing Launchpads**: Monitor and manage created launchpads using the provided getter functions.

## Security Considerations

- Ensure that only authorized addresses have access to critical functions such as setting factory configurations and closing the factory.
- Regularly review and audit the contract code to identify and mitigate potential security vulnerabilities.
- Use a secure multisig address for executing sensitive operations to prevent unauthorized actions.


### FairTokenLaunchpad Overview 

The `FairTokenLaunchpad` contract is designed to facilitate fair token launches through presale and liquidity pool generation. It enables users to create and manage fair token launchpads with customizable parameters.

## Contract Structure

The contract includes the following components:

- **FairTokenLaunchpad**: The main contract for managing token launches, presales, and liquidity pools.
- **Ownable**: An imported contract from OpenZeppelin for managing ownership.
- **ReentrancyGuard**: A contract from OpenZeppelin for guarding against reentrancy vulnerabilities.
- **IERC20**: An ERC20 token interface.
- **IFairLaunchFactoryV1**: An interface for the FairLaunchFactoryV1 contract.

## Key Features

1. **Presale Management**: Users can launch presales with specified hardcap, softcap, duration, and contribution limits.
2. **Liquidity Pool Generation**: The contract automatically creates liquidity pools on Uniswap with generated tokens and ETH.
3. **Founder Allocations**: Founders can specify token allocations for themselves, including presale and pool allocations.
4. **Customizable Configurations**: Various parameters such as presale start time, pool launch delay, and softcap timer blocks can be adjusted.

## Usage

1. **Deploying the Contract**: Deploy the `FairTokenLaunchpad` contract with initial parameters such as token name, symbol, total supply, and launchpad settings.
2. **Launching Presale**: Set the presale live and allow users to contribute funds within specified limits.
3. **Launching Token**: After a successful presale, call the `launchToken` function to create and distribute tokens, set up liquidity pools, and allocate tokens to founders and stakeholders. ERC20 in constructed as non-mintable, and liquidity pool tokens are minted to the null address, ensuring a safe token launch. 
4. **Managing Allocations**: Adjust founder allocations as needed using the provided functions.
5. **Withdrawal**: Users can withdraw tokens or ETH from the presale if conditions are met.

## Security Considerations

- Ensure that only authorized addresses have access to critical functions such as setting presale live and managing allocations.
- Implement proper checks and validations to prevent unauthorized access and ensure fair token launches.
- Regularly review and audit the contract code to identify and mitigate potential security vulnerabilities.


## DegeneratorStaking Overview

The `DegeneratorStaking` contract is designed to enable staking of a specific token (referred to as "Degenerator") by users. It allows users to stake their tokens and withdraw them along with rewards based on certain conditions.

## Contract Structure

The contract includes the following components:

- **DegeneratorStaking**: The main contract for managing staking of the Degenerator token.
- **Context**: An imported contract from OpenZeppelin providing contextual information.
- **ReentrancyGuard**: A contract from OpenZeppelin for guarding against reentrancy vulnerabilities.
- **IERC20**: An ERC20 token interface.
- **IFairLaunchFactoryV1**: An interface for the FairLaunchFactoryV1 contract.

## Key Features

1. **Staking Degenerator**: Users can stake their Degenerator tokens by specifying the amount they wish to stake.
2. **Withdrawing Degenerator**: Stakers can withdraw their staked Degenerator tokens at any time.
3. **Reward Distribution**: Stakers can withdraw rewards earned based on the amount and duration of their staked tokens.
4. **Minimum Stake Amount**: The contract allows setting a minimum stake amount to ensure valid stakes.
5. **Reward Blackout Period**: A blackout period is implemented to restrict reward withdrawals for a certain duration after staking.

## Usage

1. **Staking Tokens**: Users can stake their Degenerator tokens by calling the `stakeDegenerator` function with the desired amount.
2. **Withdrawing Staked Tokens**: Stakers can withdraw their staked tokens using the `withdrawDegenerator` function.
3. **Withdrawing Rewards**: Stakers can withdraw rewards earned by calling the `withdrawRewards` function.
4. **Configuring Parameters**: The contract owner can adjust parameters such as the minimum stake amount and reward blackout period.

## Security Considerations

- Ensure that only authorized addresses have access to critical functions such as adjusting parameters and withdrawing rewards.
- Implement proper checks and validations to prevent unauthorized access and ensure fair reward distribution.
- Regularly review and audit the contract code to identify and mitigate potential security vulnerabilities.


