// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @title CreatorMint - A decentralized NFT minting platform for creators
/// @author
contract CreatorMint {
    struct NFT {
        uint256 id;
        string title;
        string uri;
        address payable creator;
        address payable owner;
        uint256 price;
        bool forSale;
    }

    uint256 public nftCount;
    mapping(uint256 => NFT) public nfts;
    mapping(address => uint256[]) public ownerToNftIds;

    event NFTMinted(uint256 indexed id, address indexed creator, string title, string uri, uint256 price);
    event NFTListed(uint256 indexed id, uint256 price);
    event NFTUnlisted(uint256 indexed id);
    event NFTPurchased(uint256 indexed id, address indexed buyer, uint256 price);

    function mintNFT(string memory _title, string memory _uri, uint256 _price) external {
        require(bytes(_title).length > 0, "Title required");
        require(bytes(_uri).length > 0, "URI required");
        require(_price > 0, "Price must be positive");

        nftCount++;
        nfts[nftCount] = NFT(
            nftCount,
            _title,
            _uri,
            payable(msg.sender),
            payable(msg.sender),
            _price,
            true
        );
        ownerToNftIds[msg.sender].push(nftCount);
        emit NFTMinted(nftCount, msg.sender, _title, _uri, _price);
    }

    function listNFT(uint256 _id, uint256 _price) external {
        NFT storage nft = nfts[_id];
        require(msg.sender == nft.owner, "Not NFT owner");
        require(_price > 0, "Invalid price");
        nft.price = _price;
        nft.forSale = true;
        emit NFTListed(_id, _price);
    }

    function unlistNFT(uint256 _id) external {
        NFT storage nft = nfts[_id];
        require(msg.sender == nft.owner, "Not NFT owner");
        nft.forSale = false;
        emit NFTUnlisted(_id);
    }

    function buyNFT(uint256 _id) external payable {
        NFT storage nft = nfts[_id];
        require(nft.forSale, "Not for sale");
        require(msg.value == nft.price, "Incorrect price");
        require(msg.sender != nft.owner, "Cannot buy your own NFT");

        // Pay previous owner
        nft.owner.transfer(msg.value);

        address prevOwner = nft.owner;
        uint256[] storage prevOwnerNFTs = ownerToNftIds[prevOwner];

        // Transfer ownership
        nft.owner = payable(msg.sender);
        nft.forSale = false;

        // Remove NFT from previous owner's array and add to new owner
        for (uint256 i = 0; i < prevOwnerNFTs.length; i++) {
            if (prevOwnerNFTs[i] == _id) {
                prevOwnerNFTs[i] = prevOwnerNFTs[prevOwnerNFTs.length - 1];
                prevOwnerNFTs.pop();
                break;
            }
        }
        ownerToNftIds[msg.sender].push(_id);

        emit NFTPurchased(_id, msg.sender, msg.value);
    }

    function getMyNFTs() external view returns (uint256[] memory) {
        return ownerToNftIds[msg.sender];
    }

    function getNFT(uint256 _id) external view returns (
        uint256 id,
        string memory title,
        string memory uri,
        address creator,
        address owner,
        uint256 price,
        bool forSale
    ) {
        NFT storage nft = nfts[_id];
        return (nft.id, nft.title, nft.uri, nft.creator, nft.owner, nft.price, nft.forSale);
    }
}
