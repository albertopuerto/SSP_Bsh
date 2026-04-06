@isTest
private class CPQExternalConfiguratorController_Pricing_Test {
    @isTest
    static void test_post_pricingCreateDocument_201() {
        Test.setMock(HttpCalloutMock.class, new mock_post_pricingCreateDocument_201());

        String raw = CPQExternalConfiguratorController.pricingCreateDocument('{"currency":"EUR"}');
        Map<String, Object> payload = (Map<String, Object>) JSON.deserializeUntyped(raw);

        System.assertEquals('doc-001', (String) payload.get('id'));
    }

    @isTest
    static void test_post_pricingCreateItems_200_con_ifmatch() {
        mock_post_pricingCreateItems_200.lastIfMatch = null;
        Test.setMock(HttpCalloutMock.class, new mock_post_pricingCreateItems_200());

        String raw = CPQExternalConfiguratorController.pricingCreateItems('doc-001', '{"items":[]}', 'W/"4"');
        Map<String, Object> payload = (Map<String, Object>) JSON.deserializeUntyped(raw);

        System.assertEquals(true, payload.get('ok'));
        System.assertEquals('W/"4"', mock_post_pricingCreateItems_200.lastIfMatch);
    }

    @isTest
    static void test_post_pricingCreateDocument_400_throws() {
        Test.setMock(HttpCalloutMock.class, new mock_post_pricingCreateDocument_400());

        Boolean threw = false;
        try {
            CPQExternalConfiguratorController.pricingCreateDocument('{"currency":"EUR"}');
        } catch (Exception e) {
            threw = true;
            System.assert(e.getMessage().contains('SAP VC Pricing API Error 400'));
        }

        System.assertEquals(true, threw, 'Expected call to throw on HTTP 400');
    }

    private class mock_post_pricingCreateDocument_201 implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(201);
            res.setBody('{"id":"doc-001"}');
            return res;
        }
    }

    private class mock_post_pricingCreateItems_200 implements HttpCalloutMock {
        static String lastIfMatch;

        public HttpResponse respond(HttpRequest req) {
            lastIfMatch = req.getHeader('If-Match');
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('{"ok":true}');
            return res;
        }
    }

    private class mock_post_pricingCreateDocument_400 implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(400);
            res.setBody('{"error":"bad request"}');
            return res;
        }
    }
}
