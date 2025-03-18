// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
interface IHypeFiFactory {
    /// @notice Emitted when a new HypeFi token is created
    /// @param factoryAddress The address of the factory that created the token
    /// @param tokenCreator The address of the creator of the token
    /// @param protocolFeeRecipient The address of the protocol fee recipient
    /// @param bondingCurve The address of the bonding curve
    /// @param tokenURI The URI of the token
    /// @param name The name of the token
    /// @param symbol The symbol of the token
    /// @param tokenAddress The address of the token
    /// @param poolAddress The address of the pool
    /// @param airdropContract The address of the airdrop contract
    event HypeFiTokenCreated(
        address indexed factoryAddress,
        address indexed tokenCreator,
        address protocolFeeRecipient,
        address bondingCurve,
        string tokenURI,
        string name,
        string symbol,
        address tokenAddress,
        address poolAddress,
        address airdropContract
    );

    /// @notice Deploys a HypeFi ERC20 token
    /// @param _tokenCreator The address of the token creator
    /// @param _tokenURI The ERC20z token URI
    /// @param _name The ERC20 token name
    /// @param _symbol The ERC20 token symbol
    /// @param _merkleRoots The merkle roots of the airdrop
    /// @param _airdropPercent The percentage of the airdrop
    function deploy(
        address _tokenCreator,
        string memory _tokenURI,
        string memory _name,
        string memory _symbol,
        bytes32[] calldata _merkleRoots,
        uint32 _airdropPercent
    ) external payable returns (address);
}
