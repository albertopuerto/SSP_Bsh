@isTest private class APTS_IntegrationServiceBaseImplTest {
    @isTest private static void shouldGetIntegrationWrapper(){
        // create  APTS_Integration_Repository__c records.
        List<APTS_Integration_Repository__c> lstIntgRepository = new List<APTS_Integration_Repository__c>();
        APTS_Integration_Repository__c inrObj = new APTS_Integration_Repository__c();
        inrObj.APTS_Operation_Name__c = 'INSERT';
        inrObj.APTS_isActive__c = true;
        inrObj.APTS_Log_Messages__c = true;
        inrObj.APTS_Endpoint__c = 'www.apttus.com';
        lstIntgRepository.add(inrObj);
        insert lstIntgRepository;
        
        APTS_IntegrationServiceBaseImplExtender ctrl = new APTS_IntegrationServiceBaseImplExtender();
        APTS_IntegrationMasterWrapper.IntegrationWrapper res = ctrl.getIntegrationWrapper('INSERT'); 
    }
    
    @isTest private static void shouldReturnNullWhenLogNotEnabled(){
         // create  APTS_Integration_Repository__c records.
        List<APTS_Integration_Repository__c> lstIntgRepository = new List<APTS_Integration_Repository__c>();
        APTS_Integration_Repository__c inrObj = new APTS_Integration_Repository__c();
        inrObj.APTS_Operation_Name__c = 'INSERT';
        inrObj.APTS_isActive__c = true;
        inrObj.APTS_Log_Messages__c = false;
        inrObj.APTS_Endpoint__c = 'www.apttus.com';
        lstIntgRepository.add(inrObj);
        insert lstIntgRepository;
        APTS_IntegrationServiceBaseImplExtender ctrl = new APTS_IntegrationServiceBaseImplExtender();
        APTS_IntegrationMasterWrapper.IntegrationWrapper res = ctrl.getIntegrationWrapper('INSERT'); 
    }
    
    @isTest private static void shouldReturnExceptionWhenDataisEmpty(){
        try {
            APTS_IntegrationServiceBaseImplExtender ctrl = new APTS_IntegrationServiceBaseImplExtender();
            APTS_IntegrationMasterWrapper.IntegrationWrapper res = ctrl.getIntegrationWrapper('INSERT');   
        } catch(Exception ex){
            System.assertEquals('APTS_IntegrationServiceBaseImpl.IntegrationServiceException', ex.getTypeName()); 
        }
    }
    
    @isTest private static void shouldBeforeInvoke(){
        APTS_IntegrationServiceBaseImplExtender ctrl = new APTS_IntegrationServiceBaseImplExtender();
        ctrl.beforeInvoke('INSERT');
    }
    
    @isTest private static void shouldInvoke(){
        APTS_IntegrationServiceBaseImplExtender ctrl = new APTS_IntegrationServiceBaseImplExtender();
        ctrl.invoke(new List<APTS_Integration_Set_Header__c>());
    }
    
    @isTest private static void shouldAfterInvoke(){
        APTS_IntegrationServiceBaseImplExtender ctrl = new APTS_IntegrationServiceBaseImplExtender();
        ctrl.afterInvoke();
    }
    
    private class APTS_IntegrationServiceBaseImplExtender extends APTS_IntegrationServiceBaseImpl{
        public virtual void beforeInvoke(String sInputParam, String anotherSInputParam){
        }
    }
}