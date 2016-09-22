public class CreateTrainingCaseFlowController {
    public Flow.Interview.Create_Training_Case myflow { get; set; }

    public String getVarValue() {
        if (myflow == null) { 
            return null; 
        }
        else {
            return myflow.varTrainingCaseID;
        }
    }
    
    public PageReference getFinishLocation() {
    
        String caseId = 'home/home.jsp';
        if(myflow != null) caseId = myflow.varTrainingCaseID; 
        PageReference pageRef = new PageReference('/' + caseId);
        return pageRef;
    }
}