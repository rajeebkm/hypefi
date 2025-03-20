export interface networkConfigItem {
  chainId: number;
  goldskySlug?: string;
  deployer: string;
  protocolTreasury?: string;
  StartBlock?: number;
}

export interface networkConfigInfo {
  [key: string]: networkConfigItem;
}

export const networkConfig: networkConfigInfo = {
  hardhat: {
    chainId: 31337,
    goldskySlug: "hardhat",
    deployer: "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266",
    protocolTreasury: "",
  },
  localhost: {
    chainId: 31337,
    goldskySlug: "localhost",
    deployer: "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266",
    protocolTreasury: "",
  },
  coreTestnet: {
    chainId: 1114,
    goldskySlug: "core-testnet",
    deployer: "0x2dC727b15203992B65D7ADbc0108781f1Cb1F9F3",
    protocolTreasury: "",
  },
};

export const forkedChain = ["localhost"];
export const testNetworkChains = ["coreTestnet"];
export const VERIFICATION_BLOCK_CONFIRMATIONS = 6;
