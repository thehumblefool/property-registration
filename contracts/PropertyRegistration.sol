pragma solidity ^0.4.2;

contract PropertyRegistration {

	struct User {
		uint ID;
		string name;
		string password;
	}

	struct Owner {
		string transactionID;
		uint userID;
		string time;
		uint cost;
	}

	struct Property {
		uint ID;
		string pType;
		string addres;
		string dimensions;
		Owner currOwner;
		uint[] prevOwners;
	}

	mapping(uint => User) users;

	mapping(uint => Property) properties;
	
	event successEvent (
		string message
	);

	event properyRegisteredEvent (
		string transactionID
	);

	event properyTransferredEvent (
		string transactionID
	);

	event invalidEvent (
		string message
	);
	
	constructor() public {
	}

	function registerUser(uint _userID, string _userName, string _userPassword) public {
		User memory _user = users[_userID];
		if(_user.ID != 0) {
			emit invalidEvent("User already exist");
			return;
		}
		_user.ID = _userID;
		_user.name = _userName;
		_user.password = _userPassword;
		users[_userID] = _user;
		emit successEvent("Successfully created the user");
	}

	function registerProperty(uint _ownerID, string _ownerName, string _ownerPassword, uint _propertyID, string _propertyType, string _propertyDimensions, string _propertyAddress, string _time) public {
		User memory _owner = users[_ownerID];
		if(_owner.ID == 0) {
			_owner.ID = _ownerID;
			_owner.name = _ownerName;
			_owner.password = _ownerPassword;
			users[_ownerID] = _owner;
		} else {
			if(!equals(_owner.password, _ownerPassword)) {
				emit invalidEvent("Invalid password");
				return;
			}
		}

		Property memory _property = properties[_propertyID];
		if(_property.ID != 0) {
			emit invalidEvent("Property already registered");
			return;
		}
		_property.ID = _propertyID;
		_property.pType = _propertyType;
		_property.addres = _propertyAddress;
		_property.dimensions = _propertyDimensions;
		string memory _transactionID = strConcat(strConcat(uint2str(_propertyID), "."), "1");
		_property.currOwner = Owner(_transactionID, _ownerID, _time, 0);
		properties[_propertyID] = _property;

		emit properyRegisteredEvent(_transactionID);
	}

	function transferProperty(uint _propertyID, uint _sellerID, string _sellerName, string _sellerPassword, uint _buyerID, string _buyerName, uint _amount, string _time) public {
		Property memory _property = properties[_propertyID];
		if(_property.ID == 0) {
			emit invalidEvent("Property does not exist");
			return;
		}
		
		User memory _seller = users[_sellerID];
		if(_seller.ID != _sellerID) {
			emit invalidEvent("Seller does not exist");
			return;
		}

		if(!equals(_sellerName, _seller.name)) {
			emit invalidEvent("Seller name does not match");
			return;
		}

		if(!equals(_seller.password, _sellerPassword)) {
			emit invalidEvent("Invalid Password");
			return;
		}

		Owner memory _owner = _property.currOwner;
		if(_owner.userID != _sellerID) {
			emit invalidEvent("You are not authorized to sell this property");
			return;
		}

		User memory _buyer = users[_buyerID];
		if(_buyer.ID == 0) {
			emit invalidEvent("Buyer does not exist");
			return;
		}
		if(!equals(_buyerName, _buyer.name)) {
			emit invalidEvent("Buyer name does not match");
			return;
		}
		string memory _transactionID = strConcat(strConcat(uint2str(_propertyID), "."), uint2str(_property.prevOwners.length+2));
		_property.currOwner = Owner(_transactionID, _buyerID, _time, _amount);
		properties[_propertyID] = _property;
		properties[_propertyID].prevOwners.push(_sellerID);
		emit properyTransferredEvent(_transactionID);
	}

	function getPropertyByID(uint _propertyID) public view returns (uint, string, string, string, uint, string, string, uint) {
		Property memory _property = properties[_propertyID];
		if(_property.ID == 0) {
			return (0, "", "", "", 0, "", "", 0);
		}
		return (_property.ID, _property.pType, _property.addres, _property.dimensions, _property.currOwner.userID, users[_property.currOwner.userID].name, _property.currOwner.time, _property.prevOwners.length);
	}

	function getPrevOwner(uint _propertyID, uint _index) public view returns(uint, string) {
		User memory _prevOwner = users[properties[_propertyID].prevOwners[_index]];
		return (_prevOwner.ID, _prevOwner.name);
	}

	function uint2str(uint _i) internal pure returns (string){
	    if (_i == 0) return "0";
	    uint j = _i;
	    uint length;
	    while (j != 0){
	        length++;
	        j /= 10;
	    }
	    bytes memory bstr = new bytes(length);
	    uint k = length - 1;
	    while (_i != 0){
	        bstr[k--] = byte(48 + _i % 10);
	        _i /= 10;
	    }
	    return string(bstr);
	}

	function strConcat(string _a, string _b) internal pure returns (string){
	    bytes memory _ba = bytes(_a);
	    bytes memory _bb = bytes(_b);
	    string memory ab = new string(_ba.length + _bb.length);
	    bytes memory bab = bytes(ab);
	    uint k = 0;
	    for (uint i = 0; i < _ba.length; i++) bab[k++] = _ba[i];
	    for (i = 0; i < _bb.length; i++) bab[k++] = _bb[i];
	    return string(bab);
	}

	function equals (string memory a, string memory b) internal pure returns (bool) {
       return keccak256(abi.encodePacked(a)) == keccak256(abi.encodePacked(b));
   }
}
