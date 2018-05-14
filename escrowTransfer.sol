pragma solidity ^0.4.0;
contract escrowTransfer {

  struct Transfer {
    address sender;
    address recipient;
    address escrow;
    uint value; // 1 unit = 1 wei (10^18 wei = 1 eth)
    uint deadline;
    bool released;
  }
  mapping(uint => Transfer) transfers;
  uint numTransfers;

  function sendFunds(address recipient, address escrow) public payable returns (bool transferStatus) {
    uint id = numTransfers++;
    Transfer storage a = transfers[id];
    a.sender = msg.sender;
    a.recipient = recipient;
    a.escrow = escrow;
    a.value = msg.value;
    a.deadline = now + 12 weeks;
    a.released = false;
    return a.escrow.send(a.value);
  }

  function releaseFunds(uint id) public payable returns (bool transferStatus) {
    Transfer storage a = transfers[id];
    if ( a.deadline > now ) {
      return a.sender.send(a.value);
    }
    if ( confirmTransfer(id) ) {
      a.released = true;
      return a.recipient.send(a.value);
    }
    return false;
  }

  function confirmTransfer(uint id) public view returns (bool status) {
    Transfer storage a = transfers[id];
    if ( !a.released ) {
      return true;
    }
    return false;
  }

  function logTransfer(uint id) public view returns (address sender, address recipient, address escrow, uint value, uint deadline, bool released) {
    Transfer storage a = transfers[id];
    return (a.sender, a.recipient, a.escrow, a.value, a.deadline, a.released);
  }

}
