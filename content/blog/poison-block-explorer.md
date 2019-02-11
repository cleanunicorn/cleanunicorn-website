---
title: "Poison Block Explorer"
date: 2019-02-09T15:56:15+02:00
draft: false
---

I will show you how to trick a block explorer to display a different byte code than the one actually deployed on the chain.

This is important because a user can be tricked by a hacker to think it interacts with a good contract, when actually the user interacts with malicious contract. It is indeed the same contract address, but the byte code is not the one reported by the block explorer.

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

Below is a malicious contract that accepts funds and can send all of the accepted funds to the owner. Your funds are not safe if you send your ether there. The owner can steal it all:

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

The method `createGood()` pretends to deploy the good contract, but in the end it reverts the transaction. Trying to deploy the good contract means that it creates a message that contains the **byte code** and the **new contract address**. Reverting the transaction means no new contract is deployed and that the contract's **nonce** is not changed.

The address for an Ethereum contract is deterministically computed from the **address** of its creator and the creator's **nonce**. We can define it like this without going into detail:

$${address} = f({sender}, {nonce})$$

The method `createGood()` does not increase the contract's **nonce** because it reverts. This means that calling `createMalicous()` will generate the same address for the newly deployed contract but this time it will not revert but it will have a different **byte code**.

This is exactly what the `Deployer` contract exploits.

## Tricking the block explorer

To trick the block explorer you need 2 actions:

1. The hacker first calls `createGood()` and a contract message containing the **byte code** and the **new contract address** will be generated. If the block explorer does not handle the `revert()` properly, the **byte code** will be associated with the **new contract address**.

2. The hacker then calls `createMalicious()` which creates another contract message containing a different **byte code** but the **same contract address**.

The block explorer must handle the errors properly and only save the byte code when the contract message succeeds. Otherwise it will associate an incorrect byte code with a contract address.

The users checking the contract will see an incorrect byte code on the website. They will think they interact with a good contract when actually they interact with a malicious one.

## Result

The block explorer reports an incorrect byte code for a specific contract. This happens because we first pretend to deploy a contract and then revert. The block explorer parses the pretend and saves the byte code as the one deployed. When we actually deploy a new contract with a different byte code, the explorer does not overwrite the previously saved byte code.

In the end the reported byte code is not the one on the chain.

## Disclosure

I wanted to see if any explorers are vulnerable to this and this is the result:

- Deployer contract instance `0x2d07e106b5d280e4ccc2d10deee62441c91d4340`
- Good Contract / Malicious Contract `0xf4a5afe28b91cf928c2568805cfbb36d477f0b75`
- Transaction that calls pretends to deploy the good contract `0x9f4be1e7dac38999bf54af767983c9bf7e5f328d257883abbcd029e4989ccc69`
- Transaction that deploys the malicious contract `0x3d1acd9ae5e9594b93d6529ac77c39bc4f570b360c4778350e5851460489ce65`

I am in the process of contacting the explorers that have this problem to help them fix the issue.

Explorers not vulnerable:

- [Etherscan](https://etherscan.io/)
- [EthStats](https://ethstats.io/)
- [Amberdata](https://amberdata.io/) - Does not display any code, even after the second deploy.
- [EtherChain](https://www.etherchain.org/)
- [EthOrbit](https://explorer.ethorbit.com/)

Exploreres vulnerable:

- [BlockChair](https://blockchair.com/ethereum)
- [BlockScout](https://blockscout.com/eth/mainnet/)

Other block explorers that display too little information or do not display the contract code:

- [EthPlorer](https://ethplorer.io/)
- [Bloxy](https://bloxy.info/)
- [Trivial](https://trivial.co/)
- [WatchEthereum](http://watchethereum.com/)
