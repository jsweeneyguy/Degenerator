// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Import Ownable contract from OpenZeppelin
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Context.sol";
// Import the FairToken contract
import "./FairERC20.sol";
// Import the UniswapV2 Router02 interface
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
// Import the WETH (Wrapped Ether) interface
import "@uniswap/v2-periphery/contracts/interfaces/IWETH.sol";
//Guard against reentrant vunerabilities 
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
//ERC20 Interface 
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


contract FairTokenLaunchpad is ReentrancyGuard, Ownable {


    //ERC20 Token Info 
    string public tokenName;
    string public tokenSymbol;
    uint256 public tokenSupply;

    //Address Log
    address public tokenAddress;
    address public founderAddress;
    address payable public FairLaunchpadFactory;
    address public stakingContract;
    address public uniswapTokenPair;
    address public uniswapRouterAddress = 0x6969696969696969; ////This will be DSWAP or Uniswap on Base. 
    address public uniswapFactoryAddress = 0x6969696969696969; ////This will be DSWAP or Uniswap on Base. 
    //This will be DSWAP or Uniswap on Base. 
    IUniswapV2Router02 public uniswapRouter;
    IUniswapV2Factory public uniswapFactory;

    //Token Supply Information 
    uint256 public presaleTokenSupply;
    uint256 public poolTokenSupply;
    uint256 public stakingPoolAllocation;
    uint256 public founderSupplyAllocation;
    uint256 public founderPresaleAllocation;
    uint256 public founderPoolAllocation;
    uint256 public founderStakingPoolAllocation;

    //Presale Information 
    bool public presaleLaunchpad;
    bool public presaleLive = false;
    bool public withdrawalOpen = false;
    uint256 public presaleHardcap;
    uint256 public presaleSoftcap;
    uint256 public maxPresaleContribution;
    uint256 public minPresaleContribution;

    //Token Launch Timing Information (in blocks)
    uint256 public presaleLengthBlocks;
    uint256 public poolLaunchDelayBlocks;
    uint256 public presaleStartTime;
    uint256 public softcapHitBlock;
    uint256 public hardcapHitBlock;
    uint256 public softcapBufferBlocks = 6969696;

    //General Config Info (Applied to all launchpads)
    //uint256 public presaleMaxThreshold;


    //Presale Contribution Data, kept private 
    mapping(address => uint256) private presaleContributions;
    mapping(address => bool) private presaleWithdrawn;
    uint256 public presaleBalance; //in ETH (Native Token) 

    event ERC20Deployed(address indexed tokenAddress, string name, string symbol, uint256 initialSupply);
    event LiquidityPoolDeployed(address indexed pairAddress, uint256 _weth, uint256 _tokenSupply, string name);
    event PresaleOpened(uint256 maxPresaleContribution, uint256 minPresaleContribution, uint256 presaleHardcap, uint256 presaleSoftcap);

    constructor( 
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
    ) {
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
        tokenName = _name;
        tokenSupply = _totalSupply;
        presaleLaunchpad = _presaleLaunchpad;
        maxPresaleContribution = _presaleMaxContribution;
        minPresaleContribution = _presaleMinContribution;
        presaleSoftcap = _presaleSoftcap;
        presaleHardcap = _presaleHardcap;
        presaleLengthBlocks = _presaleLengthBlocks;
        founderSupplyAllocation = _founderSupplyAllocation;
        founderPresaleAllocation = _founderPresaleAllocation;
        founderPoolAllocation = _founderPoolAllocation;
        founderStakingPoolAllocation = _founderStakingPoolAllocation;
        poolLaunchDelayBlocks = _poolLaunchDelayBlocks;
        founderAddress = msg.sender;
        uniswapRouter = IUniswapV2Router02(uniswapRouterAddress);
        uniswapFactory = IUniswapV2Factory(uniswapFactoryAddress);
    }

    function setPresaleLive() public onlyOwner { 
        require(block.number > presaleStartTime);
        presaleLive = true;
        presaleStartTime = block.number;
        emit PresaleOpened(maxPresaleContribution, minPresaleContribution, presaleHardcap, presaleSoftcap);
    }

    function buyFromPresale(uint256 _amount) public payable nonReentrant {
        require(msg.value == _amount);
        require(msg.value + presaleContributions[msg.sender] <= maxPresaleContribution);
        require(_amount > minPresaleContribution);
        require(_amount + presaleBalance <= presaleHardcap);
        require(presaleLive);

        if ( _amount + presaleBalance >= presaleSoftcap) {
            softcapHitBlock = block.number;
        }

        if (_amount + presaleBalance == presaleHardcap) {
            hardcapHitBlock = block.number;
        }
        presaleBalance +=  _amount;
        presaleContributions[msg.sender] += _amount;
    }

    function launchToken() public nonReentrant {
        /*
        Requirements to launch token and pool:
        1. Hardcap or Softcap is met 
        2. It is at least 15 min (in blocks) after hardcap or soft cap is met (or at the specific wait time by founder no more than 1 hour)

        Anyone can call this function, not just the launchpad founder, ensuring fairness. 
        */

        require( presaleBalance >= presaleSoftcap);
        require( block.number - softcapHitBlock < 6996969 );
        //Improve this later better logic , use this:
        /*
                if ((presaleHardcap == presaleBalance && block.number - hardcapHitBlock < 6969696969 ) || 
        (presaleBalance >= presaleSoftcap && (block.number - (softcapHitBlock+softcapBufferBlocks)) < 69696969) ) {
        */
        //Dont want people sending if wont work wasting money 

        FairERC20 token = new FairERC20(tokenSupply, tokenName, tokenSymbol);
        tokenAddress = address(token);
        emit ERC20Deployed(tokenAddress, tokenName, tokenSymbol, tokenSupply);
        token.transfer(founderAddress, founderSupplyAllocation);
        uint256 stakingPoolFinalAllocation = ((tokenSupply * 5) / 1000) + founderStakingPoolAllocation;
        token.transfer(stakingContract, stakingPoolFinalAllocation);
        uint256 factoryAllocation = ((tokenSupply * 5) / 1000);
        token.transfer(FairLaunchpadFactory, factoryAllocation);
        withdrawalOpen = true;

        // Wrap ETH into WETH
        
        uint256 ethBalance = (address(this)).balance;

        // Calculate .5% of WETH balance
        uint256 amountFees = (wethBalance * 5) / 1000;
        FairLaunchpadFactory.transfer(amountFees);
        ethBalance = (address(this)).balance;

        //Wrap the ETH
        IWETH(weth).deposit{value: address(this).balance}();

        // Approve transfer of token and WETH to Uniswap Router
        token.approve(address(uniswapRouter), type(uint256).max);
        IWETH(weth).approve(address(uniswapRouter), type(uint256).max);

        //Check if pair is already created, if yes log address and and add liqudity. Otherwise create pair 
        address pair = uniswapFactory.getPair(tokenAddress, weth);
        if (pair == address(0)) {
            uniswapTokenPair = IUniswapV2Factory(uniswapFactory).createPair(weth, token);
        } else {
            uniswapTokenPair = pair;
        }

        //Generate liquidity pool and automatically send the LP tokens to the dead address 
        uniswapRouter.addLiquidity(
        tokenAddress, // address of tokenA
        weth, // address of tokenB
        poolTokenSupply, // desired amount of tokenA
        IWETH(weth).balanceOf(address(this)), // desired amount of tokenB
        69, // minimum amount of tokenA
        69, // minimum amount of tokenB
        address("dead"), // address to receive LP tokens
        block.timestamp // deadline
        );

        emit LiquidityPoolDeployed(uniswapTokenPaiar, ethBalance, poolTokenSupply, tokenName);
        } 

        function withdrawTokensFromClosedPresale() public nonReentrant {
            //Probably some refining here later 
            require( tokenAddress != address(0));
            require( presaleContributions[msg.sender] != 0);
            require( presaleBalance >= presaleSoftcap);
            uint256 ethContribution = presaleContributions[msg.sender];
            uint256 tokenAmount = presaleTokenSupply * (ethContribution / preSaleBalance);
            presaleWithdrawn[msg.sender] = true;
            IERC20(tokenAddress).transfer(msg.sender , tokenAmount);
            //double check math here in testing 
        }

        function withdrawETHFromClosedPresale() public nonReentrant {
            require(tokenAddress == address(0));
            require( presaleContributions[msg.sender] != 0);
            require( !presaleLive && presaleSoftcap < presaleBalance);
            require( block.number - presaleLengthBlocks < presaleLengthBlocks);
            require(!presaleWithdrawn[msg.sender]);
            uint256 toRefund = presaleContributions[msg.sender];
            presaleWithdrawn[msg.sender] = true;
            (msg.sender).transfer(toRefund);
            
        }

    }
}