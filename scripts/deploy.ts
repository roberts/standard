const { ethers, defender } = require("hardhat");

async function main() {
    const DRCS = await ethers.getContractFactory("DRCS");
    const deployment = await defender.deployProxy(DRCS, [42]);
    await deployment.waitForDeployment();
    console.log("DRCS deployed to:", await deployment.getAddress());
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});