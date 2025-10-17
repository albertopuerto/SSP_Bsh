/**
* @author       APC
* @date         10/10/2025
* @description  Class that contains the logic of multiple mocks => Map<String, HttpCalloutMock> mapRequest
*/
@isTest
public class HTTPMultiRequestMockGenerator implements HttpCalloutMock {
	Map<String, HttpCalloutMock> mapRequest;

	// /**
	//  * @author       APC
	//  * @description  HTTPMultiRequestMockGenerator constructor, if needed unblock and add basic mocks
	//  */
	 public HTTPMultiRequestMockGenerator() {
	 	this.mapRequest = new Map<String, HttpCalloutMock>();
	 }

	/**
	 * @author       APC
	 * @description This method routes the request to the appropriate mock based on the endpoint.
	 * @param req The HTTPRequest object containing the request details.
	 * @return HTTPResponse The HTTPResponse object returned by the appropriate mock.
	 */
	public HTTPResponse respond(HTTPRequest req) {
		HttpCalloutMock mock = mapRequest.get(req.getEndpoint());

		if (mock != null) {
			return mock.respond(req);
		} else {
			throw new MultiMockException('Mocks has not found for the endpoint: ' + req.getEndpoint());
		}
	}

	/**
	 * @author       APC
	 * @description This method adds a mock to the map of mocks.
	 * @param url The URL endpoint for the mock.
	 * @param mock The HttpCalloutMock instance to associate with the URL.
	 */
	public void putMock(String url, HttpCalloutMock mock) {
		mapRequest.put(url, mock);
	}


	/**
	 * @author       APC
	 * @description Custom exception class for handling MultiMock-related errors.
	 */
	public class MultiMockException extends Exception {}
}