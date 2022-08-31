import Navbar from "./Navbar";
import NFTTile from "./NFTTile";
import MarketplaceJSON from "../abi/KhaosMarketplace.json";
import FactoryJSON from "../abi/KhaosNFTFactory.json";
import axios from "axios";
import { useState } from "react";

export default function Marketplace() {
    const sampleData = [
        {
            "name": "NFT#1",
            "description": "Khaos NFT",
            "image": "https://gateway.pinata.cloud/ipfs/QmNz3AcQ2udGs5eazRYM7xuaVneKjNv4qhN17Z2yzTQxCd",
            "price": "0.01ETH",
            "currentlySelling": "True",
            "address": "0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0",
        },
        {
            "name": "NFT#2",
            "description": "Khaos NFT",
            "image": "https://gateway.pinata.cloud/ipfs/QmNz3AcQ2udGs5eazRYM7xuaVneKjNv4qhN17Z2yzTQxCd",
            "price": "0.02ETH",
            "currentlySelling": "True",
            "address": "0x9Fef3AA76A2Ddb246D0962bb9a8769405929bb67",
        },
        {
            "name": "NFT#3",
            "description": "Khaos NFT",
            "image": "https://gateway.pinata.cloud/ipfs/QmNz3AcQ2udGs5eazRYM7xuaVneKjNv4qhN17Z2yzTQxCd",
            "price": "0.03ETH",
            "currentlySelling": "True",
            "address": "0x9Fef3AA76A2Ddb246D0962bb9a8769405929bb67",
        },
        {
            "name": "NFT#4",
            "description": "Khaos NFT",
            "image": "https://gateway.pinata.cloud/ipfs/QmNz3AcQ2udGs5eazRYM7xuaVneKjNv4qhN17Z2yzTQxCd",
            "price": "0.045ETH",
            "currentlySelling": "True",
            "address": "0x9Fef3AA76A2Ddb246D0962bb9a8769405929bb67",
        },
        {
            "name": "NFT#5",
            "description": "Khaos NFT",
            "image": "https://gateway.pinata.cloud/ipfs/QmNz3AcQ2udGs5eazRYM7xuaVneKjNv4qhN17Z2yzTQxCd",
            "price": "0.05ETH",
            "currentlySelling": "True",
            "address": "0x9Fef3AA76A2Ddb246D0962bb9a8769405929bb67",
        },
        {
            "name": "NFT#6",
            "description": "Khaos NFT",
            "image": "https://gateway.pinata.cloud/ipfs/QmNz3AcQ2udGs5eazRYM7xuaVneKjNv4qhN17Z2yzTQxCd",
            "price": "0.05ETH",
            "currentlySelling": "True",
            "address": "0x9Fef3AA76A2Ddb246D0962bb9a8769405929bb67",
        },
    ];
    const [data, updateData] = useState(sampleData);
    const [dataFetched, updateFetched] = useState(false);

    async function getOwnCollections() {
        const ethers = require("ethers");
        //After adding your Hardhat network to your metamask, this code will get providers and signers
        const provider = new ethers.providers.Web3Provider(window.ethereum);
        const signer = provider.getSigner();
        const addr = await signer.getAddress();
        
        //Pull the deployed contract instance
        let contract = new ethers.Contract(FactoryJSON.address, FactoryJSON.abi, signer);
        console.log(contract)



        //Fetch all the details of every NFT from the contract and display
        // const items = await Promise.all(transaction.map(async i => {

        //     const tokenURI = await contract.tokenURI(i.tokenId);
        //     let meta = await axios.get(tokenURI);
        //     meta = meta.data;
        //     console.log(meta)

        //     let price = ethers.utils.formatUnits(i.price.toString(), 'ether');

        //     let item = {
        //         price,
        //         tokenId: i.tokenId.toNumber(),
        //         seller: i.seller,
        //         owner: i.owner,
        //         image: meta.image,
        //         name: meta.name,
        //         description: meta.description,
        //     }
        //     return item;
        // }))

        updateFetched(true);
        // updateData(items);
    }

    if (!dataFetched)
        getOwnCollections();

    return (
        <div>
            <Navbar></Navbar>
            <div className="flex flex-col place-items-center mt-20">
                <div className="md:text-xl font-bold text-white">
                    Top NFTs
                </div>
                <div className="flex mt-5 justify-between flex-wrap max-w-screen-xl text-center">
                    {data.map((value, index) => {
                        return <NFTTile data={value} key={index}></NFTTile>;
                    })}
                </div>
            </div>
        </div>
    );

}