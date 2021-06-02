// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

contract Test1 {
    using SafeMath for uint256;
    
    uint256 constant public MIN_INVESTMENT = 100e6; // 100trx
    uint256 constant public MIN_WITHDRAW = 20e6; // 20 daily withdrwal 
    uint256 constant public MAX_WITHDRAW_PERCENT = 200; //200% total RIO
    uint256 constant public DAILY_RIO = 25; // 25 % daily RIO
    uint256 constant public TIME =  60 seconds;
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
    event Divident(address _user , uint256 _amount , uint256 _start ,  uint256 _end , uint256 _diff);
    event Withdraw( address _user ,uint256 _amount);
      event NewDeposit(address _user,uint256 _amount);

    
    
    
    
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
            
            if(ifEligibleToGetLevelIncome(_ref,i+1)){
                users[_ref].holdReferralBonus = users[_ref].holdReferralBonus.add(_amount.mul(percent).div(DIVIDER)); 
            }
            setLevels(_ref,i+1);
            _ref = users[_ref].referrer;
            
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
        require(getWithdrawableAmount()>=MIN_WITHDRAW,"you must withdraw  more than 20 trx");
        require(getWithdrawableAmount()<=getContractBalance(),"low contract Balance");
        uint256 totalAmount;
        uint256 dividents;
        address _user =msg.sender;
        
        
        for(uint256 i;i<users[_user].deposits.length; i++){
            uint256 RIO = DAILY_RIO.mul(users[_user].deposits[i].amount).mul(block.timestamp.sub(users[_user].deposits[i].start)).div(DIVIDER).div(TIME);
            uint256 maxWithdrawn = users[_user].deposits[i].max;
            uint256 alreadyWithdrawn = users[_user].deposits[i].withdrawn;
            uint256 holdReferralBonus = users[_user].holdReferralBonus;
            
            if(alreadyWithdrawn != maxWithdrawn){
                if(holdReferralBonus.add(alreadyWithdrawn)>=maxWithdrawn){
                    dividents = maxWithdrawn.sub(alreadyWithdrawn);
                    holdReferralBonus= holdReferralBonus.sub(maxWithdrawn.sub(alreadyWithdrawn));
                    users[_user].deposits[i].active= false;
                }
                else {
                    if(holdReferralBonus.add(alreadyWithdrawn).add(RIO)>=maxWithdrawn){
                        dividents = maxWithdrawn.sub(alreadyWithdrawn);
                    users[_user].rioErned = users[_user].rioErned.add(maxWithdrawn.sub(alreadyWithdrawn.add(holdReferralBonus)));
                    users[_user].deposits[i].active = false;
                    }
                    else {
                        dividents = holdReferralBonus.add(RIO);
                        users[_user].rioErned = users[_user].rioErned.add(RIO);
                    }
                    holdReferralBonus =0;
                    
                }
                users[_user].holdReferralBonus =holdReferralBonus;
            }
            emit Divident(_user ,dividents,users[_user].deposits[i].start,block.timestamp,block.timestamp.sub(users[_user].deposits[i].start));
            if(dividents>0)
            users[_user].deposits[i].start = block.timestamp;
            users[_user].deposits[i].withdrawn = users[_user].deposits[i].withdrawn+dividents;
            totalAmount = totalAmount.add(dividents);
        }
        require(totalAmount>MIN_WITHDRAW,"nothing to withdraw");
        if(totalAmount>getContractBalance()){
            totalAmount = getContractBalance();
        }
        msg.sender.transfer(totalAmount);
         totalWithdrawn = totalWithdrawn.add(totalAmount);
        users[_user].totalWithdrawn = users[_user].totalWithdrawn.add(totalAmount);
                emit Withdraw(_user,totalAmount);

    }
    
    function getWithdrawableAmount() public view returns(uint256){
        uint256 totalAmount;
        uint256 dividents;
        address _user = msg.sender;
        
        for(uint256 i;i<users[_user].deposits.length; i++){
            uint256 RIO = DAILY_RIO.mul(users[_user].deposits[i].amount).mul(block.timestamp.sub(users[_user].deposits[i].start)).div(DIVIDER).div(TIME);
            uint256 maxWithdrawn = users[_user].deposits[i].max;
            uint256 alreadyWithdrawn = users[_user].deposits[i].withdrawn;
            uint256 holdReferralBonus = users[_user].holdReferralBonus;
            
            if(alreadyWithdrawn != maxWithdrawn){
                if(holdReferralBonus.add(alreadyWithdrawn)>=maxWithdrawn){
                    dividents = maxWithdrawn.sub(alreadyWithdrawn);
                }else{
                    if(holdReferralBonus.add(alreadyWithdrawn).add(RIO)>=maxWithdrawn){
                        dividents = holdReferralBonus.add(RIO);
                    }
                }
            }
          
           totalAmount = totalAmount.add(dividents); 
        }
        return totalAmount;
        
        
    }
    
    
    function ifEligibleToGetLevelIncome(address _user , uint256 _level) internal view returns(bool){
        
        if(users[_user].referral>=_level){
            
            return true;
            
        } else {
          
            return false;
        }
    }
     function DepositAmountInContract() external payable{
        
         
        
   
    }
    
     function getUserAddressById(uint256 _id) public view returns(address){
        return usersList[_id];
    }
    
    function getContractBalance() public view returns(uint256){
        return address(this).balance;
    }
    
    function getTotalDepositeCount(address _user) public view returns(uint256){
        return users[_user].deposits.length;
    }
    
      function getTotalInvested() public view returns(uint256){
        return totalInvested;
    }
    
    function getUserInfo(address _user) public view returns(uint256 _id,uint256 _referral,address _referrer,uint256 _totalWithdrawn,uint256 _holdRefIncome,uint256 _referralIncome,uint256 _rioErned){
        return (users[_user].id,users[_user].referral,users[_user].referrer,users[_user].totalWithdrawn,users[_user].holdReferralBonus,users[_user].referralIncome,users[_user].rioErned);
    }
    function getUserTotalDeposits(address _user) public view returns(uint256){
        uint256 totalAmount=0;
        for(uint256 i=0;i<getTotalDepositeCount(_user);i++){
            
                totalAmount = totalAmount.add(users[_user].deposits[i].amount);
            
        }
        return totalAmount;
    }
    
    function getAllDepositInfo(address _user,uint256 _index) public view returns(uint256 amount,
    uint256 start, uint256 withdrawn,uint256 max,bool active){
        return (users[_user].deposits[_index].amount,users[_user].deposits[_index].start,
        users[_user].deposits[_index].withdrawn,users[_user].deposits[_index].max,
        users[_user].deposits[_index].active);
    }
    function getLevelUserCount(address _user,uint256 _level ) public view returns(uint256){
        if(_level ==1){
            return levelUserCount[_user].level1;
        }
         if(_level ==2){
            return levelUserCount[_user].level2;
        }
         if(_level ==3){
            return levelUserCount[_user].level3;
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
