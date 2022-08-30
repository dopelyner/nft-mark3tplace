require("@nomiclabs/hardhat-waffle");
require("@nomiclabs/hardhat-ethers");
const fs = require('fs');
// const infuraId = fs.readFileSync(".infuraid").toString().trim() || "";

task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

module.exports = {
  defaultNetwork: "hardhat",
  networks: {
    hardhat: {
      chainId: 1337
    },
    mumbai: {
      url: `https://polygon-mumbai.g.alchemy.com/v2/I2RmBYMKA0SocRsNsMsQje9tqUtvv5I4`,
      accounts: process.env.privateKey
    },
    matic: {
      url: "https://polygon-mainnet.g.alchemy.com/v2/I2RmBYMKA0SocRsNsMsQje9tqUtvv5I4",
      accounts: process.env.privateKey
    },
    goerli: {
      url: `https://eth-goerli.g.alchemy.com/v2/I2RmBYMKA0SocRsNsMsQje9tqUtvv5I4`,
      accounts: process.env.privateKey
    }
  },
  solidity: {
    version: "0.8.13",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200
      }
    }
  }
};