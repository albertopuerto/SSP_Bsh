public class EtasCoreUtils {
    
    @AuraEnabled
    Public Static Boolean hasCustomPermission(String permissionName){
        return FeatureManagement.checkPermission(permissionName);
    }
}