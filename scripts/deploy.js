const hre = require("hardhat");

async function main() {
  
  const Vesting = await hre.ethers.getContractFactory("vestingToken");
  const vesting = await Vesting.deploy();

  await vesting.deployed();

  console.log("Greeter deployed to:", vesting.address);

  console.log("Sleeping ...");
  await sleep(60000);

  await hre.run("verify:verify",{
    address : vesting.address,
  })
}


function sleep(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });