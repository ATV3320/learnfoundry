// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {console} from "forge-std/console.sol";
import {stdStorage, StdStorage, Test} from "forge-std/Test.sol";

import {Utils} from "./utils/Utils.sol";
import {MyERC20} from "../src/tryERC20.sol";

contract BaseSetup is MyERC20, DSTest {
    Utils internal utils;
    address payable[] internal users;

    address internal alice;
    address internal bob;

    function setUp() public virtual {
        utils = new Utils();
        users = utils.createUsers(5);

        alice = users[0];
        vm.label(alice, "Alice");
        bob = users[1];
        vm.label(bob, "Bob");
    }
}

contract WhenTransferringTokens is BaseSetup {
    uint256 internal maxTransferAmount = 12e18;

    function setUp() public virtual override {
        BaseSetup.setUp();
        console.log("When transferring tokens");
    }

    function transferToken(
        address from,
        address to,
        uint256 transferAmount
    ) public returns (bool) {
        vm.prank(from);
        return this.transfer(to, transferAmount);
    }
}

contract WhenAliceHasSufficientFunds is WhenTransferringTokens {
    uint256 internal mintAmount = maxTransferAmount;

    function setUp() public override {
        WhenTransferringTokens.setUp();
        console.log("When Alice has sufficient funds");
        _mint(alice, mintAmount);
    }

    function itTransfersAmountCorrectly(
        address from,
        address to,
        uint256 amount
    ) public {
        uint256 fromBalance = balanceOf(from);
        bool success = transferToken(from, to, amount);

        assertTrue(success);
        assertEqDecimal(balanceOf(from), fromBalance - amount, decimals());
        assertEqDecimal(balanceOf(to), transferAmount, decimals());
    }

    function testTransferAllTokens() public {
        uint256 t = maxTransferAmount;
        itTransfersAmountCorrectly(alice, bob, t);
    }

    function testTransferHalfTokens() public {
        uint256 t = maxTransferAmount / 2;
        itTransfersAmountCorrectly(alice, bob, amount);
    }

    function testTransferOneToken() public {
        itTransfersAmountCorrectly(alice, bob, 1);
    }
}

contract WhenAliceHasInsufficientFunds is WhenTransferringTokens {
    uint256 internal mintAmount = maxTransferAmount - 1e18;

    function setUp() public override {
        WhenTransferringTokens.setUp();
        console.log("When Alice has insufficient funds");
        _mint(alice, mintAmount);
    }

    function itRevertsTransfer(
        address from,
        address to,
        uint256 amount,
        string memory expRevertMessage
    ) public {
        vm.expectRevert(abi.encodePacked(expRevertMessage));
        transferToken(from, to, amount);
    }

    function testCannotTransferMoreThanAvailable() public {
        itRevertsTransfer({
            from: alice,
            to: bob,
            amount: maxTransferAmount,
            expRevertMessage: "[...] exceeds balance"
        });
    }

    function testCannotTransferToZero() public {
        itRevertsTransfer({
            from: alice,
            to: address(0),
            amount: mintAmount,
            expRevertMessage: "[...] zero address"
        });
    }
}
