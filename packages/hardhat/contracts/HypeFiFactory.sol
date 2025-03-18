// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import { Clones } from "@openzeppelin/contracts/proxy/Clones.sol";
import { OwnableUpgradeable } from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import { ReentrancyGuardUpgradeable } from "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";
import { UUPSUpgradeable } from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import { ERC1967Utils } from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Utils.sol";
import { IHypeFiFactory } from "./interfaces/IHypeFiFactory.sol";
import { HypeFi } from "./HypeFi.sol";
import { AirdropContract } from "./AirdropContract.sol";

//import "hardhat/console.sol";
/// @title HypeFiFactory
/// @notice This contract is responsible for deploying HypeFi tokens with bonding curve mechanics and associated contracts.
contract HypeFiFactory is IHypeFiFactory, UUPSUpgradeable, ReentrancyGuardUpgradeable, OwnableUpgradeable {
    /// ==================== State Variables ==================== ///
    /// @notice Address of the airdrop implementation contract
    address public airdropImplementation;

    /// @notice Address of the token implementation contract
    address public tokenImplementation;

    /// @notice Address of the bonding curve contract
    address public bondingCurve;

    /// @notice Counter for the number of tokens created
    uint256 public tokenCount;

    mapping(bytes32 => uint32) public validMerkleRoots;

    /// @notice Constant representing the basis points used for percentage calculations
    uint256 public constant BASIS_POINTS = 1000000;

    /// ==================== Errors ==================== ///
    error InvalidParameters();
    error InvalidAirdropPercentage();
    error InvalidMerkleRoot();

    /// ==================== Constructor ==================== ///
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() payable {
        _disableInitializers();
    }

    /// ==================== External Functions ==================== ///
    /// @notice Creates a HypeFi token with bonding curve mechanics that graduates to Uniswap V3
    /// @param _tokenCreator The address of the token creator
    /// @param _tokenURI The ERC20z token URI
    /// @param _name The ERC20 token name
    /// @param _symbol The ERC20 token symbol
    /// @param _merkleRoots The Merkle roots for airdrop verification
    /// @param _airdropPercent The percentage of tokens to be airdropped
    /// @return The address of the newly created HypeFi token
    function deploy(
        address _tokenCreator,
        string memory _tokenURI,
        string memory _name,
        string memory _symbol,
        bytes32[] calldata _merkleRoots,
        uint32 _airdropPercent
    ) external payable nonReentrant returns (address) {
        bytes32 salt = _generateSalt(_tokenCreator, _tokenURI);
        _validateCreateTokenParams(_name, _symbol, _tokenURI, _tokenCreator);

        uint32 airdropRecipientCount = _calculateAirdropRecipientCount(_merkleRoots, _airdropPercent);

        uint256 airdropAmount = (10_000_000_000 ether / BASIS_POINTS) * _airdropPercent;
        HypeFi token = HypeFi(payable(Clones.cloneDeterministic(tokenImplementation, salt)));

        address airdropContract = Clones.clone(airdropImplementation);
        AirdropContract(airdropContract).initialize(
            address(token),
            _tokenCreator,
            _merkleRoots,
            airdropAmount,
            airdropRecipientCount
        );

        token.initialize{ value: msg.value }(
            _tokenCreator,
            bondingCurve,
            _tokenURI,
            _name,
            _symbol,
            _merkleRoots,
            airdropAmount,
            address(airdropContract)
        );

        tokenCount++;

        emit HypeFiTokenCreated(
            address(this),
            _tokenCreator,
            token.protocolFeeRecipient(),
            bondingCurve,
            _tokenURI,
            _name,
            _symbol,
            address(token),
            token.poolAddress(),
            address(airdropContract)
        );

        return address(token);
    }

    /// @notice Initializes the factory proxy contract
    /// @param _owner Address of the contract owner
    /// @dev Can only be called once due to initializer modifier
    function initialize(
        address _owner,
        address _tokenImplementation,
        address _bondingCurve,
        address _airdropImplementation
    ) external initializer {
        __UUPSUpgradeable_init();
        __ReentrancyGuard_init();
        __Ownable_init(_owner);
        tokenCount = 0;
        tokenImplementation = _tokenImplementation;
        bondingCurve = _bondingCurve;
        airdropImplementation = _airdropImplementation;
    }

    function _calculateAirdropRecipientCount(
        bytes32[] memory _merkleRoots,
        uint32 _airdropPercent
    ) internal view returns (uint32 recipentCount) {
        /// @dev The airdrop percentage is calculated in basis points, where 100% is equivalent to 1,000,000.
        /// Therefore, an airdrop percentage of 10,000 represents 1% of the total supply.

        if (_airdropPercent > 0) {
            if (_airdropPercent < 10000 || _airdropPercent > (BASIS_POINTS / 2)) revert InvalidAirdropPercentage();
            if (_merkleRoots.length > 4) revert InvalidMerkleRoot();
            for (uint256 i = 0; i < _merkleRoots.length; i++) {
                uint32 validMerkleRootHolderCount = validMerkleRoots[_merkleRoots[i]];
                if (validMerkleRootHolderCount == 0) {
                    revert InvalidMerkleRoot();
                } else {
                    recipentCount += validMerkleRootHolderCount;
                }
            }
        }
    }

    /// @notice The implementation address of the factory contract
    /// @return The address of the current implementation
    function implementation() external view returns (address) {
        return ERC1967Utils.getImplementation();
    }

    function updateMerkleRoot(bytes32 _merkleRoot, uint32 _holderCount) external onlyOwner {
        if (_merkleRoot == 0) revert InvalidMerkleRoot();
        if (_holderCount == 0) revert InvalidParameters();
        validMerkleRoots[_merkleRoot] = _holderCount;
    }

    /// ==================== Private Functions ==================== ///
    /// @notice Validates the parameters for creating a token
    /// @param _name The ERC20 token name
    /// @param _symbol The ERC20 token symbol
    /// @param _tokenURI The ERC20z token URI
    /// @param _tokenCreator The address of the token creator
    function _validateCreateTokenParams(
        string memory _name,
        string memory _symbol,
        string memory _tokenURI,
        address _tokenCreator
    ) private pure {
        if (
            bytes(_name).length == 0 ||
            bytes(_symbol).length == 0 ||
            bytes(_tokenURI).length == 0 ||
            _tokenCreator == address(0)
        ) revert InvalidParameters();
    }

    /// ==================== Internal Functions ==================== ///
    /// @notice Generates a unique salt for deterministic deployment
    /// @param _tokenCreator The address of the token creator
    /// @param _tokenURI The ERC20z token URI
    /// @return A unique salt for deployment
    function _generateSalt(address _tokenCreator, string memory _tokenURI) internal view returns (bytes32) {
        return
            keccak256(
                abi.encodePacked(
                    msg.sender,
                    _tokenCreator,
                    keccak256(abi.encodePacked(_tokenURI)),
                    block.coinbase,
                    block.number,
                    block.prevrandao,
                    block.timestamp,
                    tx.gasprice,
                    tx.origin
                )
            );
    }

    /// @notice Authorizes an upgrade to a new implementation
    /// @param _newImpl The new implementation address
    function _authorizeUpgrade(address _newImpl) internal override onlyOwner {}
}
