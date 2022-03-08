// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat");

async function main() {
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile
  // manually to make sure everything is compiled
  // await hre.run('compile');

  // We get the contract to deploy
  // const TitanFactory = await hre.ethers.getContractFactory("Titan");
  // const Titan = await TitanFactory.deploy("TitanTestV2", "TTitanV2");
  // await Titan.deployed();

  // console.log("Titan deployed to:", Titan.address);

  const KoiosFactory = await hre.ethers.getContractFactory("Koios");
  const Koios = await KoiosFactory.deploy(
    "KoiosV4",
    "KOIOS",
    "0xeDE3f3C411F0376dAc26C604b388098AB8E59e89",
    10
  );

  await Koios.deployed();

  console.log("Koios deployed to:", Koios.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
