pragma solidity ^0.4.18;

contract EnergyManager {

  /// The seller's address
  address public owner;

  /// The buyer's address part on this contract
  address public buyerAddr;

  /// The Buyer struct  
  struct Buyer {
    address addr;
    string name;

    bool init;
  }

  /// The Order struct
  struct Order {
    string goods;
    uint quantity;
    uint number;
    uint price;
    uint safepay;
    bool init;
  }

  /// The mapping to store orders
  mapping (uint => Order) orders;


  /// The sequence number of orders
  uint orderseq;


  /// Event triggered for every registered buyer
  event BuyerRegistered(address buyer, string name);

  /// Event triggered for every new order
  event OrderSent(address buyer, string goods, uint quantity, uint orderno);

  /// Event triggerd when the order gets valued and wants to know the value of the payment
  event PriceSent(address buyer, uint orderno, uint price);

  /// Event trigger when the buyer performs the safepay
  event SafepaySent(address buyer, uint orderno, uint value, uint now);

  /// The smart contract's constructor
  constructor () public {
    /// The seller is the contract's owner
    owner = msg.sender;
  }

  /// The function to send purchase orders
  ///   requires fee
  ///   Payable functions returns just the transaction object, with no custom field.
  ///   To get field values listen to OrderSent event.
  function sendOrder(string goods, uint quantity) payable public {
    
    /// Accept orders just from buyer
    require(msg.sender == buyerAddr);

    /// Increment the order sequence
    orderseq++;

    /// Create the order register
    orders[orderseq] = Order(goods, quantity, orderseq, 0, 0,  true);

    /// Trigger the event
    emit OrderSent(msg.sender, goods, quantity, orderseq);

  }

  /// The function to query orders by number
  ///   Constant functions returns custom fields
  function queryOrder(uint number) constant public returns (address buyer, string goods, uint quantity, uint price, uint safepay) {
    
    /// Validate the order number
    require(orders[number].init);

    /// Return the order data
    return(buyerAddr, orders[number].goods, orders[number].quantity, orders[number].price, orders[number].safepay);
  }

  /// The function to send the price to pay for order
  ///  Just the owner can call this function
  ///  requires free
  function sendPrice(uint orderno, uint price) payable public {
  
    /// Only the owner can use this function
    require(msg.sender == owner);

    /// Validate the order number
    require(orders[orderno].init);
      /// Update the order price
      orders[orderno].price = price;


    /// Trigger the event
    emit PriceSent(buyerAddr, orderno, price);

  }

  /// The function to send the value of order's price
  ///  This value will be blocked until the delivery of order
  ///  requires fee
  function sendSafepay(uint orderno) payable public {

    /// Validate the order number
    require(orders[orderno].init);

    /// Just the buyer can make safepay
    require(buyerAddr == msg.sender);

    /// The order's value plus the shipment value must equal to msg.value
    require(orders[orderno].price == msg.value);

    orders[orderno].safepay = msg.value;

    emit SafepaySent(msg.sender, orderno, msg.value, now);
  }

 
  function health() pure public returns (string) {
    return "running";
  }
}