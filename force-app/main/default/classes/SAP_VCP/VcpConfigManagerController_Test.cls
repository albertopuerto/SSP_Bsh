@isTest
private class VcpConfigManagerController_Test {
    static String lastIfMatch;

    private static SBQQ__Quote__c crearQuoteDePrueba() {
        return (SBQQ__Quote__c) TestFactory.createSObject(
            new SBQQ__Quote__c(),
            'TestFactoryDefaults.QuoteDefaults',
            true
        );
    }

    @isTest
    static void test_guardar_y_obtener_y_limpiar_config_success() {
        SBQQ__Quote__c quote = crearQuoteDePrueba();

        String saveRaw = VcpConfigManagerController.saveConfigIdToQuote(quote.Id, 'cfg-001');
        Map<String, Object> saveRes = (Map<String, Object>) JSON.deserializeUntyped(saveRaw);
        System.assertEquals(true, saveRes.get('success'));

        String getRaw = VcpConfigManagerController.getConfigIdFromQuote(quote.Id);
        Map<String, Object> getRes = (Map<String, Object>) JSON.deserializeUntyped(getRaw);
        System.assertEquals(true, getRes.get('success'));
        System.assertEquals('cfg-001', (String) getRes.get('configId'));

        String clearRaw = VcpConfigManagerController.clearConfigIdFromQuote(quote.Id);
        Map<String, Object> clearRes = (Map<String, Object>) JSON.deserializeUntyped(clearRaw);
        System.assertEquals(true, clearRes.get('success'));
        System.assertEquals(null, clearRes.get('configId'));
    }

    @isTest
    static void test_get_configuration_200_con_etag_inyectado() {
        Test.setMock(HttpCalloutMock.class, new mock_get_configuration_200());

        String raw = VcpConfigManagerController.getConfigurationV2('cfg-001');
        Map<String, Object> payload = (Map<String, Object>) JSON.deserializeUntyped(raw);

        System.assertEquals('cfg-001', (String) payload.get('id'));
        System.assertEquals('W/"7"', (String) payload.get('_eTag'));
    }

    @isTest
    static void test_reset_configuration_200_auto_etag_desde_get() {
        lastIfMatch = null;
        Test.setMock(HttpCalloutMock.class, new mock_get_then_post_reset_200());

        String raw = VcpConfigManagerController.resetConfigurationV2('cfg-001', '*');
        Map<String, Object> payload = (Map<String, Object>) JSON.deserializeUntyped(raw);

        System.assertEquals(true, payload.get('reset'));
        System.assertEquals('W/"9"', lastIfMatch);
    }

    @isTest
    static void test_get_kbdetermination_200() {
        Test.setMock(HttpCalloutMock.class, new mock_get_kbdetermination_200());

        String raw = VcpConfigManagerController.determineKnowledgebase('F00K001001', '2026-03-31', null, null);
        Map<String, Object> payload = (Map<String, Object>) JSON.deserializeUntyped(raw);

        System.assertEquals('-3', String.valueOf(payload.get('id')));
        System.assertEquals('advancedVariantConfiguration', (String) payload.get('type'));
    }

    @isTest
    static void test_get_translations_200() {
        Test.setMock(HttpCalloutMock.class, new mock_get_translations_200());

        String raw = VcpConfigManagerController.getKnowledgebaseTranslations('-3', 'en');
        Map<String, Object> payload = (Map<String, Object>) JSON.deserializeUntyped(raw);

        List<Object> chars = (List<Object>) payload.get('characteristics');
        System.assertNotEquals(null, chars, 'characteristics must be present');
        System.assert(chars.size() > 0, 'Expected at least one characteristic translation');

        Map<String, Object> firstChar = (Map<String, Object>) chars.get(0);
        System.assertEquals('X70_INCA_BASE_LIC_QM', (String) firstChar.get('id'));

        List<Object> products = (List<Object>) payload.get('products');
        System.assertNotEquals(null, products, 'products must be present');
        System.assertEquals('F00K001001', (String) ((Map<String, Object>) products.get(0)).get('id'));
    }

    @isTest
    static void test_get_char_translations_200() {
        Test.setMock(HttpCalloutMock.class, new mock_get_char_translations_200());

        String raw = VcpConfigManagerController.getKnowledgebaseCharacteristicTranslations('-3', 'en');
        Map<String, Object> payload = (Map<String, Object>) JSON.deserializeUntyped(raw);

        List<Object> chars = (List<Object>) payload.get('characteristics');
        System.assertNotEquals(null, chars, 'characteristics must be present');
        System.assert(chars.size() > 0, 'Expected at least one characteristic translation');

        // Verify possibleValues translations are present for X70_INCA_INCA
        Map<String, Object> incaChar = null;
        for (Object c : chars) {
            Map<String, Object> cm = (Map<String, Object>) c;
            if ('X70_INCA_INCA'.equals((String) cm.get('id'))) {
                incaChar = cm;
                break;
            }
        }
        System.assertNotEquals(null, incaChar, 'X70_INCA_INCA characteristic not found');
        List<Object> possibleValues = (List<Object>) incaChar.get('possibleValues');
        System.assertNotEquals(null, possibleValues, 'possibleValues must be present');
        System.assertEquals(2, possibleValues.size());
    }

    private class mock_get_configuration_200 implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setHeader('ETag', 'W/"7"');
            res.setBody('{"id":"cfg-001","items":[]}');
            return res;
        }
    }

    private class mock_get_then_post_reset_200 implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            String endpoint = req.getEndpoint();

            if (req.getMethod() == 'GET' && endpoint != null && endpoint.contains('/api/v2/configurations/cfg-001')) {
                res.setStatusCode(200);
                res.setHeader('ETag', 'W/"9"');
                res.setBody('{"id":"cfg-001"}');
                return res;
            }

            if (req.getMethod() == 'POST' && endpoint != null && endpoint.contains('/api/v2/configurations/cfg-001/reset')) {
                lastIfMatch = req.getHeader('If-Match');
                res.setStatusCode(200);
                res.setBody('{"reset":true}');
                return res;
            }

            res.setStatusCode(404);
            res.setBody('{"error":"mock route not found"}');
            return res;
        }
    }

    private class mock_get_kbdetermination_200 implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('{"id":-3,"type":"advancedVariantConfiguration"}');
            return res;
        }
    }

    private class mock_get_translations_200 implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            StaticResource sr = [SELECT Body FROM StaticResource WHERE Name = 'vcp_kb_translations_success' LIMIT 1];
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody(sr.Body.toString());
            return res;
        }
    }

    private class mock_get_char_translations_200 implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            StaticResource sr = [SELECT Body FROM StaticResource WHERE Name = 'vcp_kb_translations_characteristics_success' LIMIT 1];
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody(sr.Body.toString());
            return res;
        }
    }
}
