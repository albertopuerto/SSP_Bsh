/**
 * @description Handler class for Approval (SBAA__Approval__c) - handles approval locking logic
 * @author SNV1SF
 * @date 2025
 */


public without sharing class ApprovalTriggerHandler {
    
 /**
   *Before Insert and Before Update: Validate approver
 */ 
 
    public static void handleBeforeInsert(List<sbaa__Approval__c> newRecords){
      
                for (sbaa__Approval__c approval: newRecords){

                    if (approval.sbaa__ApprovedBy__c != null && approval.sbaa__ApprovedBy__c == UserInfo.getUserId()){
                    approval.addError(Label.ApprovalCreatorCannotApprove);          
               }
         }
 } 
  
   
     public static void handleBeforeUpdate(List<sbaa__Approval__c> newRecords, Map<Id, sbaa__Approval__c> oldMaps){

                for (sbaa__Approval__c approval: newRecords){
                
                if (approval.Id !=null) {
                    
                    if (approval.sbaa__ApprovedBy__c == approval.CreatedById){
                    approval.addError(Label.ApprovalCreatorCannotApprove);
                  }
               }
          }
 }   

/**
   *After Insert: Add share record for approver
 */
 
  public static void handleAfterInsert(List<sbaa__Approval__c> records) { 
        insertSharesForApprovals(records);
    
    } 
    
    
       public static void handleAfterUpdate(List<sbaa__Approval__c>  records, Map<Id, sbaa__Approval__c> oldMap){
       List<sbaa__Approval__c> changedRecords = new List<sbaa__Approval__c>();

        for (sbaa__Approval__c appr: records){
            sbaa__Approval__c oldRecord = oldMap.get(appr.Id);
            if(oldRecord != null && oldRecord.OwnerId != appr.OwnerId && appr.OwnerId != appr.sbaa__AssignedTo__c){
                changedRecords.add(appr);   
            }  

        }  
      
     if (!changedRecords.isEmpty()) {
    insertSharesForApprovals(changedRecords);
     }
        
}


/**
   *After Update: Add share record for approver
 */
    
    private static void insertSharesForApprovals(List<sbaa__Approval__c> records)    { 
   
        Set<sbaa__Approval__Share> sharesToInsert = new Set<sbaa__Approval__Share>();
        
        for (sbaa__Approval__c approval : records){
              
            if (approval.Id != null) {
                
               sbaa__Approval__Share shareRecord = new sbaa__Approval__Share();
                shareRecord.ParentId = approval.Id;
                shareRecord.AccessLevel = 'Edit';
                
                if (approval.sbaa__AssignedTo__c !=null && approval.sbaa__AssignedTo__c != UserInfo.getUserId() && String.isBlank(approval.sbaa__AssignedGroupId__c)) {
                   shareRecord.UserOrGroupId = approval.sbaa__AssignedTo__c;
                   sharesToInsert.add(shareRecord); 
                            
                } else if(approval.sbaa__AssignedGroupId__c !=null && String.isBlank(approval.sbaa__AssignedTo__c)) {
                  shareRecord.UserOrGroupId = approval.sbaa__AssignedGroupId__c;  
                  sharesToInsert.add(shareRecord); 
          
              }    
               
        } 
     }        
        
      if (!sharesToInsert.isEmpty()){
            try{
/**              
 *Convert Set to List
*/
              Database.insert( new List<sbaa__Approval__Share>(sharesToInsert), true);
            } catch (DmlException e){
                Logger.error('APX-EXC-00003-Error inserting share records:', e);
                throw(e);
            } finally {
                Logger.saveLog();
            }
         } 

  }
    
}