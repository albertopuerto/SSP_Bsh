public with sharing class PathOpportunityCallout {
    
       public static String getOpportunityPath(String recordTypeName){

        try{

        Http http= new Http();
        HttpRequest request = new HttpRequest();
        HttpResponse response = new HttpResponse();    

        String endpoint = 'https://bosch-ssp--andresdev.sandbox.lightning.force.com/';
        request.setEndpoint(endpoint+'services/data/v64.0/query/?q=SELECT+Metadata+FROM+PathAssistant+WHERE+recordType.Name+=+recordTypeName');
        request.setMethod('GET');
    
        response = http.send(request);

        return 'test';

        }catch(Exception e){
            System.debug('error'+ e.getMessage());
            return '';
        }
           
        }
    
}