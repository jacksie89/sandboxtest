public class myFlowController {

    public Flow.Interview.Create_Training_Case myflow { get; set; }
      
    public PageReference getPage() {
          String aReference;
          String pReference;
          if (myFlow==null) { return new PageReference('/home');}
          else aReference ='/'+(String) myFlow.getVariableValue('varParentID');
          return new PageReference(aReference);
         }
   }