public with sharing class UserOperations {

	@future
	public static void myUpdateUser(){
		System.debug('Inside @future method: myUpdateUser..');
		List<User> usersToUpdate = new List<User>();
		
		List<User> csmUsers = TestDataFactory.createTestUsers('Account');
		User csmUser = csmUsers[0];
        User csmUser2 = csmUsers[1];
		
		//Deactive Organisation CSM
	    csmUser.isActive = false;
	    usersToUpdate.add(csmUser);
	    System.debug('csmUser status is now: ' + csmUser.isActive);
	    //Deactive Organisation Owner
	    csmUser2.isActive = false;
	    usersToUpdate.add(csmUser2);
	    
	    // start new context via system.runAs() for the same user for test code only
	    // this is a workaround for the error MIXED_DML_OPERATION, DML operation on setup object is not 
	    // permitted after you have updated a non-setup object
	    if(Test.isRunningTest()){
	    	System.runAs(new User(Id = UserInfo.getUserId())){
	    			    update usersToUpdate;
	    	}
	    }	    
	}
}