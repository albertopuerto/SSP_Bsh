@isTest
global class APTS_JsonWebServiceMock implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest request) {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"statusCode":null,"status":null,"results":[{"referenceId":"ref1","id":"test123","errors":null}],"hasErrors":false}');
        response.setStatusCode(200);
        return response; 
    }
}