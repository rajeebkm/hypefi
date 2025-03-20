import { ethers, upgrades, network } from "hardhat";
import { networkConfig } from "../helper-hardhat-config";
import { updateContractsJson } from "../../utils/updateContracts";

export const setupContracts = async () => {
  const accounts = await ethers.getSigners();
  const networkName = network.name;
  const owner = accounts[0].address;
  const deployer = networkConfig[networkName].deployer;
  console.log(owner);

  if (deployer?.toLowerCase() !== owner.toLowerCase()) {
    throw Error("Deployer must be the Owner");
  }
  const startBlock: any = await ethers.provider.getBlock("latest");
  // console.log(startBlock!.number)

  const HypeFiRewards = await ethers.getContractFactory("HypeFiRewards");
  const hypeFiRewards = await HypeFiRewards.deploy();
  await hypeFiRewards.waitForDeployment();
  // console.log("HypeFiRewards deployed:", hypeFiRewards.target)

  const HYPEFI_RECS = "0x60187Bc4949eE2F01b507a9F77ad615093f44260"; // HyperRecs multisig wallet
  const protocolFeeRecipient = HYPEFI_RECS;
  // const protocolRewards = "0x861cFE36400580A699e09e9B95a19F1C9fdd255e"; // Base Sepolia ProtocolRewards
  const protocolRewards = hypeFiRewards.target;
  const weth = "0x4200000000000000000000000000000000000006"; // Base Sepolia WETH (For Testing)
  const nonfungiblePositionManager = "0x46A15B0b27311cedF172AB29E4f4766fbE7F4364"; // Base Sepolia NonfungiblePositionManager
  const swapRouter = "0x1b81D678ffb9C0263b24A97847620C99d213eB14"; // Base Sepolia Swap Router

  // Deploy Contract
  const HypeFiToken = await ethers.getContractFactory("HypeFi");
  const hypeFiToken = await HypeFiToken.deploy(
    protocolFeeRecipient,
    protocolRewards,
    weth,
    nonfungiblePositionManager,
    swapRouter,
  );
  await hypeFiToken.waitForDeployment();
  console.log("HypeFiToken deployed:", hypeFiToken.target);

  const BondingCurve = await ethers.getContractFactory("BondingCurve");
  const bondingCurve = await BondingCurve.deploy();
  await bondingCurve.waitForDeployment();
  console.log("BondingCurve deployed:", bondingCurve.target);

  const AirdropContract = await ethers.getContractFactory("AirdropContract");
  const airdropContract = await AirdropContract.deploy();
  await airdropContract.waitForDeployment();
  console.log("AirdropContract deployed:", airdropContract.target);

  const HypeFiFactory = await ethers.getContractFactory("HypeFiFactory");
  const hypeFiFactory = await upgrades.deployProxy(HypeFiFactory, [
    owner,
    hypeFiToken.target,
    bondingCurve.target,
    airdropContract.target,
  ]);
  await hypeFiFactory.waitForDeployment();
  console.log("HypeFiFactory deployed:", hypeFiFactory.target);

  const contracts = [
    { name: "HypeFiRewards", address: hypeFiRewards.target },
    { name: "HypeFi", address: hypeFiToken.target },
    { name: "BondingCurve", address: bondingCurve.target },
    { name: "AirdropContract", address: airdropContract.target },
    { name: "HypeFiFactory", address: hypeFiFactory.target },
    { name: "StartBlock", address: startBlock.number },
    {
      name: "Core_Subgraph",
      address: "",
    },
  ];

  updateContractsJson(contracts);
  console.table(contracts);

  console.log("🚀🚀🚀 HypeFi Deployment Successful 🚀🚀🚀");
};

setupContracts()
  .then(() => process.exit(0))
  .catch((error: any) => {
    console.error(error);
    process.exit(1);
  });
