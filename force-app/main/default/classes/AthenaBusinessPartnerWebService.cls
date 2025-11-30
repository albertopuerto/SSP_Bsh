/**
 * @description Web Service class Athena integration
 * BSSP-13685
 *
 * @author Iliana Dimitrova
 * @date 3.11.2025
 */
@RestResource(urlMapping='/v1/boschpartner')
global with sharing class AthenaBusinessPartnerWebService {

    /**
     * @description Handles PATCH requests from Athena middleware.
     *              Accepts JSON payload, validates, and routes to service layer.
     */
    @HttpPatch
    global static void patchPartner() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        res.addHeader('Content-Type', 'application/json; charset=UTF-8');

        Savepoint sp = Database.setSavepoint();

        try {
            String body = req.requestBody != null ? req.requestBody.toString() : null;

            AthenaBusinessPartnerDTO dto = AthenaBusinessPartnerDTO.fromJson(body);
            AthenaBusinessPartnerService.SvcResult result = AthenaBusinessPartnerService.process(dto);

            // SUCCESS payload
            Map<String, Object> payload = new Map<String, Object>();
            payload.put('status', 'SUCCESS');
            if (result.isCreated) {
                payload.put('message', 'New partner data processed successfully');
                payload.put('salesforceId', result.accountId);
                res.statusCode = 201;
            } else {
                payload.put('message', 'Partner data updated successfully');
                payload.put('sfAccountId', result.accountId);
                res.statusCode = 200;
            }
            res.responseBody = Blob.valueOf(JSON.serialize(payload));

        } catch (AthenaBusinessPartnerService.ValidationException e) {
            // Map to 404 or 400 based on the message
            Integer code = isNotFoundMessage(e.getMessage()) ? 404 : 400;

            Logger.warn('APX-INT-00005: Error in PATCH: ' + e.getMessage())
                  .addTags(new List<String>{'APX-INT'});

            res.statusCode = code;
            res.responseBody = Blob.valueOf(JSON.serialize(new Map<String, Object>{
                'status' => 'ERROR',
                'message' => code == 404
                    ? 'Not found, related and needed records are not in the system'
                    : 'Bad Request'
            }));

            Database.rollback(sp);

        } catch (System.NoAccessException e) {
            Logger.error('APX-INT-00005: Forbidden in PATCH: ' + e.getMessage(), e)
                  .addTags(new List<String>{'APX-INT'});
            res.statusCode = 403;
            res.responseBody = Blob.valueOf(JSON.serialize(new Map<String, Object>{
                'status' => 'ERROR',
                'message' => 'Forbidden, insufficient permissions'
            }));

            Database.rollback(sp);

        } catch (Exception e) {
            Logger.error('APX-INT-00005: Unexpected error in PATCH: ' + e.getMessage(), e)
                  .addTags(new List<String>{'APX-INT'});

            res.statusCode = 500;
            res.responseBody = Blob.valueOf(JSON.serialize(new Map<String, Object>{
                'status' => 'ERROR',
                'message' => 'Internal Server Error'
            }));

            Database.rollback(sp);

        } finally {
            Logger.saveLog();
        }
    }

    private static Boolean isNotFoundMessage(String msg) {
        if (String.isBlank(msg)) { return false; }
        String m = msg.toLowerCase();

        return m.contains('not found')
            || m.contains('missing') && m.contains('record')
            || m.startsWith('ac3') || m.startsWith('ac4') || m.startsWith('ac5');
    }
}