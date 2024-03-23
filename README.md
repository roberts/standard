# Drew Roberts Contract Standard

This repository is for updating & explaining the features of my Contract Standard for ERC-20 Tokens. The contract is designed to optimize the performance of long-term Ethereum token projects on Mainnet or a Layer-2. It removes all concern from token holders of nefarious behavior as there are no functions even available that could be misused by the project. The ultimate goal is to encourage transaction volume at launch and subsequent accumulation of tokens into the hands of long-term supporters of the project, fostering a strong community.

I believe in the Web3 Ethos of "Don't Trust, Verify" and have been in the industry for over a decade and will remain for decades to come. As such, creating long-term relationships with project founders and their teams is of utmost importance to me. I value transparency & creating a Win-Win Situation for all parties, especially token holders. If I am the developer of a project, you can expect the following commitment from me and the team.

## Drew Roberts Commitment

- Contract deployed & made publicly available 24+ hours ahead of Liquidity Pool launch
- Public livestream of liquidity pool launch with project hosting X Space
- Liquidity Pool locked for over 1 year
- Transparency with token community & prior announcement of all dev actions

## Deployments

When deploying smart contracts, I use [this workflow](https://docs.openzeppelin.com/defender/v2/tutorial/deploy) with the following services:

- [OpenZeppelin Defender](https://defender.openzeppelin.com/v2/)
- [HardHat](https://hardhat.org)

## Contract Standard Features

With every token project I have launched over the past 3 years, I test a hypothesis with the team to improve the launch & long-term success of the project. Like a scientific study, I keep all the other variables in the contract & launch strategy the same and simply isolate this hypothesis for improvement. This approach allows me to confidently learn and iterate on the best practices I have developed for project teams. [View my old contract](https://github.com/roberts/standard/blob/main/old.sol). With these learnings, I have settled on the following read & write functions for the current contract standard:

- [Read Functions](https://github.com/roberts/standard/blob/main/functions/read.md)
- [Write Functions](https://github.com/roberts/standard/blob/main/functions/write.md)

My contract standard contains the following features:

### Lopsided Tax Structure

Through many experiments with tokenomics, I have found that optimal performance for long-term token projects is achieved through a 3/16 lopsided tax structure. It is important to have the option to reduce the lopsided sell tax for a stable 3/3 tax token and another option to remove taxes altogether.

### Restrict Modifiable Tax

To ensure community confidence & clearly communicate tax policy, the buy & sell taxes are not openly adjustable. I used to cap what they could be modified to, but find it is better to hard code just a couple options into the smart contract. The following tax functions are available to projects using this contract standard:

- reduceSellTax() - This function reduces the 16% sell tax to 3%, matching the buy tax so the token has a 3/3 tax.
- removeTax() - This function removes the buy and sell tax so the token has a 0/0 tax.
- resetTax() - This function resets the token back to the 3/16 lopsided tax structure.

### Tax Wallets

Long-term projects work best when there is clear budgeting within the token tax structure between 3 wallets and those wallets are clearly identified. I also believe it is best for projects to have different individuals with control of these wallets and it is communicated on the project's website. This contract standard contains the following:

- Community Wallet - Controlled by the project's CEO or community manager
- Marketing Wallet - Controlled by the project's CMO or marketing director
- Developer Wallet - Controlled by the project's CTO or lead developer

For project longevity, these wallets are updateable in the contract. This allows teams to use a marketing manager for launch and a different marketing manager for ongoing efforts or just for natural turnover in positions over time. You have the new team member in that role create a fresh wallet only they have control over then we update the smart contract to divert the appropriate tax revenue to that wallet. There are 3 functions to update these wallets:

- updateCommunityWallet()
- updateMarketingWallet()
- updateDeveloperWallet()

### Withdraw Tokens

There are 2 functions for withdrawing tokens in the contract:

- withdrawStuckTokens() - This function withdraws the tokens in the contract
- withdrawStuckETH() - This function withdraws the Ethereum in the contract

### Enable Trading

The following function enables trading of tokens:

- enableTrading() - This function launches the Uniswap V2 Liquidity Pool with the tokens & ETH in the contract

### Anti-Whale Restrictins

There are 2 anti-whale restrictions in this contract standard. The first is a max transaction that I have found is best to be 2% or less of the total supply. The second is a max wallet which I have found is best to be 5% of the total supply, allowing multiple buys. These are necessary for heavily marketed launches and to prevent whales accumulating at launch, especially bots. 15-30 minutes after launch, this should be removed with the following function:

- removeRestrictions() - This function removes the max transaction and the max wallet

### Ownership

There are 2 functions for ownership in the Contract Standard:

- transferOwnership() - This function transfers the contract to another Ethereum address
- renounceOwnership() - This function sends the contract to the Dead Address

## Contract Standard Does NOT Contain

Here is a list of things I have seen in smart contracts for ERC-20 tokens that I believe are not in the best long-term interest of the project's community and will not include in this contract standard. This contract standard does NOT contain the following:

- No Transfer Fee
- No Whitelist
- No Blacklist
- No Mint
