// SPDX-License-Identifier: GPL-3.0

// DEPLOY TO REMIX VIDEO TUTORIAL: https://youtu.be/CvY331RwCDk
// RUN: remixd -s ./ -u https://remix.ethereum.org   
// Go to remix in your browser, connect to localhost, compile, then deploy
pragma solidity ^0.8.0;

contract Bank {
    // VISIBILITY MODIFIERS:
    // public:  Everyone can access
    // private: Can be accessed only from within this contract
    // internal:	Only this contract and contracts deriving from it can access
    // external:	Cannot be accessed internally, only externally (saves gas)

    address public bankOwner; // 'public' variables are at a contract level
    string public bankName;
    mapping(address => uint256) public customerBalance; // create mapping
    // We create a mapping named CustomerBalance with the keys being
    // the wallet address of our customers and value the amount 
    // of Ether they deposit in Wei. Wei is the smallest denomination of Ether (10^18)
    // customerBalance is basically now a JS object like { [wallet addr]: [balance in uint256]...}

    // MSG:
    // msg is a global variable that allows us to access properties like the sender, 
    // the address that initiated the transaction, and value, the amount of Ether in wei being sent.

    // constructor will only run once, when the contract is deployed
    constructor() {
        bankOwner = msg.sender;
        // we're setting the bank owner to the Ethereum address that deploys the contract
        // msg.sender is a global variable that stores the address of the account that initiates a transaction
    }

    // BELOW ARE FUNCTIONS
    // Setter functions change the value of our state variables and cost gas. 
    // Getter functions allow us to get the return value of our state variable.

    // This has visibility specifier of public which means function can be called internally or externally. 
    // Then we have our modifier payable. We need this modifier to recieve money in our contract
    function depositMoney() public payable {
        require(msg.value != 0, "You need to deposit some amount of money!");
        // Require is like a try, catch in javascript.
        customerBalance[msg.sender] += msg.value;
        // increase the balance of the sender of the money (msg.sender), by the amount sent (msg.value)
    }

    // We declared the state variable bankName earlier, now we want to set the value of that state variable
    // We will do so with a setter function which can be called externally, hence why I am using the 
    // external keyword here. We could use public but since we aren't calling this function 
    // anywhere in our contract, we can save gas using external. Setter functions will cost us gas.
    function setBankName(string memory _name) external {
        // function parameters start with underscore (_) by convention and are temporarily stored in memory.
        require(
            msg.sender == bankOwner,
            "You must be the owner to set the name of the bank"
        );
        bankName = _name;
        // You may be wondering, well how do we get the bankName? A getter for the variable was 
        // automatically already created when we initilaized the variable and made it public.
    }

    function withdrawMoney(address payable _to, uint256 _total) public payable {
        // Note: The transfer function is built into Solidity and transfers money to an address.
        require(
            _total <= customerBalance[msg.sender],
            "You have insuffient funds to withdraw"
        );

        customerBalance[msg.sender] -= _total;
        _to.transfer(_total);
    }

    function getCustomerBalance() external view returns (uint256) {
        return customerBalance[msg.sender];
    }

    function getBankBalance() public view returns (uint256) {
        require(
            msg.sender == bankOwner,
            "You must be the owner of the bank to see all balances."
        );
        return address(this).balance;
    }
}
