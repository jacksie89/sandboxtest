public with sharing class CasesController 
{
    private ApexPages.StandardSetController standardController;

    public CasesController(ApexPages.StandardSetController standardController)
    {
        this.standardController = standardController;
    }

    public PageReference bumpCases()
    {       
        // Get the selected records
        List<Case> selectedCases = (List<Case>) standardController.getSelected();

        // Update records       
        for(Case selectedCase : selectedCases)
        {
            if(selectedCase.Priority == null) 
                selectedCase.Priority = 'Low';
            else if(selectedCase.Priority == 'Low')
                selectedCase.Priority = 'Medium';
            else if(selectedCase.Priority == 'Medium')
                selectedCase.Priority = 'High';
        }       

        return null;        
    }

    public PageReference updateCases()
    {       
        // Call StandardSetController 'save' method to update (optional, you can use your own DML)
        return standardController.save();   
    }
}