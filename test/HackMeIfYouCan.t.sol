// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.7.0;

import {DSTest} from "ds-test/test.sol";
import {Vm} from "forge-std/Vm.sol";
import {HackMeIfYouCan} from "../src/HackMeIfYouCan.sol";
import {console} from "forge-std/Script.sol";

contract HackMeIfYouCanTest is DSTest {
    Vm vm = Vm(HEVM_ADDRESS);
    HackMeIfYouCan hackMe;

    bytes32 private constant PASSWORD = keccak256("password");
    bytes32[15] private DATA = [
        bytes32(0), bytes32(0), bytes32(0), bytes32(0), bytes32(0),
        bytes32(0), bytes32(0), bytes32(0), bytes32(0), bytes32(0),
        bytes32(0), bytes32(0), bytes32("key"), bytes32(0), bytes32(0)
    ];

    function setUp() public {
        hackMe = new HackMeIfYouCan(PASSWORD, DATA);
    }

    function testInitialOwner() public {
        assertEq(hackMe.owner(), address(this));
    }

    function testLockUnlock() public {
        hackMe.lock();
        assertTrue(!hackMe.unlocked());

        hackMe.lock();
        assertTrue(hackMe.unlocked());
    }

    function testContribute() public {
        vm.deal(address(this), 1 ether);
        hackMe.contribute{value: 0.0001 ether}();
        assertEq(hackMe.getContribution(), 0.0001 ether);
    }

    function testFlipWin() public {
        bool guess = true;
        bool result = hackMe.flip(guess);
        assertTrue(result || !result);
    }

    function testSendKey() public {
        hackMe.sendKey(bytes16(DATA[12]));
        assertEq(hackMe.getMarks(address(this)), 4);
    }

    function testSendPassword() public {
        hackMe.sendPassword(PASSWORD);
        assertEq(hackMe.getMarks(address(this)), 3);
    }

    function testGetMarks() public {
        assertEq(hackMe.getMarks(address(this)), 0);

        hackMe.sendKey(bytes16(DATA[12]));
        assertEq(hackMe.getMarks(address(this)), 4);

        hackMe.sendPassword(PASSWORD);
        assertEq(hackMe.getMarks(address(this)), 3);
        console.log("Marks: %d", hackMe.getMarks(address(this)));
    }

    function testReceiveUpdatesMarks() public {
        vm.deal(address(this), 1 ether);
        hackMe.contribute{value: 0.0001 ether}();

        (bool success,) = address(hackMe).call{value: 0.001 ether}("");
        require(success, "Failed to send Ether");

        assertEq(hackMe.getMarks(address(this)), 3);
    }

    receive() external payable {}
}
