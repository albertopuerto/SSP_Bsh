/*
 * Class Name: APTS_ImportFullySignedDocumentController
 * Usage: This class is used to change staus and status category of the 
 * agreement when fully signed document is uploaded 
 * 
 * ---------------------------------------------------------------------------------------------
 * MODIFY:
 * 07/21/22: Not needed for the Accelerator offering.
 */

public with sharing class APTS_ImportFullySignedDocumentController {
/*
  private Apttus__APTS_Agreement__c agreement;

  public APTS_ImportFullySignedDocumentController(ApexPages.StandardController stdController) { 
    
    this.agreement = (Apttus__APTS_Agreement__c)stdController.getRecord();
    
  }

    //Function Name: finalize
    // Usage: This function is used to change staus and status category of the 
    // agreement when fully signed document is uploaded

  public PageReference finalize(){
    
    agreement.Apttus__Status_Category__c = 'In Signatures';
    agreement.Apttus__Status__c = 'Fully Signed';
    agreement.APTS_Type_of_Signature__c = 'Wet Ink Signature';
    
    update agreement;
    
    PageReference result = new ApexPages.StandardController(agreement).view();
    
    return result;
    
  }
*/

}