---
title: "Poison Block Explorer Code"
date: 2019-02-09T15:56:15+02:00
draft: true
---

I will show you how to trick a block explorer to display a different bytecode than the one actually deployed on the chain.

This is important because a user can be tricked by the block explorer and think it interacts with a contract when actually it interacts with a different contract. It is indeed the same contract address, but the bytecode is not the one reported by the block explorer. This is a technique that hackers can use to trick users to think the contract work in your favour, when in fact it works against you.

- Set up the idea in advance
- Go through the idea
- Summarize it when you are done

i.e.
- Say what you are going to say
- Say it
- Say what you said

## Intro

I will show you how to trick a block explorer to display a different byte code than the one actually deployed on the chain.

This is important because a user can be tricked by a hacker to think it interacts with a good contract, when actually the user interacts with malicious contract. It is indeed the same contract address, but the byte code is not the one reported by the block explorer.

## Disclaimer

Not against any explorer.

This issue was reported.

## The setup

To make this work we need 3 things:

- a trustworthy contract that a user wants to interact with;
- another contract that is malicious, that the user does not want to interact with;
- a factory contract that pretends to deploy the trustworthy contract and actually deploys the malicious one.

## Trustworthy contract

Below is a simple contract that acts like a safe, a user can store funds and retrieve those funds at a later date:

```solidity
contract Safe {
    mapping(address => uint256) ledger;

    function () external payable  {
        ledger[msg.sender] += msg.value;
    }

    function withdraw() public {
        uint256 balance = ledger[msg.sender];
        ledger[msg.sender] = 0;
        msg.sender.transfer(balance);
    }
}
```

If the user wants to store some funds, they can just send them to the contract. In the future the user can call the `withdraw()` method and retrieve all of their stored funds.

## Malicious contract

Below is a malicious contract that accepts funds and can send all the accepted funds to the owner. Your funds are not safe if you send your ether there. The owner can steal it all:

```solidity
contract MaliciousContract {
    address payable owner;

    constructor() public {
        owner = msg.sender;
    }

    function () external payable {
        // Accepts ether
    }

    function steal() public {
        selfdestruct(owner);
    }
}
```

## Factory contract

The address for an Ethereum contract is deterministically computed from the address of its creator and the creator's nonce.

We can define it like this without going into detail:

$${address} = f({sender}, {nonce})$$

<!-- > If you really want to understand how the new contract's address is computed, [this answer](https://ethereum.stackexchange.com/a/761/6253) is a really good explanation. -->

Below is the factory contract:

```solidity
contract Deployer {
    function createGood () public {
        // Pretend to deploy the contract and revert
        new Safe();
        revert();
    }

    function createMalicious() public {
        MaliciousContract newContract = new MaliciousContract();

        emit Deployed(address(newContract));
    }

    event Deployed(address safe);
}
```

The method `createGood()` pretends to deploy the good contract, but in the end it reverts the transaction. Trying to deploy the good contract means that it creates a message that contains the **byte code** and the **new contract address**. Reverting the transaction means that the contract's **nonce** is not changed and no new contract is deployed. Trying to create a new contract, the same nonce will be used, thus the **same new address** will be generated.

This is exactly what the method `createMalicious()` exploits. It deploys a new contract, but this time it does not revert, the new contract is indeed deployed.

## Confuse the block explorer

The exploit happens in 2 steps:

1. The hacker first calls `createGood()` and a contract message containing the **byte code** and the **new contract address** will be generated. If the block explorer does not handle the `revert()` properly, the **byte code** will be associated with the **new contract address**.

2. The hacker then calls `createMalicious()` which creates another contract message containing a different **byte code** and the **same contract address**.

The block explorer must handle the errors properly and only save the byte code when the contract message succeeds. Otherwise it will associate an incorrect byte code with a contract address.

The users checking the contract will see an incorrect byte code on the website. They will think they interact with a good contract when actually they interact with a malicious one.

## Result

The block explorer reports an incorrect byte code for a specific contract. This happens because we first pretend to deploy a contract and then revert. The block explorer notices the pretend and saves the byte code as the one deployed. When we actually deploy a new contract with a different byte code, the explorer does not overwrite the previously saved byte code.

In the end the reported byte code is not the one on the chain.

## Disclosure

I wanted to see if any explorers are vulnerable to this and this is the result:

Deployer
0x2d07e106b5d280e4ccc2d10deee62441c91d4340

Good Contract / Malicious Contract
0xf4a5afe28b91cf928c2568805cfbb36d477f0b75

Not vulnerable:

- [Etherscan](https://etherscan.io/)
- [EthStats](https://ethstats.io/) - Does not display any code, even after the second deploy.
- [Amberdata](https://amberdata.io/)
- [EtherChain](https://www.etherchain.org/)
- [EthOrbit](https://explorer.ethorbit.com/#/)

Vulnerable:

- [BlockChair](https://blockchair.com/ethereum)
- [BlockScout](https://blockscout.com/eth/mainnet/)

Other block explorers that display too little information or do not display the contract code.

- [EthPlorer](https://ethplorer.io/)
- [Bloxy](https://bloxy.info/)
- [Trivial](https://trivial.co/)
- [WatchEthereum](http://watchethereum.com/)

## Aftermath

- Explorers affected
- Explorers (not) affected