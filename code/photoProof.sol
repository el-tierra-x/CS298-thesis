// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract PhotoProof is ERC721URIStorage, Ownable {
    uint256 private _tokenIdCounter;
    // Map from Merkle Root hashes to owners
    mapping(bytes32 => address) public merkleRootToOwner;
    // Map from owner to Merkle Root hashes
    mapping(address => bytes32[]) public ownerToMerkleRoots;

    event HashRegistered(
        address indexed owner, 
        uint256 tokenId, 
        bytes32 hash
    );

    constructor() ERC721("PhotoProof", "IMG") {}

    function registerPhoto(
        bytes32 rootHash, 
        string memory tokenURI
    ) public {
        require(
            merkleRootToOwner[rootHash] == address(0),
            "Hash already registered"
        );
        require(rootHash != bytes32(0), "Invalid hash");

        // Mint a new token
        uint256 tokenId = _tokenIdCounter;
        _tokenIdCounter += 1;

        _mint(msg.sender, tokenId);
        _setTokenURI(tokenId, tokenURI);

        // Update mappings
        merkleRootToOwner[rootHash] = msg.sender;
        ownerToMerkleRoots[msg.sender].push(rootHash);
    }

    /**
     * @dev Get all hashes for an owner
     */

    function getHashesByOwner(
        address owner
    ) public view returns (bytes32[] memory) {
        return ownerToMerkleRoots[owner];
    }

    /**
     * @dev Verify hash and get owner
     * @param hash The SHA-256 hash to verify
     */
    function verifyOwnership(
        bytes32 merkleRoot,
        address owner
    ) public view returns (bool) {
        return merkleRootToOwner[merkleRoot] == owner;
    }
}
