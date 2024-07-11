// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
 
contract ChatApp {
    struct User {
        string username;
        string publicKey;
        address userAddress;
    }
 
    struct Message {
        address sender;
        address receiver;
        string encryptedMessage;
        uint256 timestamp;
        bool isRead;
    }
 
    mapping(address => User) public users;
    mapping(string => address) private usernameToAddress;
    mapping(address => Message[]) private messages;
 
    event UserRegistered(address indexed userAddress, string username);
    event MessageSent(address indexed from, address indexed to, uint256 timestamp);
    event MessageRead(address indexed by, uint256 messageIndex);
 
    modifier userExists(address _user) {
        require(bytes(users[_user].username).length != 0, "User doesn't exist");
        _;        
    }
 
    modifier usernameAvailable(string memory _username) {
        require(usernameToAddress[_username] == address(0), "Username already taken");
        _;
    }
 
    function registerUser(string memory _username, string memory _publicKey) public usernameAvailable(_username) {
        require(bytes(users[msg.sender].username).length == 0, "User already registered");
 
        users[msg.sender] = User(_username, _publicKey, msg.sender);
        usernameToAddress[_username] = msg.sender;
 
        emit UserRegistered(msg.sender, _username);
    }
 
    function sendMessage(address _to, string memory _encryptedMessage) public userExists(_to) {
        require(bytes(users[msg.sender].username).length != 0, "Sender not registered");
 
        messages[_to].push(Message({
            sender: msg.sender,
            receiver: _to,
            encryptedMessage: _encryptedMessage,
            timestamp: block.timestamp,
            isRead: false
        }));
 
        emit MessageSent(msg.sender, _to, block.timestamp);
    }
 
    function getMessages() public view returns (Message[] memory) {
        return messages[msg.sender];
    }
 
    function getSentMessages(address _to) public view returns (Message[] memory) {
        uint256 messageCount = 0;
 
        // Count the number of sent messages
        for (uint256 i = 0; i < messages[_to].length; i++) {
            if (messages[_to][i].sender == msg.sender) {
                messageCount++;
            }
        }
 
        Message[] memory sentMessages = new Message[](messageCount);
        uint256 index = 0;
 
        // Retrieve the sent messages
        for (uint256 i = 0; i < messages[_to].length; i++) {
            if (messages[_to][i].sender == msg.sender) {
                sentMessages[index] = messages[_to][i];
                index++;
            }
        }
 
        return sentMessages;
    }
 
    function markMessageAsRead(uint256 _index) public {
        require(_index < messages[msg.sender].length, "Invalid message index");
 
        Message storage message = messages[msg.sender][_index];
        message.isRead = true;
 
        emit MessageRead(msg.sender, _index);
    }
 
    function findUserByUsername(string memory _username) public view returns (address, string memory) {
        address userAddress = usernameToAddress[_username];
        require(userAddress != address(0), "User not found");
 
        User memory user = users[userAddress];
        return (user.userAddress, user.publicKey);
    }
 
    function getUserByAddress(address _user) public view returns (string memory, string memory) {
        User memory user = users[_user];
        require(bytes(user.username).length != 0, "User not found");
 
        return (user.username, user.publicKey);
    }
 
    function getUser(address _user) public view returns (string memory, string memory, address) {
        User memory user = users[_user];
        return (user.username, user.publicKey, user.userAddress);
    }
}
