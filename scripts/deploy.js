const hre = require("hardhat");

async function main() {
  console.log("ChronoVault kontrati deploy ediliyor...");

  const ChronoVault = await hre.ethers.getContractFactory("ChronoVault");
  const vault = await ChronoVault.deploy();
  await vault.waitForDeployment();

  const address = await vault.getAddress();
  console.log("\n✅ Basarili! ChronoVault kontrat adresi:");
  console.log(address);
  console.log("\nBu adresi frontend/index.html icindeki CONTRACT_ADDRESS alanina yapistir.");
  console.log("Explorer: https://testnet.arcscan.app/address/" + address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
