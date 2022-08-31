# NFT Marketplace Project - Learning process...
__Note:__ _This is an incompleted project and is for learning purpose. If you want to discuss anything about the code or any implementation, pls notify me._

---

## Overview of an NFT marketplace

An NFT marketplace is a dedicated platform for storing and trading non-fungible tokens. Items either have a fixed price, or can be bought at an auction.


Types of NFT marketplace platforms:

* Universal non-fungible token platforms sell any kind of crypto goods, be it a work of digital art or a domain name.
  * _Examples_: `Rarible`, `OpenSea` and `Mintable`.

* Niche peer-to-peer marketplaces are focused on offering particular digital assets. Y
  * _Examples_: `Valuables`, a website where you can buy and sell tweets and `Glass Factory`, where digital holograms are sold.

---
## Key Features Implementations
1. __Storefront__
    * NFT marketplace should have a storefront that offers users all the information required for an item: bids, owners, preview or price history.

2. __Filters__
    * Using filters, it becomes easier to navigate a site, specifically if you plan to build a marketplace place for a lot of collectibles. By adding the filters feature, users can select items by payment method, listing status, category and collection.

3. __Searching for items__
    * An NFT marketplace platform should support tagging and category management to allow users to search collectibles. Use a search bar on the site and add categories.

4. __Create listings__
    * A user should be able to create and submit collectibles. Using this feature, a user should upload files and fill in the token information such as name, tags, description.

5. __Buy and Bid__
    * The NFT marketplace platform should have a feature that allows users to buy and bid for NFTs listed on the platform. The bidding feature should include a bid expiration date and allow users to view details about the bids’ current status.
5. __Wallet__
    * The NFT Marketplace Platform should have a wallet that allows users to store, send and receive non-fungible tokens. The easiest way to integrate this feature is to provide users with a connected wallet that they already use. For example, you can integrate the most popular wallets like Coinbase, Formatic or MyEtherWallet.

---
# Capstone Project Setup
1. Edit _hardhat.config.js_ file
```
    hardhat: {
      chainId: 1337
    },
    goerli: {
      url: `https://polygon-mumbai.g.alchemy.com/v2/ALCHEMY_API_KEY`,
      accounts: ['PRIVATE_KEY']
    }
  },
```

2. Edit _.env_ file
```
privateKey = 
REACT_APP_PINATA_KEY = 
REACT_APP_PINATA_SECRET = 
```

3. Compile 
```shell
npx hardhat clean
npx hardhat compile
```

4. Run script on test network
```shell
npx hardhat run scripts/deploy-khaos.js --network goerli
```
_or_

Run script on local node
```shell
npx hardhat run scripts/deploy-khaos.js --network localhost
```

