/**
     * @description Used by the Signature__c quick action (Flow) as an invocable Apex action.
     * BSSP-13592
     *
     * @author Iliana Dimitrova
     * @date 2026-02-09
 */
public with sharing class DocuSignSignatureResendController {

    @InvocableMethod(
        label='Resend DocuSign Envelope'
        description='Resends DocuSign envelope for Signature__c record(s) and sets Docusign_Status__c to Resend.'
    )
    /**
         * @description Invocable method used by the Signature__c Flow quick action
         *              to resend the DocuSign envelope for the given Signature record(s).
         * @param signatureIds List of Signature__c record Ids.
     */
    public static void resend(List<Id> signatureIds) {
        if (signatureIds == null || signatureIds.isEmpty()) {
            return;
        }

        List<Signature__c> sigs = [
            SELECT Id, Docusign_Status__c, Envelope_Id__c
            FROM Signature__c
            WHERE Id IN :signatureIds WITH SYSTEM_MODE
        ];

        if (sigs.isEmpty()){
            return;
        }

        DocuSignService svc = new DocuSignService();
        List<Signature__c> toUpdate = new List<Signature__c>();

        for (Signature__c sig : sigs) {

            // DocuSign callout
            svc.resendEnvelope(sig.Envelope_Id__c);

            sig.Docusign_Status__c = 'Resent';
            toUpdate.add(sig);

        }

        if (!toUpdate.isEmpty()) {
            update as system toUpdate;
        }
    }
}