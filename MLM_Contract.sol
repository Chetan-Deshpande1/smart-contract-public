// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

contract Tron {
    using SafeMath for uint256;
    
    uint256 constant public MIN_INVESTMENT = 100000000; // 100trx
    uint256 constant public MIN_WITHDRAW = 20000000 ; // 20 daily withdrwal 
    uint256 constant public MAX_WITHDRAW_PERCENT = 200; //200% total RIO
    uint256 constant public DAILY_RIO = 25; // 25 % daily RIO
    uint256 constant public TIME = 1 days;
    uint256 constant public DIVIDER = 100; //  for equal distribution among all accounts
    
    
    
    address adminAcc;
    address developer;
    address miscellaneous ;
    
    
    uint256 internal totalUsers;
    uint256 internal totalInvested;
    uint256 internal totalWithdrawn;
    address internal owner;
    
    struct Deposit {
        uint256 amount;
        uint256 withdrawn;
        uint256 refIncome;
        uint256 start;
        uint256 max;
        bool active;
        
    }
    
    struct User{
        uint256 id;
        Deposit[]deposits;
        uint256 referral;
       address referrer;
        uint256 totalWithdrawn;
        uint256 holdReferralBonus;
        uint256 referralIncome;
        uint256 rioErned;
        bool isExist;
        
        
    }
    
    
    struct Level {
        uint256 level1;
        uint256 level2;
        uint256 level3;
    }
    
    mapping(address => User )  public users;
    mapping(uint256=>address) public usersList;
    mapping(address=>Level) public levelUserCount;
    
    event NewUserRegisterEvent(address _user,address _ref , uint256 _amount);

    
    
    
    
    constructor(address _adminAcc , address _developer , address _miscellaneous) public {
        owner = msg.sender;
        adminAcc = _adminAcc;
        developer = _developer;
        miscellaneous = _miscellaneous;
      
        
    }
    
    function Invest(address _ref) public payable {
        require(msg.value>=MIN_INVESTMENT,"you should pay min amount");
        if(users[msg.sender].deposits.length ==0){ 
            if(_ref ==address(0) || users[_ref].isExist ==false || _ref == msg.sender){
                _ref = owner;
            }
            if(msg.sender == owner){
                _ref = address(0);
            }
            totalUsers = totalUsers.add(1);
            users[msg.sender].id = totalUsers;
            users[msg.sender].referrer = _ref;
            users[_ref].referral = users[_ref].referral.add(1);
            usersList[totalUsers] = msg.sender;
            users[msg.sender].isExist =true;
            emit NewUserRegisterEvent(msg.sender, _ref,msg.value);
            
            
        }else {
            
            
        }
        totalInvested = totalInvested.add(msg.value); // total amount invested

        users[_ref].referralIncome = users[_ref].
        referralIncome.add(msg.value.mul(10).div(DIVIDER));
        
        users[msg.sender].deposits.
        push(Deposit(msg.value,block.timestamp,0,0,
        MAX_WITHDRAW_PERCENT.mul(msg.value).div(DIVIDER),true));
        
        address(uint256(adminAcc)).transfer(msg.value.mul(4).div(DIVIDER));
        address(uint256(developer)).transfer(msg.value.mul(4).div(DIVIDER));
        address(uint256(miscellaneous)).transfer(msg.value.mul(2).div(DIVIDER));
        
        DistrubuteLevelFund(users[msg.sender].referrer,msg.value);
        
    }

    function DistrubuteLevelFund(address _ref , uint256 _amount) internal {
        for(uint256 i =0 ; i<=2; i++){
            uint256 percent =0 ;
            
            if(_ref == address(0)) {
                
                break;
                
            } else if(i==0) {
                
                percent = 10;
                
            } else if(i==1){
                
                percent = 5;
                
            }else  {
                 percent =3;
                
               
            }
            
        }
    }
    
    
    
    function setLevels(address _user, uint256 _level) public{
        if(_level ==1) {
            levelUserCount[_user].level1 = levelUserCount[_user].level1.add(1);
        }
         if(_level ==2) {
            levelUserCount[_user].level2 = levelUserCount[_user].level2.add(1);
        }
         if(_level ==2) {
            levelUserCount[_user].level3 = levelUserCount[_user].level3.add(1);
        }
    }
    
    
    function WithdrawFunds() public {
        
    }
    
    function getWithdrawableAmountt() public view returns(uint256){
        uint256 totalAmount;
        uint256 dividents;
        address _user = msg.sender;
        
        for(uint256 i;i<users[_user].deposits.length; i++){
            uint256 RIO = DAILY_RIO.mul(users[_user].deposits[i].amount).mul(block.timestamp.sub(users[_user].deposits[i].start)).div(DIVIDER).div(TIME);
            uint256 maxWithdrawn = users[_user].deposits[i].max;
            uint256 alreadyWithdrawn = users[_user].deposits[i].withdrawn;
            uint256 holdReferralBonus = users[_user].holdReferralBonus;
            
            
            //line 255; continue
            
        }
        
        
        
    }

}

 library SafeMath{
 function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0);
        uint256 c = a / b;

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }
}
