// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract WhitelistNft is ERC721, Ownable {
    uint256 private _nextTokenId;   
    bytes32 public root;

    /**Errors */
    error WhitelistNft__NotAPartOfThAllowlist();

    constructor(address initialOwner, bytes32 _root) ERC721("MyToken", "MTK") Ownable(initialOwner){
        root = _root;
    }

    function safeMint(address to,bytes32[] memory proof,bytes32 leaf) public onlyOwner {
        if(!isValid(proof,leaf)){
            revert WhitelistNft__NotAPartOfThAllowlist();
        }
        uint256 tokenId = _nextTokenId++;
        _safeMint(to, tokenId);
    }

    function isValid(bytes32[] memory proof,bytes32 leaf) public view returns(bool){
        return MerkleProof.verify(proof,root,leaf);
    }
}