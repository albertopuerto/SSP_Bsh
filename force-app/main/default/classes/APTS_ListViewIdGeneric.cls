public class APTS_ListViewIdGeneric {

    @AuraEnabled
    public static String getListViewDetail(String objectName,String viewName){
        List<ListView> listViews = [SELECT DeveloperName,Id 
                                    FROM ListView 
                                    WHERE SobjectType =: objectName
                                    AND DeveloperName =: viewName];
        if(!listViews.isEmpty()){
            return listViews[0].Id;
        }                   
        else{
            return 'FAIL';
        }
    }
     @AuraEnabled
    public static String getDashboardId(String dashboardName){
        List<Dashboard> dashList = [SELECT Id,DeveloperName
                            FROM Dashboard
                            WHERE DeveloperName =: dashboardName];
        if(!dashList.isEmpty()){
            return dashList[0].Id;
        }
        else{
            return 'FAIL';
        }
    }
    
    /*// Get E-Commerce value form presales config setting (Added by Japan Bhavsar on 2/4/2019) 
    @AuraEnabled
    public static APTSMD_Apttus_PreSales_Config_Settings2__c getPresalesConfigSetting(){
      APTSMD_Apttus_PreSales_Config_Settings2__c preSalesConfig = APTSMD_Apttus_PreSales_Config_Settings2__c.getOrgDefaults();
      return preSalesConfig;
    }
    
    // Get E-Commerce URL (Added by Jigar Naik 06/07/2019)
    @AuraEnabled
    public static String getECommerceURL(){
      return APTSMD_API_CommonUtils.getECommerceCommunityURL();
    }
    */

}