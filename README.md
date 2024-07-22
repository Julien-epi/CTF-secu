README
Introduction
This README provides instructions for executing the AttackHackMeIfYouCan script, designed to exploit the HackMeIfYouCan smart contract deployed on the Ethereum Sepolia testnet.

Prerequisites
Foundry: Ensure you have Foundry installed. Foundry is a development toolkit for Ethereum.

Installation instructions can be found here.
Environment Variables:

PRIVATE_KEY: Your private key to sign transactions.
CONTRACT_ADDRESS: The address of the deployed HackMeIfYouCan contract on Sepolia.
Setup and Execution
1. Set Up Environment Variables
Create a .env file in the root directory with the following content:

PRIVATE_KEY=<your_private_key>
CONTRACT_ADDRESS=<contract_address_on_sepolia>
2. Install Foundry and Dependencies
Ensure Foundry is installed and all dependencies are up-to-date. Run the following commands:


curl -L https://foundry.paradigm.xyz | 
foundryup
forge install
3. Compile the Script
Compile the script to ensure there are no errors:


forge build
4. Run the Script
Execute the script using Foundry. This will connect to the Sepolia testnet and broadcast the transactions:

forge script script/AttackHackMeIfYouCan.s.sol:AttackHackMeIfYouCan --fork-url https://eth-sepolia.g.alchemy.com/v2/KSzIF7Y-M-fCzr3yF1iz_5A_YwrZel1D --broadcast --legacy

5. Check the Results
After running the script, 

- forge script script/CheckMarks.s.sol:CheckMarks --fork-url https://eth-sepolia.g.alchemy.com/v2/KSzIF7Y-M-fCzr3yF1iz_5A_YwrZel1D --broadcast --legacy