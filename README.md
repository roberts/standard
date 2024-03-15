# Drew Roberts Contract Standard

This repository is for updating & explaining the features of my Standard ERC-20 Token Contract. The contract is designed for optimized performance of long-term Ethereum token projects on Mainnet or a Layer 2. It removes all concern from token holders of nefarious behavior as there are no functions even available that could be misused by the project. The ultimate goal is to encourage transaction volume at launch and subsequent accumalation of tokens into the hands of long-term supporters of the project, fostering a strong community.

I believe in the Web3 Ethos of "Don't Trust, Verify" and have been in the industry for over a decade and will remain for decades to come. As such, creating long-term relationships with project founders and their teams is of utmost importance to me. I value transparency & creating a Win-Win Situation for all parties, especially token holders. If I am the developer of a project, you can expect the following commitment from me and the team.

## Drew Roberts Commitment

- Contract deployed & made publicly available 24+ hours ahead of Liquidity Pool launch
- Public livestream of liquidity pool launch with project hosting X Space
- Liquidity Pool locked for over 1 year
- Transparency with token community & prior announcement of all dev actions

## Contract Standard Features

With every token project I have launched over the past 3 years, I test a hypothesis with the team to improve the launch & long-term success of the project. Like a scientific study, I keep all the other variables in the contract & launch strategy the same and simply isolate this hypothesis for improvement. This approach allows me to confidently learn and iterate on the best practices I have developed for project teams.

My contract standard contains the following features:

### Lopsided Tax Structure

I have found the optimal buy tax to be 3% for long-term projects. After many iterations of testing lopsided tax structures, I have found 16% to be the optimal sell tax.

### Restrict Modifiable Tax

To ensure community confidence & clearly communicate what the team is able to do with the taxes, the buy and sell tax are not openly adjustable. I used to cap what they could be modified to, but find it is better to hard code just a couple options into the smart contract. There are 2 functions available to projects:

- reduceSellTax() - This function reduces the 16% sell tax to 3%, matching the buy tax so the token has a 3/3 tax.
- removeTax() - This function removes the buy and sell tax so the token has a 0/0  tax.
- resetTax() - THis function resets the token back to the 3/16 lopsided tax structure.

### Tax Wallets

Long-term projects work best when there is clear budgeting within the token tax structure between 3 wallets and those wallets are clearly identified. I also believe it is best for projects to have different individuals with control of these wallets and it is communicated on the project's website. This contract standard contains the following:

- Community Wallet - Controlled by the project's CEO or community manager
- Marketing Wallet - Controlled by the project's CMO or marketing director
- Developer Wallet - Controlled by the project's CTO or lead developer

For project longevity, these wallets are updateable in the contract. This allows teams to use a marketing manager for launch and a different marketing manager for ongoing efforts or just for natural turnover in positions over time. You have the new team member in that role create a fresh wallet only they have control over then we update the smart contract to divert the appropriate tax revenue to that wallet.


## Contract Standard Does NOT Contain

Here is a list of things I have seen in smart contracts for ERC-20 tokens that I believe are not in the best long-term interest of the project's community and will not include in this contract standard. This contract standard does NOT contain the following:

- No Transfer Fee
