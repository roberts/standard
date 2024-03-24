/**
 *
 *
   Contract features:
   100,000,000 tokens
   3% buy tax in ETH sent to community, marketing & developer
   16% sell tax in ETH sent to community, marketing, & developer
   Option to reduce taxes to 3/3
   Option to remove taxes
   Removable anti-whale restrictions for max transaction & max wallet
 */

// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
import '@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol';
import '@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router01.sol';
import '@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol';

/// @custom:security-contact security@drewroberts.com
contract DRCS is ERC20, ERC20Pausable, Ownable, ERC20Permit, ERC20Votes {
    using Math for uint256;

    IUniswapV2Router02 public immutable uniswapV2Router;
    address public uniswapV2Pair;
    address public constant deadAddress = address(0x000000000000000000000000000000000000dEaD);

    string exchangeLink = "https://app.uniswap.or/swap";
    string websiteLink = "https://DrewRoberts.com";

    address public communityWallet;
    address public marketingWallet;
    address public developerWallet;

    bool public tradable = false;
    bool public swappable = false;
    bool private swapping;
    uint256 public swapTokenAmount;

    bool public restrictions = true;
    uint256 public restrictMaxTransaction;
    uint256 public restrictMaxWallet;

    bool public taxation = true;
    bool public taxLopsided = true;

    uint256 public totalBuyTax;
    uint256 public totalSellTax;
    uint256 private communityTax;
    uint256 private marketingTax;
    uint256 private developerTax;

    uint256 public totalLopsidedSellTax;
    uint256 private communityLopsidedSellTax;
    uint256 private marketingLopsidedSellTax;
    uint256 private developerLopsidedSellTax;

    uint256 private communityTokens;
    uint256 private marketingTokens;
    uint256 private developerTokens;

    mapping(address => bool) private automatedMarketMakerPairs;

    event ExcludeFromFees(address indexed account, bool isExcluded);

    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);

    event communityWalletUpdated(
        address indexed newWallet,
        address indexed oldWallet
    );

    event marketingWalletUpdated(
        address indexed newWallet,
        address indexed oldWallet
    );

    event developerWalletUpdated(
        address indexed newWallet,
        address indexed oldWallet
    );


    constructor(address initialOwner)
        ERC20("Drew Roberts Contract Standard", "DRCS")
        Ownable(initialOwner)
        ERC20Permit("Drew Roberts Contract Standard")
    {
        uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        _approve(address(this), address(uniswapV2Router), type(uint256).max);

        uint256 totalSupply = 100_000_000 ether;

        swapTokenAmount = totalSupply / 2000; // 0.05% of total supply (50,000 tokens)

        restrictMaxTransaction = totalSupply / 100; // 1% of total supply (1,000,000 tokens)
        restrictMaxWallet = totalSupply / 20; // 5% of total supply (5,000,000 tokens)

        communityTax = 1;
        marketingTax = 1;
        developerTax = 1;
        totalBuyTax = communityTax + marketingTax + developerTax;
        totalSellTax = communityTax + marketingTax + developerTax;

        communityLopsidedSellTax = 6;
        marketingLopsidedSellTax = 6;
        developerLopsidedSellTax = 4;
        totalLopsidedSellTax = communityLopsidedSellTax + marketingLopsidedSellTax + developerLopsidedSellTax;

        communityWallet = address(0xC6aa2f0FF6b8563EA418ec2558890D6027413699); // Community Funds
        marketingWallet = address(0xC6aa2f0FF6b8563EA418ec2558890D6027413699); // Marketing Funds
        developerWallet = address(0xC6aa2f0FF6b8563EA418ec2558890D6027413699); // Developer Funds

        _mint(address(this), totalSupply);
    }

    receive() external payable {}

    /**
     * @dev Enables trading, creates a uniswap pair and adds liquidity using the tokens in the contract.
     *
     * sets tradable to true, it can never be set to false after that
     * sets swappable to true, enabling automatic swaps once swapTokenAmount is reached
     * stores uniswap pair address in uniswapV2Pair
     */
    function enableTrading() external onlyOwner {
        require(!tradable, "Trading already enabled.");

        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(
            address(this),
            uniswapV2Router.WETH()
        );
        _approve(address(this), address(uniswapV2Pair), type(uint256).max);
        IERC20(uniswapV2Pair).approve(
            address(uniswapV2Router),
            type(uint256).max
        );

        _setAutomatedMarketMakerPair(address(uniswapV2Pair), true);

        uint256 tokensInWallet = balanceOf(address(this));
        uint256 tokensToAdd = (tokensInWallet * 100) / 100; // 100% of tokens in contract go to Liquidity Pool to be paired with ETH in contract

        uniswapV2Router.addLiquidityETH{value: address(this).balance}(
            address(this),
            tokensToAdd,
            0,
            0,
            owner(),
            block.timestamp
        );

        tradable = true;
        swappable = true;
    }

    /**
     * @dev Updates the exchangeLink string with a new value
     */
    function updateExchangeLink(string calldata newLink) external onlyOwner {
        exchangeLink = newLink;
    }

    /**
     * @dev Updates the websiteLink string with a new value
     */
    function updateWebsiteLink(string calldata newLink) external onlyOwner {
        websiteLink = newLink;
    }

    /**
     * @dev Updates the threshold at which the tokens in the contract are automatically swapped for ETH
     */
    function updateSwapTokenAmount(
        uint256 newAmount
    ) external onlyOwner returns (bool) {
        require(
            newAmount >= (totalSupply() * 1) / 100000,
            "ERC20: Swap amount cannot be lower than 0.001% total supply."
        );
        require(
            newAmount <= (totalSupply() * 5) / 1000,
            "ERC20: Swap amount cannot be higher than 0.5% total supply."
        );
        swapTokenAmount = newAmount;
        return true;
    }

    /**
     * @dev Updates the communityWallet address
     */
    function updateCommunityWallet(
        address _communityWallet
    ) external onlyOwner {
        require(_communityWallet != address(0), "ERC20: Address 0");
        address oldWallet = communityWallet;
        communityWallet = _communityWallet;
        emit communityWalletUpdated(communityWallet, oldWallet);
    }

    /**
     * @dev Updates the marketingWallet address
     */
    function updateMarketingWallet(
        address _marketingWallet
    ) external onlyOwner {
        require(_marketingWallet != address(0), "ERC20: Address 0");
        address oldWallet = marketingWallet;
        marketingWallet = _marketingWallet;
        emit marketingWalletUpdated(marketingWallet, oldWallet);
    }

    /**
     * @dev Updates the developerWallet address
     */
    // function updateDeveloperWallet(
    //     address _developerWallet
    // ) external onlyOwner {
    //     require(_developerWallet != address(0), "ERC20: Address 0");
    //     address oldWallet = developerWallet;
    //     developerWallet = _developerWallet;
    //     emit developerWalletUpdated(developerWallet, oldWallet);
    // }

    /**
     * @dev removes the max transaction and max wallet restrictions
     * this cannot be reversed
     */
    function removeRestrictions() external onlyOwner {
        restrictions = false;
    }

    /**
     * @dev Resets the tax to 3% buy and 16% sell
     */
    function resetTax() external onlyOwner {
        taxation = true;
        taxLopsided = true;
    }

    /**
     * @dev Sets the sell tax to 3%
     */
    function reduceSellTax() external onlyOwner {
        taxLopsided = false;
    }

    /**
     * @dev Sets the buy and sell fees to 0%
     */
    function removeTax() external onlyOwner {
        taxation = false;
    }

    /**
     * @dev Sends any remaining ETH in the contract that wasn't automatically swapped to the owner
     */
    function withdrawStuckETH() public onlyOwner {
        bool success;
        (success, ) = address(msg.sender).call{value: address(this).balance}(
            ""
        );
    }

    /**
     * @dev Sends any remaining tokens in the contract to the owner
     */
    function withdrawStuckTokens(address tkn) public onlyOwner {
        require(IERC20(tkn).balanceOf(address(this)) > 0, "No tokens");
        uint256 amount = IERC20(tkn).balanceOf(address(this));
        IERC20(tkn).transfer(msg.sender, amount);
    }

    /**
     * @dev stores the address of the automated market maker pair
     */
    function _setAutomatedMarketMakerPair(address pair, bool value) private {
        automatedMarketMakerPairs[pair] = value;

        emit SetAutomatedMarketMakerPair(pair, value);
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    // The following functions are overrides required by Solidity.

    function _update(address from, address to, uint256 value)
        internal
        override(ERC20, ERC20Pausable, ERC20Votes)
    {
        super._update(from, to, value);
    }

    function nonces(address owner)
        public
        view
        override(ERC20Permit, Nonces)
        returns (uint256)
    {
        return super.nonces(owner);
    }

    /**
     * @dev Transfer function
     */
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        if (amount == 0) {
            super._transfer(from, to, 0);
            return;
        }

        if (
            from != owner() &&
            to != owner() &&
            to != address(0) &&
            to != deadAddress &&
            !swapping
        ) {
            if (!tradable) {
                require(
                    from == owner() ||
                        from == address(this) ||
                        from == deadAddress ||
                        from == communityWallet ||
                        from == marketingWallet ||
                        from == developerWallet ||
                        to == owner() ||
                        to == address(this) ||
                        to == deadAddress ||
                        to == communityWallet ||
                        to == marketingWallet ||
                        to == developerWallet,
                    "ERC20: Token Trading Not Enabled. Be Patient Anon."
                );
            }

            //when buy
            if (
                automatedMarketMakerPairs[from] &&
                (to == owner() ||
                    to == address(this) ||
                    to == deadAddress ||
                    to == address(uniswapV2Router) ||
                    to == communityWallet ||
                    to == marketingWallet ||
                    to == developerWallet)
            ) {
                if (restrictions) {
                    require(
                        amount <= restrictMaxTransaction,
                        "ERC20: Max Transaction Exceeded"
                    );
                    require(
                        amount + balanceOf(to) <= restrictMaxWallet,
                        "ERC20: Max Wallet Exceeded"
                    );
                }
            }
            //when sell
            else if (
                automatedMarketMakerPairs[to] &&
                (from == owner() ||
                    from == address(this) ||
                    from == deadAddress ||
                    from == address(uniswapV2Router) ||
                    from == communityWallet ||
                    from == marketingWallet ||
                    from == developerWallet)
            ) {
                if (restrictions) {
                    require(
                        amount <= restrictMaxTransaction,
                        "ERC20: Max Transaction Exceeded"
                    );
                }
            } else if (
                to != owner() &&
                to != address(this) &&
                to != deadAddress &&
                to != address(uniswapV2Router) &&
                to != communityWallet &&
                to != marketingWallet &&
                to != developerWallet
            ) {
                require(
                    amount + balanceOf(to) <= restrictMaxWallet,
                    "ERC20: Max Wallet Exceeded"
                );
            }
        }

        uint256 contractTokenBalance = balanceOf(address(this));

        bool canSwap = contractTokenBalance >= swapTokenAmount;

        if (
            canSwap &&
            swappable &&
            !swapping &&
            !automatedMarketMakerPairs[from] &&
            from != owner() &&
            from != address(this) &&
            from != deadAddress &&
            from != communityWallet &&
            from != marketingWallet &&
            from != developerWallet &&
            to != owner() &&
            to != address(this) &&
            to != deadAddress &&
            to != communityWallet &&
            to != marketingWallet &&
            to != developerWallet
        ) {
            swapping = true;

            distributeTax();

            swapping = false;
        }

        bool taxed = !swapping;

        if (
            from == owner() ||
            from == address(this) ||
            from == deadAddress ||
            from == communityWallet ||
            from == marketingWallet ||
            from == developerWallet ||
            to == owner() ||
            to == address(this) ||
            to == deadAddress ||
            to == communityWallet ||
            to == marketingWallet ||
            to == developerWallet
        ) {
            taxed = false;
        }

        uint256 fees = 0;

        if (taxed) {
            // Collect Sell Tax
            if (automatedMarketMakerPairs[to] && taxation) {
                if (taxLopsided) {
                    fees = amount.tryMul(totalLopsidedSellTax).tryDiv(100);
                    communityTokens += (fees * communityLopsidedSellTax) / totalLopsidedSellTax;
                    marketingTokens += (fees * marketingLopsidedSellTax) / totalLopsidedSellTax;
                    developerTokens += (fees * developerLopsidedSellTax) / totalLopsidedSellTax;
                } else {
                    fees = amount.tryMul(totalSellTax).tryDiv(100);
                    communityTokens += (fees * communityTax) / totalSellTax;
                    marketingTokens += (fees * marketingTax) / totalSellTax;
                    developerTokens += (fees * developerTax) / totalSellTax;
                }
            }
            // Collect Buy Tax
            else if (automatedMarketMakerPairs[from] && taxation) {
                fees = amount.tryMul(totalBuyTax).tryDiv(100);
                communityTokens += (fees * communityTax) / totalBuyTax;
                marketingTokens += (fees * marketingTax) / totalBuyTax;
                developerTokens += (fees * developerTax) / totalBuyTax;
            }

            if (fees > 0) {
                super._transfer(from, address(this), fees);
            }

            amount -= fees;
        }

        super._transfer(from, to, amount);
    }

    /**
     * @dev Helper function that swaps tokens in the contract for ETH
     */
    function swapTokensForEth(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // make the swap
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    /**
     * @dev Helper function that sends the ETH from the contract to the communityWallet, marketingWallet & developerWallet
     */
    function distributeTax() private {
        uint256 contractBalance = balanceOf(address(this));
        uint256 totalTokensToSwap = communityTokens + marketingTokens + developerTokens;
        bool success;

        if (contractBalance == 0 || totalTokensToSwap == 0) {
            return;
        }

        if (contractBalance > swapTokenAmount * 20) {
            contractBalance = swapTokenAmount * 20;
        }

        swapTokensForEth(contractBalance);

        uint256 ethBalance = address(this).balance;

        uint256 ethForCommunity = ethBalance.tryMul(communityTokens).tryDiv(totalTokensToSwap);
        uint256 ethForDeveloper = ethBalance.tryMul(developerTokens).tryDiv(totalTokensToSwap);

        communityTokens = 0;
        marketingTokens = 0;
        developerTokens = 0;

        (success, ) = address(communityWallet).call{value: ethForCommunity}("");
        (success, ) = address(marketingWallet).call{value: address(this).balance}("");
        (success, ) = address(developerWallet).call{value: ethForDeveloper}("");
    }
}