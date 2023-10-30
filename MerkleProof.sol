// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.22;

/**
 * Here we are creating a Merkle Tree 
 * We can use Merkle Tree for verifications , For example we can take a bunch of transaction and create a merkle tree out of it and get its root
 * So if even of its transaction is change the whole root will change 
 * With this we can easily check if a transaction was included in the block or not 
 */

contract MerkleTreeProof {
    /**
     * @dev This function will return true if it can create the root from proof leaf and the index
     * @param proof These are the array of hashes needed to compute the merkle tree
     * @param root The merkle root itself (Which is basically the last root or the topmost branch)
     * @param leaf The hash of the element in the array that was used to construct the merkle tree
     * @param index The index in the array where element is stored
     */
    function verify(bytes32[] memory proof,bytes32 root,bytes32 leaf,uint index) public view returns(bool){
        bytes32 hash = leaf;

        //Recompute the merkle root
        for(uint i = 0; i < proof.length; i++){
            //We need to first compute the parent hash first from the very bottom in the merkle tree , indexes of left are all even and right are all odd
            //Now this will give us the hash one level abhove from the very bottom the merkle tree
            if(index % 2 == 0){
                hash = keccak256(abi.encodePacked(hash,proof[i]));
            }else{
                hash = keccak256(abi.encodePacked(proof[i],hash));
            }
            index = index / 2;
        }
        //This condition is to check when the hash will be equal to the root and return it at that point
        return hash == root;
    }
}


contract TestMerkleProof is MerkleTreeProof {
    bytes32[] public hashes;

    constructor() {
        string[4] memory transactions = [
            "alice -> bob",
            "bob -> dave",
            "carol -> alice",
            "dave -> bob"
        ];

        for (uint i = 0; i < transactions.length; i++) {
            hashes.push(keccak256(abi.encodePacked(transactions[i])));
        }

        uint n = transactions.length;
        uint offset = 0;

        while (n > 0) {
            for (uint i = 0; i < n - 1; i += 2) {
                hashes.push(
                    keccak256(
                        abi.encodePacked(hashes[offset + i], hashes[offset + i + 1])
                    )
                );
            }
            offset += n;
            n = n / 2;
        }
    }

    function getRoot() public view returns (bytes32) {
        return hashes[hashes.length - 1];
    }

    /* verify
    3rd leaf
    0xdca3326ad7e8121bf9cf9c12333e6b2271abe823ec9edfe42f813b1e768fa57b

    root
    0xcc086fcc038189b4641db2cc4f1de3bb132aefbd65d510d817591550937818c7

    index
    2

    proof
    0x8da9e1c820f9dbd1589fd6585872bc1063588625729e7ab0797cfc63a00bd950
    0x995788ffc103b987ad50f5e5707fd094419eb12d9552cc423bd0cd86a3861433
    */
}

