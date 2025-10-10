/**
* @author		APC
* @date			10/10/2025
* @description	Class which manages generation of HTTPMockGenerator
*               to be used in test classes for simulating HTTP callouts.
*               It can be used to return responses with body as String or Blob.
*               It can also capture the HTTP requests made during the callout.
*               It can be used in combination with HTTPMultiRequestMockGenerator
*               to manage multiple mocks in a single test class.
*   		    > Example of use:
*               >> With static resources:
*               	HttpMockGenerator mock = new HttpMockGenerator(200, 'OK',
*                   Test.getResource('MyStaticResource').getBody(), new Map<String, String>{'Content-Type' => 'application/json'});
*				  >>>Or:
*					final StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
*					mock.setStaticResource('mockstatiresource');
*					mock.setStatusCode(200);
*					mock.setHeader('Content-Type', 'application/json');
*               >> Without static resources:
*               HttpMockGenerator mock = new HttpMockGenerator(200, 'OK', '{"key":"value"}', new Map<String, String>{'Content-Type' => 'application/json'});
*               Test.setMock(HttpCalloutMock.class, mock);
*/
@isTest
@SuppressWarnings('PMD.ExcessiveParameterList')
public class HTTPMockGenerator implements HttpCalloutMock {
	public Integer code;
	public String status;
	public String bodyAsString;
	public Blob bodyAsBlob;
	public Map<String, String> responseHeaders;
	public List<HttpRequest> httpRequests;

	/**
	* @author       APC
	* @description  HTTPMockGenerator constructor 2 params
	* @param        code Integer
	* @param        body String
	*/
	public HTTPMockGenerator(Integer code, String body) {
		this.code = code;
		this.bodyAsString = body;
		this.status = 'StatusMessage';
		Map<String,String> headers = new Map<String,String>();
		headers.put('Content-Type', 'application/json');
		this.responseHeaders = headers;
	}

	/**
	* @author       APC
	* @description  HTTPMockGenerator constructor with body as Blob
	* @param        code Integer
	* @param        status String
	* @param        body Blob
	* @param        responseHeaders Map<String, String>
	*/
	public HTTPMockGenerator(Integer code, String status, Blob body, Map<String, String> responseHeaders) {
		this.code = code;
		this.status = status;
		this.bodyAsString = null;
		this.bodyAsBlob = body;
		this.responseHeaders = responseHeaders;
	}

	/**
	* @author       APC
	* @description  HTTPMockGenerator constructor with body as String
	* @param        code Integer
	* @param        status Blob
	* @param        body String
	* @param        responseHeaders Map<String, String>
	*/
	public HTTPMockGenerator(Integer code, String status, String body, Map<String, String> responseHeaders) {
		this.code = code;
		this.status = status;
		this.bodyAsString = body;
		this.bodyAsBlob = null;
		this.responseHeaders = responseHeaders;
	}

	/**
	* @author       APC
	* @description  Make the HTTP mock generator track received HTTP requests
	* @return 		HTTPMockGenerator instance
	**/
	public HTTPMockGenerator captureHttpRequests() {
		httpRequests = new List<HttpRequest>();
		return this;
	}

	/***
	* @author       APC
	* @description  returns HttpResponse
	* @param        req -> HTTPRequest
	* @return 		HTTPResponse
	*/
	public HTTPResponse respond(HTTPRequest req) {
		if (httpRequests != null) {
			httpRequests.add(req);
		}
		HttpResponse resp = new HttpResponse();
		resp.setStatusCode(code);
		resp.setStatus(status);
		if (bodyAsBlob != null) {
			resp.setBodyAsBlob(bodyAsBlob);
		} else {
			resp.setBody(bodyAsString);
		}

		if (responseHeaders != null) {
			for (String key : responseHeaders.keySet()) {
				resp.setHeader(key, responseHeaders.get(key));
			}
		}
		return resp;
	}
}