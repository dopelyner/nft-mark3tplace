const { ethers } = require("ethers");

function main() {
    const { deployer } = await ethers.getSigner();

    console.log("Deploying contracts with the accounts:", deployer.address);
    console.log("Accoutn balance:", (await deployer.getBalance().toString()));

    saveFrontEndFiles();
}

function saveFrontEndFiles(contract, name) {
    const fs = require("fs");
    const contractDir = __dirname + "/../../contractsData";

    if(fs.existsSync(contractDir)) {
        fs.mkdirSync(contractDir);
    }

    fs.writeFileSync(
        contractDir + `/${name}-address.json`,
        JSON.stringify({ address: contract.address }, undefined, 2)
    );

    const contractArtifact = artifacts.readArtifactSync(name);

    fs.writeFileSync(
        contractDir + `${name}.json`,
        JSON.stringify(contractArtifact, null, 2);
    );
}

main()