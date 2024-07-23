// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;


//CA - 0x2F3b05feF6265F8574CbC9900A8c581c993fEae6




contract SimpleWallet {

    struct Transaction{
        address from;
        address to;
        uint timestamp;
        uint amount;
    }

    Transaction[] public transactionHistory;
   
    address public owner;
    string public str;
    bool public stop;

    event Transfer( address receiver, uint amount);
    event Receive(address sender, uint amount);
    event ReceiveUser(address sender, address receiver, uint amount);



    constructor(){
        owner=msg.sender;
    }


    modifier onlyOwner() {
        require(msg.sender == owner,"You don't have access");
        _;
    }

    mapping(address => uint) suspiciousUser;

    function suspiciousActivity(address _sender) public {
        suspiciousUser[_sender] +=1;
    }

    modifier getSuspiciousUser(address _sender){
        require(suspiciousUser[_sender]<5, "Activity found suspicious,  try later");
        _;
    }

    modifier isEmergencyDeclared(){
        require(stop==false,"Emergency declared");
        _;

    }

    function toggleStop() external onlyOwner isEmergencyDeclared
    {
        stop=!stop;
    }

    


    function changeOwner(address newOwner) public onlyOwner(){
        owner= newOwner;
    }

   
    /**Contract related functions**/
    function transferToContract(uint _startTime) external payable getSuspiciousUser(msg.sender) {
        require(block.timestamp>_startTime, "senf after start Time");
       transactionHistory.push(Transaction({
        from: msg.sender,
        to:address(this),
        timestamp:block.timestamp,
        amount:msg.value
       }));
    }




    function transferToUserViaContract(address payable _to, uint _weiAmount) external onlyOwner {
        require(address(this).balance>=_weiAmount,"Insufficient Balance");
        require(_to!=address(0), "Address format incorrect");
        _to.transfer(_weiAmount);
        transactionHistory.push(Transaction({
        from: msg.sender,
        to:_to,
        timestamp:block.timestamp,
        amount:_weiAmount
       }));
        emit Transfer(_to, _weiAmount );
    }




    function withdrawFromContract(uint _weiAmount) external onlyOwner {
       require(address(this).balance >= _weiAmount, "Insuffficient balance");
       payable(owner).transfer(_weiAmount);
        transactionHistory.push(Transaction({
        from: address(this),
        to:owner,
        timestamp:block.timestamp,
        amount:_weiAmount
       }));
       
    }




    function getContractBalanceInWei() external view returns (uint) {
         return address(this).balance;
    }
   
     /**User related functions**/
    function transferToUserViaMsgValue(address _to) external payable {
       require(owner.balance >=msg.value, "Insufficient Balance");
       require(address(this).balance>=msg.value,"Insufficient Balance");
       require(_to!=address(0), "Address format incorrect");
       payable(_to).transfer(msg.value);
        transactionHistory.push(Transaction({
        from: msg.sender,
        to:_to,
        timestamp:block.timestamp,
        amount:msg.value
       }));
    }




    function receiveFromUser() external payable{
        require(msg.value>0, "wei value must be greater than zero");
        payable(owner).transfer(msg.value);
        emit ReceiveUser(msg.sender, owner, msg.value);
         transactionHistory.push(Transaction({
        from: msg.sender,
        to:owner,
        timestamp:block.timestamp,
        amount:msg.value
       }));
         } 
       
    




    function getOwnerBalanceInWei() external view returns(uint){

        return owner.balance;
       
    }




    receive() external payable {
        transactionHistory.push(Transaction({
        from: msg.sender,
        to:address(this),
        timestamp:block.timestamp,
        amount:msg.value
       }));
        emit Receive(msg.sender, msg.value);


       
    }




    fallback() external  payable {
        payable (msg.sender).transfer(msg.value); //returning ether to the user back

        suspiciousActivity(msg.sender);
       
    }

    function getTransactionHistory() external view returns(Transaction[] memory) {
        return transactionHistory;
        
    }




}

















