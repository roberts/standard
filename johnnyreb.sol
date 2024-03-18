// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract JohnnyReb {
    address payable public wallet1 =
        payable(0xC6aa2f0FF6b8563EA418ec2558890D6027413699);
    address payable public wallet2 =
        payable(0x90923AD852f67682D9CcD437196a619F7BdF6Ae7);
    address payable public wallet3 =
        payable(0xC6aa2f0FF6b8563EA418ec2558890D6027413699);

    constructor() {}

    function setWallet3(address payable _wallet3) public {
        wallet3 = _wallet3;
    }

    function sendStuckEther() public {
        payable(msg.sender).transfer(address(this).balance);
    }

    receive() external payable {
        require(msg.value > 0, "No ether sent");

        uint wallet1Share = (msg.value * 40) / 100;
        uint wallet2Share = (msg.value * 40) / 100;
        uint wallet3Share = msg.value - wallet1Share - wallet2Share;

        wallet1.transfer(wallet1Share);
        wallet2.transfer(wallet2Share);
        wallet3.transfer(wallet3Share);
    }
}
