public class CasesController {
        
    private final Case a_case;
    private final List<Case> spt_cases { get; set; }
    public List<Case> latest_cases {get; set; }
    public Integer caseCount;
     
    public CasesController() {
        spt_cases = [SELECT CaseNumber, ContactId, OwnerId, Status, Subject FROM Case Where OwnerId='00G20000001d7Kw' And Status='New' ];
    }
    
    public List<Case> getMycases() {
        return spt_cases;
    }
    
    /*public String getNumberOfSupportQueueCases(){
        List<Case> lst = new List<Case>();
        lst = [SELECT CaseNumber, OwnerId FROM Case Where OwnerId='00G20000001d7Kw' And Status<>'Escalated'];
        caseCount = lst.size();
        return 'Number of Cases in Support Queue: ' + caseCount;
    }*/
    
    public PageReference getCurrentCaseNumber() {
        List<Case> lst = new List<Case>();
        lst = [SELECT CaseNumber, ContactId, OwnerId FROM Case Where OwnerId='00G20000001d7Kw' And Status<>'Escalated'];
        caseCount = lst.size();
        return null;
    }
    /*public Integer getCaseCount(){
        //List<Case> lst = new List<Case>();
        //lst = [SELECT CaseNumber, OwnerId FROM Case Where OwnerId='00G20000001d7Kw' And Status='New'];
        //caseCount = lst.size();
        return caseCount;
    }*/
    public List<Case> getMyLatestCases() {
        latest_cases = [SELECT CaseNumber, Contact.Name, Account.Name, OwnerId, Status, Subject FROM Case Where OwnerId='00G20000001d7Kw' And Status='New' ];
        return latest_cases;
    }
}