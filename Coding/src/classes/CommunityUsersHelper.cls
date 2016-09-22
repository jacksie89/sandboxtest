public class CommunityUsersHelper {

	public Integer TotalActiveICUsers, TotalActiveECUsers;
    public Integer OffsetSize = 0;
    public Integer QueryLimit = 20; 	
	public Integer OffsetSizeEC = 0; 
    public Integer QueryLimitEC = 20;
    public String searchstring{get;set;}	
    public Set<Id> userIdsIC = new Set<Id>();
    public Set<Id> userIdsEC = new Set<Id>();
    transient List<User> communityUsers = new List<User>();
    transient List<PermissionSetAssignment> permSetAssignees = new List<PermissionSetAssignment>();	

	public List<User> queryUsers(String communityType){
   		    
	    //Query back all assignees in the IC Community permission set and add to list
	    permSetAssignees = [SELECT AssigneeId FROM PermissionSetAssignment WHERE PermissionSetId 
	                    IN (SELECT Id From PermissionSet Where Label =: communityType)];
	        	    
	    //Query back list of IC/EC users in set of userIds gathered above
	    if(communityType == 'IC Community'){
	    	
		    //Loop through the above list of permission set assignees
		    for(PermissionSetAssignment psa : permSetAssignees){
		       	userIdsIC.add(psa.AssigneeId); // Add assignee id to set of ids to query for users
		    }
	    	
	    	TotalActiveICUsers = [Select Count() from User Where Id IN : userIdsIC And 
	    				isActive = true]; //Total active IC Users
	    	    	
	    	communityUsers = [Select Id, Username, Alias, CommunityNickname, ICUser__c, ECUser__c from User Where Id IN : userIdsIC And 
	    				isActive = true Order By Username ASC limit :QueryLimit offset :OffsetSize];	
	    } else {	    	
		    //Loop through the above list of permission set assignees
		    for(PermissionSetAssignment psa : permSetAssignees){
		       	userIdsEC.add(psa.AssigneeId); // Add assignee id to set of ids to query for users
		    }

	    	TotalActiveECUsers = [Select Count() from User Where Id IN : userIdsEC And 
	    				isActive = true];	//Total active EC Users
	    				
	    	communityUsers = [Select Id, Username, Alias, CommunityNickname, ICUser__c, ECUser__c from User Where Id IN : userIdsEC And 
	    				isActive = true Order By Username ASC limit :QueryLimitEC offset :OffsetSizeEC];	    	
	    }	    
	    return communityUsers;		
	}
		
	public Integer getNumberOfActiveICUsers() {
    	return TotalActiveICUsers;
    }

    public Integer getNumberOfActiveECUsers() {
    	return TotalActiveECUsers;
    } 
    
    //IC ONLY METHODS   
    public PageReference Next() {
        OffsetSize += QueryLimit;
        return null;
    }
    
    public PageReference Previous() {
        OffsetSize -= QueryLimit;
        return null;
    }
    
    public Boolean getDisableNext() { 
        if (OffsetSize + QueryLimit < getNumberOfActiveICUsers()){
            return false;
        }
        else return true;
    }
    
    public Boolean getDisablePrevious(){
        if(OffsetSize>0){
            return false;
        }
        else return true;
    }
    
    //EC ONLY METHODS
    public Boolean getDisablePreviousEC(){
        if(OffsetSizeEC>0){
            return false;
        }
        else return true;
    }    
    
    public Boolean getDisableNextEC() { 
        if (OffsetSizeEC + QueryLimitEC < getNumberOfActiveECUsers()){
            return false;
        }
        else return true;
    }    
    
    public PageReference NextEC() {
        OffsetSizeEC += QueryLimitEC;
        return null;
    }
    
    public PageReference PreviousEC() {
        OffsetSizeEC -= QueryLimitEC;
        return null;
    }     
}

/*	
	public List<User> queryICUsers(){
		
    	Set<Id> icUserIds = new Set<Id>();
    	List<User> icUsers = new List<User>();
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
	    				isActive = true limit :QueryLimit offset :OffsetSize];
	    return icUsers;		
	}
*/