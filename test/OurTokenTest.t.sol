// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

import {DeployOurToken} from "../script/DeployOurToken.s.sol";
import {OurToken} from "../src/OurToken.sol";
import {Test, console} from "forge-std/Test.sol";
import {StdCheats} from "forge-std/StdCheats.sol";

interface MintableToken {
    function mint(address _to, uint256 _amount) external;
}

contract OurTokenTest is StdCheats, Test {
    uint256 BOB_STARTING_AMOUNT = 100 ether;

    OurToken public token;
    DeployOurToken public deployer;
    address public deployerAddress;
    address bob;
    address alice;

    function setUp() public {
        deployer = new DeployOurToken();
        token = deployer.run();

        bob = makeAddr("bob");
        alice = makeAddr("alice");

        deployerAddress = vm.addr(deployer.deployerKey());
        vm.prank(deployerAddress);
        token.transfer(bob, BOB_STARTING_AMOUNT);
    }

    function testInitialSupply() public {
        // console.log("Token Total Supply: %s", token.totalSupply());
        // console.log("Deployer Initial Supply: %s", deployer.INITIAL_SUPPLY());
        assertEq(token.totalSupply(), deployer.INITIAL_SUPPLY());
    }

    function testUsersCantMint() public {
        vm.expectRevert();
        MintableToken(address(token)).mint(address(this), 1);
    }

    function testAllowances() public {
        uint initialAllowance = 1000;

        vm.prank(bob);
        token.approve(alice, initialAllowance);

        uint256 transferAmount = 500;

        vm.prank(alice);
        token.transferFrom(bob, alice, transferAmount);
        assertEq(token.balanceOf(alice), transferAmount);
        assertEq(token.balanceOf(bob), BOB_STARTING_AMOUNT - transferAmount);
    }
}
