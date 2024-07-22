// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;


//CA - 0x2F3b05feF6265F8574CbC9900A8c581c993fEae6




contract SimpleWallet {
   
    address public owner;
    string public str;

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
   
    /**Contract related functions**/
    function transferToContract() external payable  {
       str="Amount transferred to the contract";
    }




    function transferToUserViaContract(address payable _to, uint _weiAmount) external onlyOwner {
        require(address(this).balance>=_weiAmount,"Insufficient Balance");
        _to.transfer(_weiAmount);
        emit Transfer(_to, _weiAmount );
    }




    function withdrawFromContract(uint _weiAmount) external onlyOwner {
       require(address(this).balance >= _weiAmount, "Insuffficient balance");
       payable(owner).transfer(_weiAmount);
    }




    function getContractBalanceInWei() external view returns (uint) {
         return address(this).balance;
    }
   
     /**User related functions**/
    function transferToUserViaMsgValue(address _to) external payable {
       require(owner.balance >=msg.value, "Insufficient Balance");
       require(address(this).balance>=msg.value,"Insufficient Balance");
       payable(_to).transfer(msg.value);
    }




    function receiveFromUser() external payable{
        require(msg.value>0, "wei value must be greater than zero");
        payable(owner).transfer(msg.value);
        emit ReceiveUser(msg.sender, owner, msg.value);
         } 
       
    




    function getOwnerBalanceInWei() external view returns(uint){

        return owner.balance;
       
    }




    receive() external payable {
        str="receive function is called";
        emit Receive(msg.sender, msg.value);


       
    }




    fallback() external  payable {
        payable (msg.sender).transfer(msg.value); //returning ether to the user back

        str="fallback function is called";
       
    }




}

















