// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.7.0;

import {Script, console} from "forge-std/Script.sol";
import {HackMeIfYouCan} from "../src/HackMeIfYouCan.sol";

contract CheckMarks is Script {
    function run() external {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(privateKey);

        // Adresse du contrat déployé sur Sepolia
        address payable contractAddress = payable(vm.envAddress("CONTRACT_ADDRESS"));
        HackMeIfYouCan hackMe = HackMeIfYouCan(contractAddress);
        
        // Récupérez les marks pour l'adresse actuelle
        uint256 marks = hackMe.getMarks(0x6c9622A0472681f150773108C0A8662A0528c6Ef);
        console.log("Marks after actions", marks);

        vm.stopBroadcast();
    }

    event LogUint(string message, uint256 val);
}
