//SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.7.0 <0.9.0;

/// @title A simple Vending Machine Contract
/// @author Kalpita Mandal
/// @notice You can use this contract for only the most basic simulation
/// @dev All function calls are currently implemented without side effects
/// @custom:experimental This is an experimental contract.

contract VendingMachine {
    
    struct ItemList{
        uint256 ItemCode;
        string ItemName;
        uint256 ItemCost;
        uint256 Inventory;
    }
    ItemList[] public Items;
    
    uint256 ItemCodeCounter=0;
    address payable MachineOwner;
    mapping(uint256 => bool) RefillListExist;
    
    uint256[] RefillItems;
    
    // events for displaying the menu without function
    event display(ItemList[]);
    
    // checking the use of modifiers in the contract
    modifier MatchOwner() {
        require(msg.sender==MachineOwner);
        _;
    }
    
    //SEE IF IT CAN BE CONNECTED TO METAMASK AND OTHER FUNCTIONS
    //The caller of the contract owns the vending Machine
    constructor() {
        Items.push(ItemList(++ItemCodeCounter,'Coke',20,5));
        Items.push(ItemList(++ItemCodeCounter,'Ice Tea',30,10));
        Items.push(ItemList(++ItemCodeCounter,'Slice',50,20));
        Items.push(ItemList(++ItemCodeCounter,'Tropicana',40,5));
        Items.push(ItemList(++ItemCodeCounter,'Latte',15,35));
        MachineOwner=payable(msg.sender);
        emit display(Items);
    }
    
    function DisplayItems() view public returns(ItemList[] memory){
        return Items;
    }
    
    /// @notice To check the balance for the desired Item
    /// @dev Returns the balance of the sender
    function GetBalance() view public returns(uint256){
        return msg.sender.balance;
    }
    
    /// @notice Expected to buy the Item if the owner is not purchasing and the amount is sufficient
    /// @dev The itemlist type object is expected as result
    // TODO: Test the function
    function BuyItem(uint256 _ItemId) public payable returns(ItemList memory){
        ItemList memory MyItem = Items[_ItemId-1];
        
        require(msg.value==MyItem.ItemCost);
        require(msg.sender!=MachineOwner);
        
        MachineOwner.transfer(msg.value);
        Items[_ItemId-1].Inventory -= 1;
        RefillInventory(_ItemId);
        return MyItem;
    }
    
    /// @notice this function checks if any refill is required, if so adds it to the refillitems array
    /// @dev no value is returned
    function RefillInventory(uint256 _ItemId) internal{
        ItemList memory MyItem = Items[_ItemId-1];
        require(!RefillListExist[MyItem.ItemCode]);
        
        if(MyItem.Inventory<=5){
            RefillItems.push(MyItem.ItemCode);
            if(MyItem.Inventory==0){
                delete Items[_ItemId-1];
            }
        }
        RefillListExist[MyItem.ItemCode] = true;
        RefillInventoryAlert();
    }
    
    /// @notice this function checks gives the list of items that need refilling
    /// @dev returns the refillItems list
    function RefillInventoryAlert() view internal returns(uint256[] memory){
        return RefillItems;
    }
    
    /// @notice this function allows MachineOwner to refill the vending Machine
    /// @dev returns the Itemlist/Menu of the Vending Machine
    // TODO: The function is too complicated need to reduce complexity
    function Refill(uint256 _refillAmount, uint256 _refillItemCode) public payable MatchOwner returns(ItemList[] memory){
        uint256[] memory RefillItem = RefillInventoryAlert();
        for(uint256 j=0;j<=ItemCodeCounter;j++){
            for(uint256 i=0;i<=RefillItem.length;i++){
                if(Items[j].ItemCode == RefillItem[i]){
                    require(Items[j].ItemCode == _refillItemCode);
                    require(msg.value>_refillAmount);
                    Items[j].Inventory += _refillAmount/(Items[j].ItemCost);
                    if(Items[j].Inventory>5){
                        delete RefillItem[i];
                    }
                }
            }
        }
        return Items;
    }
}