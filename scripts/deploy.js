const { ethers } = require("hardhat");

async function main() {
  const CreatorMint = await ethers.getContractFactory("CreatorMint");
  const creatorMint = await CreatorMint.deploy();

  await creatorMint.deployed();

  console.log("CreatorMint contract deployed to:", creatorMint.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
