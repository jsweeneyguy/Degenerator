# README

### Degenerator Overview

`Degenerator` is an smart contract architecture designed to deploy: 
1. **Degenerator Token**
2. **Degenerator Staking**
3. **Degenerator Launch Factory** 
4.  **Multisignature Management/Deployer Wallet** 

The Degenerator Launch Factory (termed `FairLaunchFactoryV1`) is an Automated Token Launchpad / Market Maker rolled into one. Users can pay the specified fee to purchase Token Launchpads from the Launch Factory. All Token Launchpads are themselves a smart contract that facilitate: 1. Autonomosly generating a non-mintable, SafeERC20 standard token and allocating said token to users; 2. Creating a Uniswap ETH/Token pair, generating a market for the pair by adding liquidity and tokens to the Liquidity Pair, 3. Burning ownership of the market pair and Liquidity Pool upon creation to ensure token holder safety. 

Purchasers of Token Launchpads can also utilize their launchpad to hold a token presale to raise ETH liquidity for generating their token's market. Launchpad Owners can configure their personal token allocations, token allocations reserved for presale, token allocations reserved for market generation, and (if they choose) can also allocate supply to stakers of the Degenerator token. Launchpad Owners can also configure the following: presale softcap/hardcap, minimum contribution, maximum contribution, presale duration, time from softcap hit to sale end, time between presale end and market generation, market order size configurations, and more. All token/market configuration variables are limited within certain thersholds to ensure that consumers purchasing Degenerator launched tokens from Degenerator markets are protected from fraud/"rug pulls". These thresholds are controlled by the multisignature Management/Deployer Wallet to secure their manipulation from hack or bad actors, requiring a 2/3rd council vote to be modified.

The Degenerator Launch Factory aims to service both founders and market participants by wrapping existing ERC20 and Uniswap AMM Protocols in smart contracts that provide both process automation for founders as well as the garauntee of safety for presale/market participants. For this service the Degenerator Launch Factory receieves a 0.25% share of tokens and ETH liquidity raised in presales and/or token launches. 

The Degenerator native token and Degenerator Staking Contract are designed as a mechanism to reward platform supporters with small yields of tokens launched via the Degenerator platform. The Degenerator staking contract will default receive a 0.25% share of the minted token supply. Founders can choose to allocate up to an additional 2.5% of the token supply to the staking contract. Degenerator token holders can stake their tokens in the Staking Contract, and after a blackout period to avoid flash-staking, their staked Degenerator will qualify to yield newly launched tokens from the staking contract pool. Token rewards will be proportional to an address's % of the staking pool at the time the token is launched. For example, if an address's stake comprised 10% of the staking pool at the time of a coin launch, they would be eligible for 10% of the 0.25%-2.75% of token supply allocated to the staking contract (.025%-0.275% of total token supply). To avoid risk in token disbursal, an address cannot increase it's stake before withdrawal of their current stake. On top of this, due to limitations in dealing with rewards at the scale of tens of thousands of different tokens, token rewards must be manually withdrawn by stakeholders and will be lost if not withdrawn before unstaking. 

The MultiSignature Management/Deployer Wallet (referred to as "the Deployer") can be thought of as the Degenerator "War Room". The Deployer is responsible for launching/managing the Staking Contracts, Launch Factory, and platform funds. When the Deployer is deployed (deployerception), it will be initialized with a list of addresses belonging to the Degenerator Advisory Board. Contractual entrance and removal of memembers from this board will be done via vote by the Advisory Board inside the contract. Additionally, the contract has built in functionality requiring any modification to the factory to be approved by 2/3rds vote of the council. This voting system allows the Launch Factory to be flexible to changing crypto prices and consumer demands while also being robust to hack or manipulation via internal bad actors. In Future versioning of the Degenerator architecture I aim to give a gradually increasing voting power to the staking contract and allow stakers of Degenerator to propose and vote on Factory configurations. 


### Multisignature Management/Deployer Wallet - DegeneratorDeployer Overview

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


### Degenerator Launch Factory - FairLaunchFactoryV1 Overview

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

### Degenerator Launchpads - FairTokenLaunchpad Overview 

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


## Degenerator Staking - DegeneratorStaking Overview

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
