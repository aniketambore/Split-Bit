# Split Bit

- A Blockchain based basic project, which focuses on interacting with the smart-contract via web3dart in flutter.

## Preview
<img src="https://i.ibb.co/DWrxxhF/Untitled1.gif" width="80%">

## Initial Setup
- Meta-Mask, Chrome Extension installation.
- Infura to connect with the RPC server.
- Deployed Smart-Contract on Remix-Ethereum IDE.

## Setup Your Meta-Mask wallet.
![Setup MetaMask](assets/diagram.svg)

##  Deploy SmartContract.
- Create Simple Smart-Contract using Solidity Programing Language via [Remix-Ethereum Ide](https://remix.ethereum.org)
- Just Copy/Paste the SmartContract code from `lib ➡ SplitCoin.sol`
- Compile it
![Compile Contract](assets/screenshot_compile.png)
- Deploy it
![Deploy Contract](assets/screenshot_deploy.png)
- Copy ABI
![Copy Contract ABI](assets/Screenshot.png)
- Paste ABI in out project as, `assets/abi.json`

## Infura
- Create your account on [infura](https://infura.io/)
![Infura Sequence](assets/infura_sequence.svg)

---

## ether_splitter.dart
- Add appropriate credentials, as mentioned by comments.

| //Paste your MetaMask address | ![MetaMask Address](assets/comment_1.png) |
| ---------------------------- | ---------------------------- |
| //Paste Your Infura Test API EndPoint link | ![Infura EndPoint Link](assets/comment_2.png) |
| //Paste the deployed contract address from Remix IDE | ![Deployed Smart Contract](assets/comment_3.png) |
| //Export the meta mask private key and paste here | ![MetaMask Private Key](assets/comment_4.png) |


## Thats it !



