public with sharing class CommunityUsersController {

    //transient Integer CountTotalRecords{get;set;}
    //transient Integer CountTotalRecordsEC{get;set;}
    //public Integer OffsetSize = 0;
    //public Integer OffsetSizeEC = 0;
    //private Integer QueryLimit = 20; 
    //private Integer QueryLimitEC = 20;
    public List<User> icUsers = new List<User>();
    public List<User> ecUsers = new List<User>();
    transient List<User> totalActiveUsers = new List<User>();
    public Integer TotalActiveICUsers;
    public Integer TotalActiveECUsers;
    public CommunityUsersHelper cuHelper = new CommunityUsersHelper();
    public List<User> usrLst {get;set;}
    transient List<User> allCommUsers {get;set;}
    public Map<String, User> myCommUsers = new Map<String, User>();
    transient List<PermissionSetAssignment> commPermSetAssignees = new List<PermissionSetAssignment>();
    public Set<Id> allCommUserIds = new Set<Id>();
    transient String userFullName;
    
    public CommunityUsersController() {
        usrLst = new List<User>(); 
    }
    // the text in the search box
    public string searchText {
        get {
            if (searchText == null) searchText = 'Search Text'; // prefill the serach box for ease of use
            return searchText;
        }
        set;
    }

    public list<User> getUsers(){               
        icUsers = cuHelper.queryUsers('IC Community');
        return icUsers;
    }
    
    public Integer getNumberOfActiveUsers() {
        return cuHelper.getNumberOfActiveICUsers();
    }

    public PageReference searchUser(){
        //String searchQuery = 'Select Email from User Where Username =: searchText';
        //String searchQuery = 'Select Username, CommunityNickname, Alias, ICUser__c, ECUser__c from User Where Name =: searchText AND isActive=true';

        //Query back all assignees in the IC Community permission set and add to list
        commPermSetAssignees = [SELECT AssigneeId FROM PermissionSetAssignment WHERE PermissionSetId 
                        IN (SELECT Id From PermissionSet Where Label = 'IC Community' OR Label = 'EC Community')];
                    
            
        //Loop through the above list of permission set assignees
        for(PermissionSetAssignment psa : commPermSetAssignees){
            allCommUserIds.add(psa.AssigneeId); // Add assignee id to set of ids to query for users
        }
            
        TotalActiveICUsers = [Select Count() from User Where Id IN : allCommUserIds And 
                isActive = true]; //Total active IC Users
                    
        allCommUsers = [Select Id, Name, Username, Alias, CommunityNickname, ICUser__c, ECUser__c from User Where Id IN : allCommUserIds And 
                isActive = true];   

        //Build a map of Names to Users
        for(User commUsr : allCommUsers){
            myCommUsers.put(commUsr.Username, commUsr);
        }
        
        for (String theKey : myCommUsers.keySet()) {  
          System.debug('Key is: ' + theKey);
          System.debug('Values are: ' + myCommUsers.get(theKey));
          //if(myCommUsers.get(theKey).Name == searchText){
          userFullName = myCommUsers.get(theKey).Name;
          if(userFullName.contains(searchText)){
              System.debug('User found...');
              usrLst.add(myCommUsers.get(theKey));
          } else {
              System.debug('User Not Found!!');
          }
        }
        return null;                           
    }
    
    public void clearResults(){
        usrLst.clear();
        searchText = 'Search Text';
    } 
    //IC User Methods
    public Boolean getDisablePrevious(){
        return cuHelper.getDisablePrevious();
    }    
    
    public Boolean getDisableNext() { 
        return cuHelper.getDisableNext();
    }    
    
    public void Next() {
        cuHelper.Next();
    }
    
    public void Previous() {
        cuHelper.Previous();
    } 


    //EC User Methods
    public list<User> getECUsers(){        
        ecUsers = cuHelper.queryUsers('EC Community');
        return ecUsers;
    }

    public Integer getNumberOfActiveECUsers() {
        return cuHelper.getNumberOfActiveECUsers();
    }    
    
    public Boolean getDisablePreviousEC(){
        return cuHelper.getDisablePreviousEC();
    }    
    
    public Boolean getDisableNextEC() { 
        return cuHelper.getDisableNextEC();
    }    
    
    public void NextEC() {
        cuHelper.NextEC();
    }
    
    public void PreviousEC() {
        cuHelper.PreviousEC();
    }     
}


        /*Set<Id> icUserIds = new Set<Id>();
        List<PermissionSetAssignment> icPermSetAssignees = new List<PermissionSetAssignment>();
                
        //Query back all assignees in the IC Community permission set and add to list
        icPermSetAssignees = [SELECT AssigneeId FROM PermissionSetAssignment WHERE PermissionSetId 
                        IN (SELECT Id From PermissionSet Where Label = 'IC Community')];
            
        //Loop through the above list of permission set assignees
        for(PermissionSetAssignment psa : icPermSetAssignees){
            icUserIds.add(psa.AssigneeId); // Add assignee id to set of ids to query for users
        }
        
        //Total active IC Users
        TotalActiveICUsers = [Select Count() from User Where Id IN : icUserIds And 
                        isActive = true];
        
            
        //Query back list of users in set of userIds gathered above
        icUsers = [Select Id, Username, Alias, CommunityNickname, ICUser__c, ECUser__c from User Where Id IN : icUserIds And 
                        isActive = true limit :QueryLimit offset :OffsetSize];*/
                        
        /*Set<Id> ecUserIds = new Set<Id>();
        List<PermissionSetAssignment> ecPermSetAssignees = new List<PermissionSetAssignment>();
        List<User> ecUsers = new List<User>();
        
        //Query back all assignees in the IC Community permission set and add to list
        ecPermSetAssignees = [SELECT AssigneeId FROM PermissionSetAssignment WHERE PermissionSetId 
                        IN (SELECT Id From PermissionSet Where Label = 'EC Community')];
            
        //Loop through the above list of permission set assignees
        for(PermissionSetAssignment psa : ecPermSetAssignees){
            ecUserIds.add(psa.AssigneeId); // Add assignee id to set of ids to query for users
        }
        
        //Total active EC Users
        TotalActiveECUsers = [Select Count() from User Where Id IN : ecUserIds And 
                        isActive = true];
            
        //Query back list of users in set of userIds gathered above
        ecUsers = [Select Id, Username, CommunityNickname, Alias, ICUser__c, ECUser__c from User Where Id IN : ecUserIds And 
                        isActive = true limit :QueryLimitEC offset :OffsetSizeEC];
            
        return ecUsers;*/