import { network } from "hardhat";

async function main() {
  const { ethers } = await network.connect();

  const Contract = await ethers.getContractFactory("CarMileage");
  const contract = await Contract.deploy();

  await contract.waitForDeployment();

  console.log("Deployed to:", await contract.getAddress());
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
