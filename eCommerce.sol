// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

/**
 * @title Ecommerce Contract
 * @dev A simple Solidity contract representing an ecommerce system on the Ethereum blockchain.
 */
contract Ecommerce {
    address public owner;

    struct Item {
        uint256 id;
        string name;
        string category;
        string image;
        uint256 cost;
        uint256 rating;
        uint256 stock;
        string description;
    }

    struct Order {
        uint256 time;
        Item item;
    }

    // Mapping to store items with their IDs
    mapping(uint256 => Item) public items;
    // Mapping to store orders for each user
    mapping(address => mapping(uint256 => Order)) public orders;
    // Mapping to store the count of orders for each user
    mapping(address => uint256) public orderCount;

    // Event emitted when an item is listed
    event List(string name, uint256 cost, uint256 quantity);
    // Event emitted when an item is purchased
    event Buy(address buyer, uint256 orderId, uint256 itemId);

    // Modifier to restrict function access to the contract owner
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    /**
     * @dev Lists a new item for sale.
     * @param _id The ID of the item.
     * @param _name The name of the item.
     * @param _category The category of the item.
     * @param _image The image of the item.
     * @param _cost The cost of the item.
     * @param _rating The rating of the item.
     * @param _stock The stock of the item.
     * @param _description The description of the item.
     */
    function list(
        uint256 _id,
        string memory _name,
        string memory _category,
        string memory _image,
        uint256 _cost,
        uint256 _rating,
        uint256 _stock,
        string memory _description
    ) public onlyOwner {
        // Create Item
        Item memory item = Item(
            _id,
            _name,
            _category,
            _image,
            _cost,
            _rating,
            _stock,
            _description
        );

        // Add Item to mapping
        items[_id] = item;

        // Emit event
        emit List(_name, _cost, _stock);
    }

    /**
     * @dev Allows a user to purchase an item.
     * @param _id The ID of the item to be purchased.
     */
    function buy(uint256 _id) public payable {
        // Fetch item
        Item memory item = items[_id];

        // Require enough ether to buy item
        require(msg.value >= item.cost, "Insufficient funds to buy the item");

        // Require item is in stock
        require(item.stock > 0, "Item is out of stock");

        // Create order
        Order memory order = Order(block.timestamp, item);

        // Add order for user
        orderCount[msg.sender]++;
        orders[msg.sender][orderCount[msg.sender]] = order;

        // Subtract stock
        items[_id].stock--;

        // Emit event
        emit Buy(msg.sender, orderCount[msg.sender], item.id);
    }

    /**
     * @dev Allows the contract owner to withdraw the contract's balance.
     */
    function withdraw() public onlyOwner {
        (bool success, ) = owner.call{value: address(this).balance}("");
        require(success, "Withdrawal failed");
    }

    /**
     * @dev Retrieves the details of an item by its ID.
     * @param itemId The ID of the item.
     * @return The item details.
     */
    function getItem(uint256 itemId) external view returns (Item memory) {
        return items[itemId];
    }
}
