public class CreditLimitGetAuthorizations {
   
    @AuraEnabled
    public static void getAuthorizationToken(String objectRecordId) {
         	
            Http http= new Http();
            HttpRequest request = new HttpRequest();
            HttpResponse response = new HttpResponse();

            try{

                request.setEndpoint('testEndpoint');
                request.setMethod('POST');
                request.setHeader('Content-Type', 'application/x-www-form-urlencoded:');
            
                response = http.send(request);

                if(response.getStatus()== '200'){

                }else{
                    Logger.error('Request error details - '+ response.getStatusCode() +'-'+response.getStatus())
                    .addTags(('API,TEST').split(','))
                    .setRecordId(objectRecordId);
                }

            }catch(Exception ex){
                Logger.error('Error while creating the log - '+ ex.getMessage())
                .setRecordId(objectRecordId);
            }finally{
                Logger.saveLog();
            }
            
        
         
    }
}