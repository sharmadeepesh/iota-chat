// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DecentralizedChat {
    struct User {
        string username;
        string publicKey;
    }

    struct Message {
        address sender;
        address receiver;
        string encryptedMessage;
        uint256 timestamp;
        bool isRead;
    }

    mapping(address => User) public users;
    mapping(address => Message[]) public messages;

    event UserRegistered(address userAddress, string username);
    event MessageSent(address indexed from, address indexed to, uint256 timestamp);
    event MessageRead(address indexed by, uint256 messageIndex);

    modifier userExists(address _user) {
        require(bytes(users[_user].username).length != 0, "User does not exist");
        _;
    }

    function registerUser(string memory _username, string memory _publicKey) public {
        require(bytes(users[msg.sender].username).length == 0, "User already registered");
        users[msg.sender] = User(_username, _publicKey);
        emit UserRegistered(msg.sender, _username);
    }

    function sendMessage(address _to, string memory _encryptedMessage) public userExists(_to) {
        require(bytes(users[msg.sender].username).length != 0, "Sender not registered");
        messages[_to].push(Message(msg.sender, _to, _encryptedMessage, block.timestamp, false));
        emit MessageSent(msg.sender, _to, block.timestamp);
    }

    function getMessages() public view returns (Message[] memory) {
        return messages[msg.sender];
    }

    function markMessageAsRead(uint256 _index) public {
        require(_index < messages[msg.sender].length, "Invalid message index");
        Message storage message = messages[msg.sender][_index];
        message.isRead = true;
        emit MessageRead(msg.sender, _index);
    }

    function getUser(address _user) public view returns (string memory, string memory) {
        return (users[_user].username, users[_user].publicKey);
    }
}
