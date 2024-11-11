/**
* @Name: APTS_AutoExpiryRenewalBatchScheduler
* @Author: Apttus
* @CreateDate: 02-Aug-2019
* @Description: This class is to Schedule Batch class APTS_AutoExpiryRenewalBatch
---------------------------------------------------------------------------------------------
* @LastModifiedBy: <LastModifiedBy>
* @LastModifiedDate: <LastModifiedDate>
* @ChangeDescription: <ChangeDescription>
**/
global class APTS_AutoExpiryRenewalBatchScheduler implements Schedulable {
   global void execute(SchedulableContext sc) {
      APTS_AutoExpiryRenewalBatch Obj = new APTS_AutoExpiryRenewalBatch(); 
      database.executebatch(Obj);
   }
}