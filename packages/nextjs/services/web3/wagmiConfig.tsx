import { Chain, createClient, fallback, http } from "viem";
import { hardhat, mainnet } from "viem/chains";
import {createConfig} from '@privy-io/wagmi';
import scaffoldConfig, { DEFAULT_ALCHEMY_API_KEY, monadTestnet } from "~~/scaffold.config";
import { getAlchemyHttpUrl } from "~~/utils/scaffold-eth";

const { targetNetworks } = scaffoldConfig;

// We always want to have mainnet enabled (ENS resolution, ETH price, etc). But only once.
export const enabledChains = targetNetworks.find((network: Chain) => network.id === 1)
  ? targetNetworks
  : ([...targetNetworks, mainnet] as const);

export const wagmiConfig = createConfig({
  chains: enabledChains,
  ssr: true,
  client({ chain }) {
    let rpcFallbacks = [http()];

    const isMonadDevChain = chain.id === monadTestnet.id;

    // Use MonadDev RPC URL if chainId matches
    const rpcUrl = isMonadDevChain ? chain.rpcUrls.default.http[0] : getAlchemyHttpUrl(chain.id);

    if (rpcUrl) {
      const isUsingDefaultKey = scaffoldConfig.alchemyApiKey === DEFAULT_ALCHEMY_API_KEY;
      // If using default Scaffold-ETH 2 API key, we prioritize the default RPC
      rpcFallbacks = isUsingDefaultKey ? [http(), http(rpcUrl)] : [http(rpcUrl), http()];
    }

    return createClient({
      chain,
      transport: fallback(rpcFallbacks),
      ...(chain.id !== (hardhat as Chain).id
        ? {
            pollingInterval: scaffoldConfig.pollingInterval,
          }
        : {}),
    });
  },
});
