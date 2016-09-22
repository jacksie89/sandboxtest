public class activityListBC {
    
    //public List<Lead> allLeads = [Select Id from Lead Where Organisation__c = '0018E00000Edf0E'];
    public List<Lead> allLeads;
    public String currentRecord{get; set;}
    //public ApexPages.StandardController stc;
    //private final Account acct;


    private ApexPages.StandardController ctrl;
    public Account acct {get;set;}

    public activityListBC(ApexPages.StandardController controllerParam){
        ctrl = controllerParam;
        ctrl.addFields(new List<String>{'name'});
        acct = (Account) ctrl.getRecord();
        allLeads = [Select Id from Lead Where Organisation__c =: acct.Id];
    }


    /*public activityListBC(ApexPages.StandardController stdController){
        System.debug('Debug 1...');
        this.acct = (Account)stdController.getRecord();
        System.debug('Debug 2...');
    }*/ 

    public String getGreeting() {
        return 'Record Id: ' + acct.id;
    }
   
    /*public ApexPages.StandardSetController setCon {

        /get {
            if(setCon == null) {
                setCon = new ApexPages.StandardSetController(Database.getQueryLocator(
                    [Select Subject, ActivityDate, Type, OwnerId, CreatedDate, Status From Task Where WhoId = '00Q8E000002PUBc']));
            }
            return setCon;
        }
        set;
        get {
            currentRecord = [SELECT Id, Name FROM Account WHERE Id = :ApexPages.currentPage().getParameters().get('id')];
            //allLeads = [Select Id from Lead Where Organisation__c = :currentRecord.Id];
        }
        set;
        //get {
        currentRecord = currentPage().getParameters().get('id');
        //} set;

    }*/

    // Initialize setCon and return a list of records
    //public List<Task> getLeadTasks() {
    //    return (List<Task>) setCon.getRecords();
    //}
    
    public Task[] getTasks() {
 
         
        currentRecord = ApexPages.currentPage().getParameters().get('id');
        System.debug('currentRecord value: ' + currentRecord);        
        try { //we have to catch query exceptions in case the list is greater than 2000 rows
                //Task[] taskList = [Select Subject, ActivityDate, Type, OwnerId, CreatedDate, Status From Task Where WhoId = '00Q8E000002PUBc'];                   
                Task[] taskList = [Select Id, Subject, ActivityDate, Type, OwnerId, WhoId, Who.Name, CreatedDate, Status From Task Where WhoId IN: allLeads];
                return taskList;
        
        } catch (QueryException e) {                            
                ApexPages.addMessages(e);                   
                return null;
        }        
    }
    
    public Event[] getEvents() {
                
        try { //we have to catch query exceptions in case the list is greater than 2000 rows
                Event[] eventList = [Select Id, Subject, ActivityDate, Type, OwnerId, WhoId, Who.Name, CreatedDate, Event_Status__c From Event Where WhoId IN: allLeads];                   
                return eventList;
        
        } catch (QueryException e) {                            
                ApexPages.addMessages(e);                   
                return null;
        }        
    }     
}