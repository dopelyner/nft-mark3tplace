const { ethers } = require("hardhat");
const hre = require("hardhat");
const fs = require("fs");

async function main() {
    const [deployer] = await ethers.getSigners();
    const signers = await ethers.getSigners();
    const addr = signers[0].address;
    let balance = await deployer.getBalance();
    let balanceInEthers = ethers.utils.formatEther(balance);
    console.log("Deployer                   |", addr);
    console.log("Deployer's balance         |", balanceInEthers);

    const Factory = await hre.ethers.getContractFactory("KhaosNFTFactory");
    const factory = await Factory.deploy();
    await factory.deployed();
    console.log("KHS Factory Address        |", factory.address);

    const policyFee = 2500;
    const feeRecipient = signers[0].address; // deployer
    const Marketplace = await hre.ethers.getContractFactory("KhaosMarketplace");
    const marketplace = await Marketplace.deploy(policyFee, feeRecipient, factory.address);
    await marketplace.deployed();
    console.log("KHS Marketplace Address    |", marketplace.address);
    console.log("Market Fee                 |", policyFee / 1000, "%");
    console.log("Fee Recipient              |", feeRecipient);

    const KhaosNFT = await hre.ethers.getContractFactory("KhaosNFT");
    const royalty = 3000;
    const nft = await KhaosNFT.deploy("Khaos NFT", "KHS", deployer.address, royalty, deployer.address);
    await nft.deployed();
    console.log("NFT #1                     |", nft.address);
    console.log("Royalty Fee                |", royalty / 1000, "%");
    console.log("Royalty Recipient          |", deployer.address);

    const uri = "https://gateway.pinata.cloud/ipfs/QmNz3AcQ2udGs5eazRYM7xuaVneKjNv4qhN17Z2yzTQxCd";
    nft.safeMint(deployer.address, uri);
    await marketplace.connect(deployer).addPayableToken(nft.address);
    console.log("Add payable token          |", nft.address);
    let create = await factory.connect(deployer).createNFTCollection("Artemis", "ARTMS", 3000, deployer.address);
    let getCollection = await factory.connect(deployer).getOwnCollections();
    
    console.log(create)
    console.log(getCollection)

    /**
     *  Export data to JSON files
     */
    const data = {
        address: marketplace.address,
        abi: JSON.parse(marketplace.interface.format('json'))
    }
    //This writes the ABI and address to the KhaosMarketplace.json
    fs.writeFileSync('./src/abi/KhaosMarketplace.json', JSON.stringify(data))
    console.log("abi                        | ./src/abi/KhaosMarketplace.json")

    const NFTdata = {
        address: nft.address,
        abi: JSON.parse(nft.interface.format('json'))
    }
    //This writes the ABI and address to the KhaosNFT.json
    fs.writeFileSync('./src/abi/KhaosNFT.json', JSON.stringify(NFTdata))
    console.log("abi                        | ./src/abi/KhaosNFT.json")

    const FactoryData = {
        address: factory.address,
        abi: JSON.parse(factory.interface.format('json'))
    }
    //This writes the ABI and address to the KhaosNFTFactory.json
    fs.writeFileSync('./src/abi/KhaosNFTFactory.json', JSON.stringify(FactoryData))
    console.log("abi                        | ./src/abi/KhaosNFTFactory.json")
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });